# gatewaysrv - API Gateway

Tiz 平台的 API 网关服务，基于 Spring Cloud Gateway 实现。

## 技术栈

- Java 21
- Spring Boot 4.0.2
- Spring Cloud Gateway
- Spring Cloud Alibaba (Nacos)
- JWT 认证 (jjwt 0.13.0)

## 功能特性

- **路由转发**: 将请求转发到对应的微服务
- **JWT 认证**: 验证 JWT Token 并注入用户信息
- **白名单机制**: 支持配置不需要认证的路径
- **CORS 配置**: 支持跨域请求
- **全局异常处理**: 统一的错误响应格式
- **Nacos 集成**: 支持服务发现和配置中心

## 路由规则

| 路径 | 目标服务 | 端口 |
|------|----------|------|
| `/api/auth/v1/**` | authsrv | 8101 |
| `/api/chat/v1/**` | chatsrv | 8102 |
| `/api/content/v1/**` | contentsrv | 8103 |
| `/api/practice/v1/**` | practicesrv | 8104 |
| `/api/quiz/v1/**` | quizsrv | 8105 |
| `/api/user/v1/**` | usersrv | 8107 |

## 认证流程

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

### 请求头注入

网关验证 JWT 后，会向下游服务注入以下请求头：

- `X-User-Id`: 用户 ID
- `X-User-Email`: 用户邮箱

## 白名单路径

以下路径不需要 JWT 认证：

- `/api/auth/v1/login` - 登录
- `/api/auth/v1/register` - 注册
- `/api/auth/v1/refresh` - 刷新 Token
- `/actuator/**` - 健康检查端点

## 配置说明

### application.yaml

```yaml
server:
  port: 8080

spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://authsrv
          predicates:
            - Path=/api/auth/v1/**

jwt:
  secret: your-jwt-secret-key

gateway:
  whitelist:
    - /api/auth/v1/login
    - /api/auth/v1/register

cors:
  allowed-origins: http://localhost:5173
  allowed-methods: GET,POST,PUT,PATCH,DELETE,OPTIONS
  allowed-headers: Authorization,Content-Type,X-*
  allow-credentials: true
  max-age: 3600
```

## 运行

### 前置条件

1. 启动 Nacos (可选，用于服务发现)
2. 启动后端微服务

### 启动网关

```bash
# 构建
./gradlew build

# 运行
./gradlew bootRun

# 或者
java -jar build/libs/gatewaysrv-1.0.0-SNAPSHOT.jar
```

### 环境变量

```bash
# JWT 密钥
JWT_SECRET=your-secret-key

# Nacos 地址
NACOS_SERVER_ADDR=localhost:30006
```

## 健康检查

```bash
curl http://localhost:8080/actuator/health
```

## 错误响应格式

```json
{
  "error": {
    "type": "authentication_error",
    "code": "token_invalid",
    "message": "Invalid token signature"
  }
}
```

### 常见错误码

| code | message | HTTP |
|------|---------|------|
| token_missing | Authorization header is required | 401 |
| token_invalid | Invalid token signature | 401 |
| token_expired | Token has expired | 401 |
| internal_error | Internal server error | 500 |

## 项目结构

```
gatewaysrv/
├── build.gradle.kts
├── gradle/
│   └── libs.versions.toml
├── settings.gradle.kts
└── src/
    ├── main/
    │   ├── java/io/github/suj1e/gateway/
    │   │   ├── GatewayApplication.java
    │   │   ├── config/
    │   │   │   ├── CorsConfig.java
    │   │   │   ├── JwtProperties.java
    │   │   │   └── RouteConfig.java
    │   │   ├── filter/
    │   │   │   └── JwtAuthenticationFilter.java
    │   │   └── handler/
    │   │       ├── GatewayErrorResponse.java
    │   │       └── GlobalExceptionHandler.java
    │   └── resources/
    │       └── application.yaml
    └── test/
        ├── java/io/github/suj1e/gateway/
        │   └── filter/
        │       └── JwtAuthenticationFilterTest.java
        └── resources/
            └── application.yaml
```

## 测试

```bash
# 运行所有测试
./gradlew test

# 运行特定测试
./gradlew test --tests "JwtAuthenticationFilterTest"
```

## 依赖

- `io.github.suj1e:common:1.0.0-SNAPSHOT` - 公共模块
