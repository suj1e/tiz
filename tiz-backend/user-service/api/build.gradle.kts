plugins {
    `java-library`
    `maven-publish`
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

dependencies {
    api(libs.common)
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            artifactId = "user-api"
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
