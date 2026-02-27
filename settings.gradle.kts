rootProject.name = "quizsrv-root"

include("common")
include("quizsrv")

dependencyResolutionManagement {
    repositories {
        mavenCentral()
        mavenLocal()
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
    }
}
