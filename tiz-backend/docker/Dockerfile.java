# Multi-stage Dockerfile for Tiz Java Services
# Usage: docker build --build-arg SERVICE_NAME=authsrv --build-arg PORT=8101 -f tiz-backend/docker/Dockerfile.java -t tiz/authsrv:latest .

ARG BUILD_IMAGE=gradle:8.12-jdk21
ARG RUNTIME_IMAGE=eclipse-temurin:21-jre-alpine

# ============================================================================
# Stage 1: Build
# ============================================================================
FROM ${BUILD_IMAGE} AS builder

# Build arguments
ARG SERVICE_NAME
ARG PORT=8080

# Set working directory
WORKDIR /build

# Copy Gradle wrapper and build files first for better caching
COPY tiz-backend/${SERVICE_NAME}/gradle/wrapper/ gradle/wrapper/
COPY tiz-backend/${SERVICE_NAME}/gradlew .
COPY tiz-backend/${SERVICE_NAME}/settings.gradle.kts .
COPY tiz-backend/${SERVICE_NAME}/build.gradle.kts .
COPY tiz-backend/${SERVICE_NAME}/api/ api/
COPY tiz-backend/${SERVICE_NAME}/app/ app/
COPY tiz-backend/common/ ../common/
COPY tiz-backend/gradle.properties ../
COPY tiz-backend/buildSrc/ ../buildSrc/

# Build and publish common module to Maven Local (needed by services)
RUN if [ -d "../common" ]; then \
    cd ../common && \
    gradle publishToMavenLocal --no-daemon --quiet; \
    fi

# Build the service bootJar
RUN gradle :app:bootJar --no-daemon --quiet

# ============================================================================
# Stage 2: Runtime
# ============================================================================
FROM ${RUNTIME_IMAGE} AS runtime

# Build arguments
ARG SERVICE_NAME
ARG PORT=8080
ARG USER=tiz

# Set labels
LABEL maintainer="tiz-team"
LABEL service="${SERVICE_NAME}"

# Install ca-certificates for HTTPS calls and curl for health check
RUN apk add --no-cache ca-certificates curl tzdata && \
    # Set timezone to UTC
    cp /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "UTC" > /etc/timezone && \
    # Create non-root user
    addgroup -S ${USER} && \
    adduser -S -G ${USER} ${USER}

# Set working directory
WORKDIR /app

# Copy the built JAR from builder
COPY --from=builder /build/app/build/libs/*.jar app.jar

# Change ownership to non-root user
RUN chown -R ${USER}:${USER} /app

# Switch to non-root user
USER ${USER}

# Expose service port
EXPOSE ${PORT}

# Health check using Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT}/actuator/health || exit 1

# JVM options for production
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:InitialRAMPercentage=50.0 \
               -XX:+UseG1GC \
               -XX:+UnlockExperimentalVMOptions \
               -XX:+UseStringDeduplication \
               -Djava.security.egd=file:/dev/./urandom \
               -Dspring.profiles.active=prod"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
