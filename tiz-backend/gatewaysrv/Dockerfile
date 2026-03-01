# Build stage for gatewaysrv (no api/app subproject structure)
ARG BUILD_IMAGE=gradle:9.3.1-jdk21

FROM ${BUILD_IMAGE} AS builder
WORKDIR /build
ARG GITHUB_TOKEN

# Configure GitHub Packages authentication
RUN mkdir -p ~/.gradle && \
    echo "org.gradle.jvmargs=-Xmx2g" >> ~/.gradle/gradle.properties

# Copy gradle wrapper and config first (for caching)
COPY gradle ./gradle
COPY gradle.properties settings.gradle.kts build.gradle.kts ./

# Configure GitHub Packages in project
RUN echo 'repositories { mavenLocal(); mavenCentral(); maven { name = "GitHubPackages"; url = uri("https://maven.pkg.github.com/suj1e/tiz"); credentials { username = "token"; password = System.getenv("GITHUB_TOKEN") } } }' >> build.gradle.kts

# Copy source (gatewaysrv has src directly, not api/app)
COPY src ./src

# Build (no :app prefix for gatewaysrv)
RUN ./gradlew bootJar --no-daemon --quiet

# Runtime stage
ARG BASE_IMAGE=ghcr.io/suj1e/tiz/base-jre:21
FROM ${BASE_IMAGE} AS runtime

COPY --from=builder /build/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
