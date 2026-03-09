# Build stage
FROM gradle:9.3.1-jdk21 AS builder
WORKDIR /build

ARG ALIYUN_MAVEN_USERNAME
ARG ALIYUN_MAVEN_PASSWORD
ENV ALIYUN_MAVEN_USERNAME=${ALIYUN_MAVEN_USERNAME}
ENV ALIYUN_MAVEN_PASSWORD=${ALIYUN_MAVEN_PASSWORD}

RUN mkdir -p ~/.gradle && \
    echo "org.gradle.jvmargs=-Xmx2g" >> ~/.gradle/gradle.properties

COPY gradle ./gradle
COPY gradle.properties settings.gradle.kts build.gradle.kts ./
COPY api ./api
COPY app ./app

RUN gradle :app:bootJar --no-daemon --quiet

FROM eclipse-temurin:21-jre-alpine AS runtime

LABEL maintainer="tiz-team"

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories && apk add --no-cache ca-certificates curl tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    addgroup -S tiz && \
    adduser -S -G tiz tiz

WORKDIR /app

ARG PORT=8104
ENV PORT=${PORT}
ENV JAVA_OPTS="-XX:+UseContainerSupport -Xms256m -Xmx512m"

COPY --from=builder --chown=tiz:tiz /build/app/build/libs/*.jar app.jar

USER tiz

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT}/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
