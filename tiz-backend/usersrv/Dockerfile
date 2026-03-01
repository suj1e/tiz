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
FROM eclipse-temurin:21-jre-alpine AS runtime

LABEL maintainer="tiz-team"

# Install runtime dependencies and create non-root user
RUN apk add --no-cache ca-certificates curl tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    addgroup -S tiz && \
    adduser -S -G tiz tiz

WORKDIR /app

ARG PORT
COPY --from=builder --chown=tiz:tiz /build/app/build/libs/*.jar app.jar

# Switch to non-root user
USER tiz

EXPOSE ${PORT}
ENTRYPOINT ["java", "-jar", "app.jar"]
