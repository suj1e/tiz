plugins {
    java
    `java-library`
}

dependencies {
    // Core module
    api(project(":authsrv-core"))
    api(project(":authsrv-api"))

    // Nexora Spring Boot Starters
    implementation(libs.nexora.spring.boot.starter.web)
    implementation(libs.nexora.spring.boot.starter.redis)
    implementation(libs.nexora.spring.boot.starter.kafka)
    implementation(libs.nexora.spring.boot.starter.resilience)
    implementation(libs.nexora.spring.boot.starter.security)
    implementation(libs.nexora.spring.boot.starter.file.storage)
    implementation(libs.nexora.spring.boot.starter.data.jpa)
    implementation(libs.nexora.spring.boot.starter.audit)
    // Note: nexora-spring-boot-starter-id is not available, using local SnowflakeIdGenerator instead

    // Spring Boot starters (not covered by nexora-starters)
    implementation(libs.spring.boot.validation)
    implementation(libs.spring.boot.aop)
    implementation(libs.bundles.oauth2)

    // SpringDoc OpenAPI
    implementation(libs.springdoc.openapi)

    // Database
    implementation(libs.flyway)
    implementation(libs.flyway.mysql)
    runtimeOnly(libs.mysql)

    // Quartz for scheduled tasks
    implementation(libs.spring.boot.quartz)

    // Observability
    implementation(libs.bundles.observability)

    // Spring Cloud for @RefreshScope
    implementation("org.springframework.cloud:spring-cloud-context")

    // MapStruct
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
    annotationProcessor(libs.lombok.mapstruct.binding)

    // QueryDSL - use rootProject extra
    implementation(libs.querydsl.jpa)
    annotationProcessor(libs.querydsl.apt)
    annotationProcessor("com.querydsl:querydsl-apt:${rootProject.extra["querydslVersion"]}:jakarta")
    annotationProcessor(libs.jakarta.persistence.api)
}
