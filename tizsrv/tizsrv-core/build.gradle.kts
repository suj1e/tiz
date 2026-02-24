plugins {
    `java-library`
}

dependencies {
    // Nexora Spring Boot Starters
    api(libs.nexora.spring.boot.starter.data.jpa)
    api(libs.nexora.spring.boot.starter.kafka)
    api(libs.nexora.spring.boot.starter.audit)

    // Spring Boot starters (always included)
    api(libs.spring.boot.validation)
    api(libs.spring.boot.aop)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
}
