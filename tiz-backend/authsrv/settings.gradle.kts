dependencyResolutionManagement {
    versionCatalogs {
        create("libs") {
            from(files("../common/gradle/libs.versions.toml"))
        }
    }
}

rootProject.name = "authsrv"
