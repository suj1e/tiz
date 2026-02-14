plugins {
    java
    alias(libs.plugins.spring.boot)
}

dependencies {
    implementation(project(":authsrv-adapter"))

    // Nacos
    implementation(libs.spring.cloud.alibaba.nacos.discovery)
    implementation(libs.spring.cloud.alibaba.nacos.config)
    implementation(libs.spring.cloud.bootstrap)
    implementation(libs.spring.cloud.loadbalancer)

    // Jasypt
    implementation(libs.jasypt)

    // Observability
    implementation(libs.bundles.observability)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Test
    testImplementation(libs.bundles.testing)
    testImplementation(libs.testcontainers.kafka)
    testImplementation(libs.testcontainers.mysql)
    testImplementation(libs.testcontainers.junit)
}

tasks.bootJar {
    archiveFileName.set("authsrv.jar")
}

tasks.jar {
    enabled = false
}
