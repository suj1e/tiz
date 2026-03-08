plugins {
    java
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

dependencyManagement {
    imports {
        mavenBom(libs.spring.cloud.dependencies.get().toString())
        mavenBom(libs.spring.cloud.alibaba.dependencies.get().toString())
    }
}

dependencies {
    implementation(project(":api"))
    implementation("io.github.suj1e:common:1.0.0-SNAPSHOT")

    implementation(libs.spring.boot.starter.web)
    implementation(libs.spring.boot.starter.data.jpa)
    implementation(libs.spring.boot.starter.data.redis)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.security)
    implementation(libs.spring.boot.starter.actuator)

    implementation(libs.spring.cloud.nacos.discovery)
    implementation(libs.spring.cloud.nacos.config)

    // QueryDSL
    implementation("com.querydsl:querydsl-jpa:5.1.0:jakarta")

    // JWT
    implementation(libs.bundles.jjwt)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // MapStruct
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)
    annotationProcessor(libs.lombok.mapstruct.binding)

    runtimeOnly(libs.mysql.connector.j)
    testImplementation(libs.bundles.testing)
    testRuntimeOnly("com.h2database:h2")
}

tasks.withType<Test> { useJUnitPlatform() }

tasks.withType<JavaCompile> {
    options.compilerArgs.addAll(listOf(
        "-Amapstruct.defaultComponentModel=spring",
        "-Amapstruct.unmappedTargetPolicy=IGNORE"
    ))
}
