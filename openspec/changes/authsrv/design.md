# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring Data JPA + QueryDSL
- Spring Security
- JWT (jjwt 0.13.0)
- MySQL, Redis

## 2. 项目结构

```
authsrv/
├── build.gradle.kts
├── gradle/libs.versions.toml
└── src/main/java/io/github/suj1e/auth/
    ├── AuthApplication.java
    ├── controller/
    │   ├── AuthController.java      # 对外 API
    │   └── InternalUserController.java  # 内部 API
    ├── service/
    │   ├── AuthService.java
    │   ├── TokenService.java
    │   └── UserService.java
    ├── repository/
    │   ├── UserRepository.java
    │   └── RefreshTokenRepository.java
    ├── entity/
    │   ├── User.java
    │   └── RefreshToken.java
    ├── dto/
    │   ├── LoginRequest.java
    │   ├── RegisterRequest.java
    │   └── TokenResponse.java
    └── security/
        ├── JwtTokenProvider.java
        └── SecurityConfig.java
```

## 3. API 端点

### 对外 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/v1/register` | 注册 |
| POST | `/api/auth/v1/login` | 登录 |
| POST | `/api/auth/v1/logout` | 登出 |
| POST | `/api/auth/v1/refresh` | 刷新 Token |
| GET | `/api/auth/v1/me` | 获取当前用户 |

### 内部 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/internal/auth/v1/users/{id}` | 获取用户信息 |
| GET | `/internal/auth/v1/users/validate` | 验证 Token |

## 4. 数据库表

- `users` - 用户表
- `refresh_tokens` - 刷新令牌表

## 5. Token 流程

```
登录 → 返回 Access Token + Refresh Token
       ↓
Access Token 过期 → 用 Refresh Token 换取新的 Access Token
       ↓
Refresh Token 过期 → 需要重新登录
```

## 6. Redis 使用

- Token 黑名单 (登出时将 Refresh Token 加入黑名单)
