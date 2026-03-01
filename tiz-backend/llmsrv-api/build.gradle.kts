plugins {
    `java-library`
    `maven-publish`
    alias(libs.plugins.spring.dependency.management)
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
    // Common module (from Maven Local)
    api("io.github.suj1e:common:1.0.0-SNAPSHOT")

    // WebFlux for reactive client
    api(libs.spring.boot.starter.webflux)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
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
            artifactId = "llmsrv-api"
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/suj1e/tiz")
            credentials {
                username = System.getenv("GITHUB_ACTOR") ?: "token"
                password = System.getenv("GITHUB_TOKEN")
            }
        }
    }
}
