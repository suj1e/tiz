rootProject.name = "authsrv"

dependencyResolutionManagement {
    repositories {
        mavenLocal()
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/spring") }
        mavenCentral()
    }
}

include(
    "authsrv-api",
    "authsrv-core",
    "authsrv-adapter",
    "authsrv-boot"
)
