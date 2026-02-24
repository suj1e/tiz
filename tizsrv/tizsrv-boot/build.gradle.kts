plugins {
    java
    alias(libs.plugins.spring.boot)
}

dependencies {
    // Adapter module (includes core and api transitively)
    implementation(project(":tizsrv-adapter"))

    // Nacos
    implementation(libs.spring.cloud.alibaba.nacos.discovery)
    implementation(libs.spring.cloud.alibaba.nacos.config)
    implementation(libs.spring.cloud.bootstrap)
    implementation(libs.spring.cloud.loadbalancer)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Test
    testImplementation(libs.bundles.testing)

    // Test containers
    testImplementation(libs.testcontainers.kafka)
    testImplementation(libs.testcontainers.mysql)
    testImplementation(libs.testcontainers.junit)
}

tasks.bootJar {
    archiveFileName.set("tizsrv-boot.jar")
}

tasks.jar {
    enabled = false
}
