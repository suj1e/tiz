plugins {
    alias(libs.plugins.spring.dependency.management)
}

group = "io.github.suj1e"
version = "1.0.0-SNAPSHOT"

subprojects {
    apply(plugin = "java-library")

    repositories {
        mavenCentral()
        mavenLocal()
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
    }
}
