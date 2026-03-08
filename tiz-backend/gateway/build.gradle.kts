plugins {
    `java-library`
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
}

group = "io.github.suj1e"
version = "1.0.0-SNAPSHOT"

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

    // Common module (exclude servlet-based dependencies for reactive gateway)
    implementation("io.github.suj1e:common:1.0.0-SNAPSHOT") {
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-web")
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-data-jpa")
        exclude(group = "com.mysql", module = "mysql-connector-j")
    }

    // Spring Cloud Gateway (reactive)
    implementation(libs.spring.boot.starter.webflux)
    implementation(libs.spring.cloud.starter.gateway)
    implementation(libs.spring.cloud.loadbalancer)

    // Spring Cloud Nacos
    implementation(libs.spring.cloud.nacos.discovery)
    implementation(libs.spring.cloud.nacos.config)

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
