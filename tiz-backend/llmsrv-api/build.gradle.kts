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

dependencyManagement {
    imports {
        mavenBom("org.springframework.boot:spring-boot-dependencies:4.0.2")
    }
}

repositories {
    mavenCentral()
    mavenLocal()
    maven {
        url = uri("https://maven.aliyun.com/repository/public")
    }
    // 阿里云制品仓库 - Snapshot
    maven {
        name = "AliyunPackagesSnapshot"
        url = uri("https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx")
        credentials {
            username = System.getenv("ALIYUN_MAVEN_USERNAME") ?: ""
            password = System.getenv("ALIYUN_MAVEN_PASSWORD") ?: ""
        }
    }
    // 阿里云制品仓库 - Release
    maven {
        name = "AliyunPackagesRelease"
        url = uri("https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-release-epshtr")
        credentials {
            username = System.getenv("ALIYUN_MAVEN_USERNAME") ?: ""
            password = System.getenv("ALIYUN_MAVEN_PASSWORD") ?: ""
        }
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
            name = "AliyunPackages"
            val isSnapshot = version.toString().contains("SNAPSHOT", ignoreCase = true)
            url = uri(
                if (isSnapshot) {
                    "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx"
                } else {
                    "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-release-epshtr"
                }
            )
            credentials {
                username = System.getenv("ALIYUN_MAVEN_USERNAME")
                    ?: project.findProperty("aliyunMavenUsername") as String?
                    ?: ""
                password = System.getenv("ALIYUN_MAVEN_PASSWORD")
                    ?: project.findProperty("aliyunMavenPassword") as String?
                    ?: ""
            }
        }
    }
}
