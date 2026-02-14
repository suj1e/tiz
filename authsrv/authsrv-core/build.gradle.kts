plugins {
    `java-library`
}

dependencies {
    // Nexora Common (for PasswordUtil, etc.)
    api(libs.nexora.common)
    implementation(libs.nexora.spring.boot.starter.data.jpa)

    // Jakarta Persistence API for entity annotations
    api("jakarta.persistence:jakarta.persistence-api")

    // Spring Data for JPA annotations in BaseEntity
    api("org.springframework.data:spring-data-jpa")
    api("org.springframework:spring-context")

    // Spring Security for PasswordEncoder in domain services
    api("org.springframework.security:spring-security-crypto")
    api("org.springframework.security:spring-security-core")

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
}
