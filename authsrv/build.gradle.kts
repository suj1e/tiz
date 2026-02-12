plugins {
    java
    `java-library`
}

// Get versions from TOML (at root level, libs is available)
val springBootVersion = libs.versions.spring.boot.get()
val springCloudVersion = libs.versions.springCloud.get()
val springCloudAlibabaVersion = libs.versions.springCloudAlibaba.get()
val lombokMapstructBindingVersion = libs.versions.lombokMapstructBinding.get()
val springdocVersion = libs.versions.springdoc.get()
val querydslVersion = libs.versions.querydsl.get()

// Expose to subprojects
extra["springBootVersion"] = springBootVersion
extra["springCloudVersion"] = springCloudVersion
extra["springCloudAlibabaVersion"] = springCloudAlibabaVersion
extra["lombokMapstructBindingVersion"] = lombokMapstructBindingVersion
extra["springdocVersion"] = springdocVersion
extra["querydslVersion"] = querydslVersion

allprojects {
    group = "com.nexora"
    version = "1.0.0"

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
}

subprojects {
    apply {
        plugin("java")
        plugin("java-library")
    }

    java {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-parameters")
        options.encoding = "UTF-8"
    }

    tasks.withType<Test>().configureEach {
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
        systemProperty("java.util.logging.manager", "org.jboss.logmanager.LogManager")
    }

    dependencies {
        // Spring Boot BOM
        implementation(platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))
        annotationProcessor(platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))
        testImplementation(platform("org.springframework.boot:spring-boot-dependencies:$springBootVersion"))

        // Spring Cloud BOM
        implementation(platform("org.springframework.cloud:spring-cloud-dependencies:$springCloudVersion"))

        // Spring Cloud Alibaba BOM
        implementation(platform("com.alibaba.cloud:spring-cloud-alibaba-dependencies:$springCloudAlibabaVersion"))
    }

    configurations {
        compileOnly {
            extendsFrom(configurations.annotationProcessor.get())
        }
        // 依赖解析策略
        all {
            resolutionStrategy {
                // 缓存动态版本30天
                cacheDynamicVersionsFor(30, "days")
                // 缓存快照版本10分钟
                cacheChangingModulesFor(10, "minutes")
            }
            // 排除 Nacos logback 适配器（与 Logback 冲突）
            exclude(group = "com.alibaba.nacos", module = "logback-adapter")
        }
    }
}

// 构建优化任务
tasks.register("qualityCheck") {
    group = "verification"
    description = "运行所有质量检查（测试 + 代码检查）"
    dependsOn(subprojects.map { it.tasks.named("check") })
    dependsOn(subprojects.map { it.tasks.named("test") })
}
