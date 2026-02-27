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

repositories {
    mavenCentral()
    mavenLocal()
    maven {
        url = uri("https://maven.aliyun.com/repository/public")
    }
}

dependencyManagement {
    imports {
        mavenBom(libs.spring.cloud.dependencies.get().toString())
        mavenBom(libs.spring.cloud.alibaba.dependencies.get().toString())
    }
}

dependencies {
    // Common module
    implementation("io.github.suj1e:common:1.0.0-SNAPSHOT")

    // Spring Cloud Gateway
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
