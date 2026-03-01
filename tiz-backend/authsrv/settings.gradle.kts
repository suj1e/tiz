rootProject.name = "authsrv"

include("api")
include("app")

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        mavenLocal()
        mavenCentral()
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        // GitHub Packages - for common, llmsrv-api, contentsrv-api
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
