plugins {
    `java-library`
    `maven-publish`
}

group = "io.github.suj1e"
version = "1.0.0-SNAPSHOT"

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
    mavenCentral()
    mavenLocal()
    maven {
        url = uri("https://maven.aliyun.com/repository/public")
    }
}

dependencies {
    // Spring Boot Starters (core only)
    api(libs.spring.boot.starter.web)
    api(libs.spring.boot.starter.data.jpa)
    api(libs.spring.boot.starter.data.redis)
    api(libs.spring.boot.starter.validation)
    api(libs.spring.boot.starter.security)
    api(libs.spring.boot.starter.actuator)

    // QueryDSL (Jakarta)
    api("com.querydsl:querydsl-jpa:5.1.0:jakarta")

    // Security
    api(libs.bundles.jjwt)

    // Jackson
    api(libs.bundles.jackson)

    // Logging
    api(libs.logstash.logback.encoder)

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

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            artifactId = "common"
        }
    }
}
