plugins {
    java
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

dependencyManagement {
    imports {
        mavenBom(libs.spring.cloud.dependencies.get().toString())
        mavenBom(libs.spring.cloud.alibaba.dependencies.get().toString())
    }
}

dependencies {
    // 本地 api 模块
    implementation(project(":api"))

    // Common module (from Maven Local)
    implementation(libs.common)

    // Service APIs (from Maven Local)
    implementation(libs.content.api)
    implementation(libs.llm.api)

    // Spring Boot Starters
    implementation(libs.spring.boot.starter.web)
    implementation(libs.spring.boot.starter.data.jpa)
    implementation(libs.spring.boot.starter.data.redis)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.security)
    implementation(libs.spring.boot.starter.actuator)
    implementation(libs.spring.kafka)

    // Spring Cloud
    implementation(libs.spring.cloud.nacos.discovery)
    implementation(libs.spring.cloud.nacos.config)

    // QueryDSL
    implementation(libs.querydsl.jpa)

    // Security (JWT already in common)
    implementation(libs.bundles.jjwt)

    // Database
    runtimeOnly(libs.mysql.connector.j)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // MapStruct
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)
    annotationProcessor(libs.lombok.mapstruct.binding)

    // Testing
    testImplementation(libs.bundles.testing)
    testRuntimeOnly("com.h2database:h2")
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
