plugins {
    java
    `java-library`
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.jib)
}

dependencies {
    // Adapter module (includes core and api transitively)
    implementation(project(":authsrv-adapter"))

    // Nacos 服务发现与配置中心
    implementation(libs.spring.cloud.alibaba.nacos.discovery)
    implementation(libs.spring.cloud.alibaba.nacos.config)
    implementation(libs.spring.cloud.bootstrap)
    implementation(libs.spring.cloud.loadbalancer)

    // Jasypt for property encryption
    implementation(libs.jasypt)

    // Observability
    implementation(libs.bundles.observability)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Test
    testImplementation(libs.bundles.testing)
}

tasks.bootJar {
    archiveFileName.set("authsrv.jar")
}

tasks.jar {
    enabled = false
}

// Jib 容器化配置
jib {
    from {
        image = "eclipse-temurin:21-jre-alpine"
        platforms {
            platform {
                architecture = "amd64"
                os = "linux"
            }
            platform {
                architecture = "arm64"
                os = "linux"
            }
        }
    }
    to {
        image = "nexora/authsrv:${project.version}"
        tags = setOf("latest")
    }
    container {
        jvmFlags = listOf(
            "-XX:+UseG1GC",
            "-XX:MaxRAMPercentage=75.0",
            "-XX:+UseStringDeduplication",
            "-Djava.security.egd=file:/dev/./urandom"
        )
        ports = listOf("8080")
        labels.set(mapOf(
            "maintainer" to "Nexora Team",
            "version" to "${project.version}",
            "component" to "auth"
        ))
        creationTime.set("USE_CURRENT_TIMESTAMP")
    }
}

// 代码质量任务
tasks.register("lint") {
    description = "运行代码风格检查"
    group = "verification"
}

tasks.register("buildDocker") {
    description = "使用 Jib 构建 Docker 镜像"
    group = "build"
    dependsOn("jibDockerBuild")
}
