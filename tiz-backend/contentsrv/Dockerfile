# Build stage
ARG BUILD_IMAGE=gradle:9.3.1-jdk21

FROM ${BUILD_IMAGE} AS builder
WORKDIR /build

# Pass GITHUB_TOKEN for GitHub Packages authentication
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

# Configure Gradle
RUN mkdir -p ~/.gradle && \
    echo "org.gradle.jvmargs=-Xmx2g" >> ~/.gradle/gradle.properties

# Copy gradle wrapper and config first (for caching)
COPY gradle ./gradle
COPY gradle.properties settings.gradle.kts build.gradle.kts ./

# Copy source
COPY api ./api
COPY app ./app

# Build (repositories already configured in settings.gradle.kts)
RUN ./gradlew :app:bootJar --no-daemon --quiet

# Runtime stage
ARG BASE_IMAGE=ghcr.io/suj1e/tiz/base-jre:21
FROM ${BASE_IMAGE} AS runtime

ARG PORT
COPY --from=builder /build/app/build/libs/*.jar app.jar
EXPOSE ${PORT}
ENTRYPOINT ["java", "-jar", "app.jar"]
