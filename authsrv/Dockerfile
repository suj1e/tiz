# ============================================
# Stage 1: Build (优化缓存层)
# ============================================
FROM docker.1ms.run/gradle:9.0-jdk21 AS builder

# 构建参数：Maven 私有仓库认证（流水线传入）
ARG MAVEN_USERNAME
ARG MAVEN_PASSWORD
ARG MAVEN_REPO_URL

# 转为环境变量，供 Gradle 使用
ENV MAVEN_USERNAME=${MAVEN_USERNAME}
ENV MAVEN_PASSWORD=${MAVEN_PASSWORD}
ENV MAVEN_REPO_URL=${MAVEN_REPO_URL}

WORKDIR /app

# 1. 先复制依赖声明文件 (这层会被缓存)
COPY --chown=gradle:gradle build.gradle.kts settings.gradle.kts gradle.properties ./
COPY --chown=gradle:gradle gradle ./gradle

# 2. 下载依赖 (利用缓存)
RUN gradle dependencies --no-daemon || true

# 3. 复制源码
COPY --chown=gradle:gradle src ./src

# 4. 构建
RUN gradle bootJar --no-daemon -x test --parallel

# ============================================
# Stage 2: Runtime (Dragonwell JDK)
# ============================================
FROM dragonwell-registry.cn-hangzhou.cr.aliyuncs.com/dragonwell/dragonwell:21

# 安装 curl（健康检查用）并创建非 root 用户
RUN yum install -y curl && yum clean all && \
    groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# 从构建阶段复制 JAR
COPY --from=builder /app/build/libs/*.jar app.jar

# 创建日志目录并授权
RUN mkdir -p /app/logs /home/appuser/logs && \
    chown -R appuser:appgroup /app /home/appuser

# JVM 容器优化参数
ENV JAVA_OPTS="-XX:+UseG1GC \
               -XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:MinRAMPercentage=50.0 \
               -XX:+UseStringDeduplication \
               -XX:+ExitOnOutOfMemoryError \
               -XX:MaxGCPauseMillis=200 \
               -Djava.security.egd=file:/dev/./urandom \
               -Duser.timezone=Asia/Shanghai \
               -Dfile.encoding=UTF-8"

# 健康检查（改用 curl）
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:40007/actuator/health || exit 1

# 切换到非 root 用户
USER appuser

EXPOSE 40006 40007

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
