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
    implementation(project(":common"))

    // Spring Boot Starters
    implementation(libs.spring.boot.starter.web)
    implementation(libs.spring.boot.starter.data.jpa)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.actuator)
    implementation(libs.spring.boot.starter.aop)
    implementation(libs.spring.boot.starter.webflux)
    implementation(libs.spring.boot.starter.kafka)

    // Spring Cloud
    implementation(libs.spring.cloud.starter.openfeign)
    implementation(libs.spring.cloud.nacos.discovery)
    implementation(libs.spring.cloud.nacos.config)
    implementation(libs.spring.cloud.loadbalancer)

    // QueryDSL
    implementation(libs.querydsl.jpa)
    annotationProcessor(libs.querydsl.jpa)
    annotationProcessor(libs.jakarta.persistence.api)

    // MapStruct
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)
    annotationProcessor(libs.lombok.mapstruct.binding)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Database
    runtimeOnly(libs.mysql.connector.j)

    // Testing
    testImplementation(libs.bundles.testing)
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<JavaCompile> {
    options.compilerArgs.addAll(listOf(
        "-Amapstruct.defaultComponentModel=spring",
        "-Amapstruct.unmappedTargetPolicy=IGNORE"
    ))
}
