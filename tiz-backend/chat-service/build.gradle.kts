plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
}

subprojects {
    group = rootProject.group
    version = rootProject.version

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
}
