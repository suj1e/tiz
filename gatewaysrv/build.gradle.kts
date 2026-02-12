plugins {
    java
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
}

group = "com.nexora"
version = "1.0.0"

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
    // 所有配置的依赖解析策略
    all {
        resolutionStrategy {
            // 缓存动态版本30天
            cacheDynamicVersionsFor(30, "days")
            // 缓存快照版本10分钟
            cacheChangingModulesFor(10, "minutes")
        }
    }
}

repositories {
    mavenCentral()
    mavenLocal()
    // 云效私有仓库（支持环境变量覆盖）
    maven {
        url = uri(System.getenv("MAVEN_REPO_URL")?.takeIf { it.isNotBlank() } ?: "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx")
        name = "Aliyun Packages"
        credentials {
            username = System.getenv("MAVEN_USERNAME") ?: project.findProperty("mavenUsername") as String?
            password = System.getenv("MAVEN_PASSWORD") ?: project.findProperty("mavenPassword") as String?
        }
    }
    // 添加阿里云镜像（加速国内访问）
    maven {
        url = uri("https://maven.aliyun.com/repository/public")
        name = "Aliyun Public"
    }
    // Spring里程碑仓库（如需要预发布版本）
    maven {
        url = uri("https://repo.spring.io/milestone")
        name = "Spring Milestone"
    }
}

dependencyManagement {
    imports {
        // 使用正确的API
        mavenBom(libs.spring.cloud.dependencies.get().toString())
        mavenBom(libs.spring.cloud.alibaba.dependencies.get().toString())
    }
    dependencies {
        // Jackson 版本由 Spring Boot BOM 管理
    }
}

dependencies {
    // Spring Cloud Gateway
    implementation(libs.spring.cloud.gateway)
    implementation(libs.spring.cloud.loadbalancer)

    // 服务发现 & 配置中心
    implementation(libs.spring.cloud.nacos.discovery) {
        // 排除Spring Boot Web以避免与WebFlux冲突
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-web")
    }
    implementation(libs.spring.cloud.nacos.config) {
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-web")
    }

    // 熔断器
    implementation(libs.spring.cloud.circuitbreaker)

    // 限流
    implementation(libs.spring.boot.redis.reactive)

    // Nexora Spring Boot Starters
    implementation(libs.nexora.spring.boot.starter.webflux)
    implementation(libs.nexora.spring.boot.starter.security) {
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-web")
    }
    implementation(libs.nexora.spring.boot.starter.resilience)
    implementation(libs.nexora.spring.boot.starter.observability)

    // 可观测性
    implementation(libs.bundles.observability)

    // 链路追踪 - OpenTelemetry + Tempo
    implementation("io.micrometer:micrometer-tracing-bridge-otel")
    implementation("io.opentelemetry:opentelemetry-exporter-otlp")

    // Caffeine 缓存（Spring Cloud LoadBalancer 生产环境推荐）
    implementation("com.github.ben-manes.caffeine:caffeine")

    // 验证
    implementation(libs.spring.boot.validation)

    // 结构化日志 (JSON 格式输出给 Filebeat/Elasticsearch)
    implementation("net.logstash.logback:logstash-logback-encoder:8.0")

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // 测试
    testImplementation(libs.bundles.testing)
}

// 测试配置优化
tasks.withType<Test> {
    useJUnitPlatform()

    // 并行测试执行（基于CPU核心数）
    maxParallelForks = (Runtime.getRuntime().availableProcessors() / 2).coerceAtLeast(1)

    // JVM参数优化
    jvmArgs("-XX:+UseG1GC", "-Xmx512m", "-Xms256m")

    testLogging {
        events("passed", "skipped", "failed", "standard_out", "standard_error")
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
        showStandardStreams = false
    }

    // 测试报告配置
    reports {
        junitXml.required.set(true)
        html.required.set(true)
    }

    // 系统属性
    systemProperty("spring.profiles.active", "test")
}

// Jib 容器化配置已移除 - 使用 Dockerfile 构建

// 构建优化任务
tasks.register("qualityCheck") {
    group = "verification"
    description = "运行所有质量检查"
    dependsOn("test", "check")
}
