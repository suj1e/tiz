# 设计文档

## 1. 技术栈

- Java 21
- Spring Boot 4.0.2
- Spring Cloud Gateway
- Spring Cloud Alibaba 2025.1.0.0
- JWT (jjwt 0.13.0)

## 2. 项目结构

```
gatewaysrv/
├── build.gradle.kts
├── gradle/
│   └── libs.versions.toml
└── src/main/java/io/github/suj1e/gateway/
    ├── GatewayApplication.java
    ├── config/
    │   ├── RouteConfig.java
    │   ├── SecurityConfig.java
    │   └── CorsConfig.java
    ├── filter/
    │   ├── JwtAuthenticationFilter.java
    │   └── RequestLoggingFilter.java
    ├── handler/
    │   └── GlobalExceptionHandler.java
    └── util/
        └── JwtUtils.java
```

## 3. 路由配置

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://authsrv
          predicates:
            - Path=/api/auth/v1/**
          filters:
            - StripPrefix=0

        - id: user-service
          uri: lb://usersrv
          predicates:
            - Path=/api/user/v1/**

        - id: chat-service
          uri: lb://chatsrv
          predicates:
            - Path=/api/chat/v1/**

        - id: content-service
          uri: lb://contentsrv
          predicates:
            - Path=/api/content/v1/**

        - id: practice-service
          uri: lb://practicesrv
          predicates:
            - Path=/api/practice/v1/**

        - id: quiz-service
          uri: lb://quizsrv
          predicates:
            - Path=/api/quiz/v1/**
```

## 4. JWT 认证流程

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────▶│ Gateway  │────▶│ Service  │
└──────────┘     └──────────┘     └──────────┘
                      │
                      ▼
               ┌──────────────┐
               │ JWT Filter   │
               │ 1. 提取 Token │
               │ 2. 验证签名   │
               │ 3. 检查过期   │
               │ 4. 注入用户ID │
               └──────────────┘
```

## 5. 白名单路径

```java
public static final List<String> WHITE_LIST = List.of(
    "/api/auth/v1/login",
    "/api/auth/v1/register",
    "/api/auth/v1/refresh",
    "/actuator/**"
);
```

## 6. 响应格式

错误响应统一使用 common 模块的 `ApiResponse<ErrorBody>` 格式。
