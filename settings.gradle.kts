rootProject.name = "tiz-backend"

include("common")
include("authsrv")
include("chatsrv")
include("contentsrv")
include("gatewaysrv")
include("llmsrv")
include("practicesrv")
include("quizsrv")
include("usersrv")

dependencyResolutionManagement {
    repositories {
        mavenCentral()
        mavenLocal()
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
    }
}
