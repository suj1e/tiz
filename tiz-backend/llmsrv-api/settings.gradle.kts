rootProject.name = "llmsrv-api"

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
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
