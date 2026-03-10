plugins {
    `java-library`
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

dependencies {
    // BOMs
    implementation(platform(libs.spring.cloud.dependencies))
    implementation(platform(libs.spring.cloud.alibaba.dependencies))

    // Common module (exclude servlet-based and JPA dependencies for reactive gateway)
    implementation(libs.common) {
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-web")
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-data-jpa")
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-security")
        exclude(group = "com.querydsl", module = "querydsl-jpa")
        exclude(group = "com.alibaba.nacos", module = "logback-adapter")
    }

    // Spring Cloud Gateway (reactive)
    implementation(libs.spring.boot.starter.webflux)
    implementation(libs.spring.cloud.starter.gateway)
    implementation(libs.spring.cloud.loadbalancer)

    // Spring Cloud Nacos
    implementation(libs.spring.cloud.nacos.discovery) {
        exclude(group = "com.alibaba.nacos", module = "nacos-log4j2-adapter")
    }
    implementation(libs.spring.cloud.nacos.config) {
        exclude(group = "com.alibaba.nacos", module = "nacos-log4j2-adapter")
    }
    // Explicit nacos-client version for compatibility
    implementation("com.alibaba.nacos:nacos-client:3.0.1")

    // Spring Boot Actuator
    implementation(libs.spring.boot.starter.actuator)

    // Security (JWT)
    implementation(libs.bundles.jjwt)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Testing
    testImplementation(libs.spring.boot.starter.test)
    testImplementation(libs.reactor.test)
}

tasks.withType<Test> {
    useJUnitPlatform()
}
