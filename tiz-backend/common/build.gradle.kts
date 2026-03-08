plugins {
    `java-library`
    `maven-publish`
    alias(libs.plugins.spring.dependency.management)
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

// Maven repository URLs
val aliyunMavenSnapshotUrl = "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx"
val aliyunMavenReleaseUrl = "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-release-epshtr"

dependencyManagement {
    imports {
        mavenBom("org.springframework.boot:spring-boot-dependencies:${libs.versions.spring.boot.get()}")
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
        url = uri(aliyunMavenSnapshotUrl)
        credentials {
            username = System.getenv("ALIYUN_MAVEN_USERNAME") ?: ""
            password = System.getenv("ALIYUN_MAVEN_PASSWORD") ?: ""
        }
    }
    // 阿里云制品仓库 - Release
    maven {
        name = "AliyunPackagesRelease"
        url = uri(aliyunMavenReleaseUrl)
        credentials {
            username = System.getenv("ALIYUN_MAVEN_USERNAME") ?: ""
            password = System.getenv("ALIYUN_MAVEN_PASSWORD") ?: ""
        }
    }
}

dependencies {
    // Spring Boot Starters (core only)
    api(libs.spring.boot.starter.web)
    api(libs.spring.boot.starter.data.jpa)
    api(libs.spring.boot.starter.validation)
    api(libs.spring.boot.starter.security)

    // QueryDSL (Jakarta)
    api(variantOf(libs.querydsl.jpa) { classifier("jakarta") })

    // Security
    api(libs.bundles.jjwt)

    // Jackson
    api(libs.bundles.jackson)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // MapStruct
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)
    annotationProcessor(libs.lombok.mapstruct.binding)
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
    repositories {
        maven {
            name = "AliyunPackages"
            val isSnapshot = version.toString().contains("SNAPSHOT", ignoreCase = true)
            url = uri(
                if (isSnapshot) {
                    aliyunMavenSnapshotUrl
                } else {
                    aliyunMavenReleaseUrl
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
