# 修复 Java 微服务 Dockerfile

## 概述

修复 Java 微服务 Dockerfile 中的 Gradle 构建问题，并优化 JVM 参数。

## 问题分析

### 当前问题

1. **Gradle 构建失败**
   - Dockerfile 使用 `./gradlew` 但没有复制 `gradlew` 脚本
   - 导致构建失败

2. **JVM 参数不够优化**
   - 没有容器感知参数
   - 内存设置硬编码

### 解决方案

1. **使用 `gradle` 命令替代 `gradlew`**
   - `gradle:9.3.1-jdk21` 镜像已包含正确版本的 Gradle
   - 直接使用 `gradle` 命令更简洁

2. **优化 JVM 参数**
   - 添加 `-XX:+UseContainerSupport` 容器感知
   - 使用环境变量配置内存，支持运行时覆盖

## 变更范围

修改 7 个 Java 服务的 Dockerfile

## 新 Dockerfile 模板

```dockerfile
# Build stage
FROM gradle:9.3.1-jdk21 AS builder
WORKDIR /build

# Maven credentials for private repository
ARG ALIYUN_MAVEN_USERNAME
ARG ALIYUN_MAVEN_PASSWORD
ENV ALIYUN_MAVEN_USERNAME=${ALIYUN_MAVEN_USERNAME}
ENV ALIYUN_MAVEN_PASSWORD=${ALIYUN_MAVEN_PASSWORD}

# Configure Gradle
RUN mkdir -p ~/.gradle && \
    echo "org.gradle.jvmargs=-Xmx2g" >> ~/.gradle/gradle.properties

# Copy gradle wrapper and config first (for caching)
COPY gradle ./gradle
COPY gradle.properties settings.gradle.kts build.gradle.kts ./

# Copy source
COPY api ./api
COPY app ./app

# Build using gradle (not gradlew - image has gradle installed)
RUN gradle :app:bootJar --no-daemon --quiet

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
ENV PORT=${PORT}
ENV JAVA_OPTS="-XX:+UseContainerSupport -Xms256m -Xmx512m"

COPY --from=builder --chown=tiz:tiz /build/app/build/libs/*.jar app.jar

# Switch to non-root user
USER tiz

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT}/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

## 改进点

| 改进 | 说明 |
|------|------|
| `gradle` 替代 `./gradlew` | 使用镜像自带的 gradle |
| `UseContainerSupport` | JVM 容器感知 |
| `JAVA_OPTS` 环境变量 | 支持运行时覆盖 |
| `HEALTHCHECK` | 容器健康检查 |
| 移除 `GITHUB_TOKEN` | 不再需要 |
