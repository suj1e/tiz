plugins {
    `java-library`
}

dependencies {
    // Jakarta Validation for DTOs
    api("jakarta.validation:jakarta.validation-api")

    // Jackson for JSON serialization
    api("com.fasterxml.jackson.core:jackson-annotations")

    // Spring Web for @HttpExchange
    api(libs.spring.web)

    // Lombok (compile only for DTOs)
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
}
