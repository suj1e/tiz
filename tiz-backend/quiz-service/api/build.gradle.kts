plugins {
    `java-library`
    `maven-publish`
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

dependencies {
    // Common module (from Maven Local)
    api("io.github.suj1e:common:1.0.0-SNAPSHOT")

    // Jakarta validation for DTO annotations
    api("jakarta.validation:jakarta.validation-api:3.0.2")
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            artifactId = "quiz-api"
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
