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
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            artifactId = "usersrv-api"
        }
    }
}
