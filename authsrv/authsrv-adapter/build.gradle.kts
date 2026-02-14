plugins {
    `java-library`
}

dependencies {
    // Internal modules
    api(project(":authsrv-core"))
    api(project(":authsrv-api"))

    // Nexora Spring Boot Starters
    implementation(libs.nexora.spring.boot.starter.web)
    implementation(libs.nexora.spring.boot.starter.security)
    implementation(libs.nexora.spring.boot.starter.redis)
    implementation(libs.nexora.spring.boot.starter.resilience)

    // SpringDoc OpenAPI
    implementation(libs.springdoc.openapi)

    // Database
    implementation(libs.flyway)
    implementation(libs.flyway.mysql)
    runtimeOnly(libs.mysql)

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

    // QueryDSL (optional)
    // {{ADAPTER_QUERYDSL}}
}
