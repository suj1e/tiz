# Authsrv

> 企业级认证授权服务 - 基于 Spring Boot 的统一身份认证与 SSO 解决方案

[![Java](https://img.shields.io/badge/Java-21-orange)](https://openjdk.org/projects/jdk/21/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.7-green)](https://spring.io/projects/spring-boot)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 简介

**Authsrv** 是一个采用领域驱动设计（DDD）和分层架构构建的企业级认证授权服务，支持 **REST API** 和 **HTTP Interface（@HttpExchange）** 双协议调用。

### 核心特性

| 特性 | 描述 |
|------|------|
| 双协议支持 | REST API（前端/第三方）+ HTTP Interface（微服务间） |
| SDK 化设计 | `authsrv-api` 作为独立 SDK 供其他微服务依赖 |
| 类型安全 | @HttpExchange 提供编译时类型检查 |
| 多认证方式 | 本地密码、OAuth2/OIDC SSO |
| JWT 令牌 | Access Token (15min) + Refresh Token (7天) |
| 账户安全 | BCrypt 加密、失败锁定、密码策略 |
| 审计日志 | 登录/登出/注册/安全事件全记录 |
| 高可用 | 无状态设计、支持水平扩展 |

## 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                     authsrv-boot                             │
│  启动层 - 配置、组件扫描、基础设施初始化                         │
├─────────────────────────────────────────────────────────────┤
│                    authsrv-adapter                           │
│  适配器层 - REST API、HTTP Interface 服务实现                   │
│                                                             │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │   REST 控制器     │         │  HTTP Interface  │          │
│  │  /api/v1/auth/*  │         │  @HttpExchange   │          │
│  └──────────────────┘         └──────────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                    authsrv-core                              │
│  核心领域层 - 领域实体、领域服务、业务逻辑                       │
├─────────────────────────────────────────────────────────────┤
│                    authsrv-api                               │
│  API SDK 层 - 对外接口定义、DTO、@HttpExchange（供其他微服务依赖） │
└─────────────────────────────────────────────────────────────┘
```

### 依赖关系

```
Boot ──→ Adapter ──→ Core
  ↑                  ↑
  └── API ────────────┘
```

**依赖说明**：
- Adapter 依赖 Core（调用领域服务）
- API 依赖 Adapter（调用应用服务）
- Boot 依赖 Adapter（启动应用）

**外部微服务调用**：
```
其他微服务 ──→ @HttpExchange ──→ authsrv
     │
     └── 依赖 authsrv-api SDK
```

## 快速开始

### 环境要求

- **JDK**: 21+
- **Gradle**: 8.11+
- **PostgreSQL**: 16.x
- **Redis**: 7.x

### 本地运行

```bash
# 1. 启动依赖服务（使用 Docker Compose）
cd deploy/docker/dev && docker-compose up -d

# 2. 运行应用
./gradlew :authsrv-boot:bootRun --args='--spring.profiles.active=dev'

# 或使用启动脚本（推荐）
./start.sh dev

# 3. 访问服务
curl http://localhost:8080/authsrv/actuator/health
```

### Docker 部署

```bash
# 使用部署脚本（推荐）
./deploy/scripts/docker-deploy.sh -e dev -a up

# 或手动操作
cd deploy/docker/dev
docker-compose up -d
```

## API 文档

### REST API

```bash
# 用户登录
POST /authsrv/api/v1/auth/login
{
  "username": "john.doe",
  "password": "P@ssw0rd123"
}

# 用户注册
POST /authsrv/api/v1/auth/register
{
  "username": "john.doe",
  "email": "john@example.com",
  "password": "P@ssw0rd123"
}

# 刷新令牌
POST /authsrv/api/v1/auth/refresh
{
  "refreshToken": "uuid-token"
}
```

### HTTP Interface (@HttpExchange)

**其他微服务依赖 SDK**：

```kotlin
// build.gradle.kts
dependencies {
    implementation("com.nexora.auth:authsrv-api:1.0.0")
}
```

**调用示例**：

```java
// 1. 配置 HTTP Client Bean
@Configuration
public class AuthClientConfig {

    @Bean
    public AuthClient authClient() {
        RestClient restClient = RestClient.builder()
            .baseUrl("http://authsrv:8080")
            .build();

        HttpServiceProxyFactory factory = HttpServiceProxyFactory.builder()
            .clientAdapter(RestClientAdapter.create(restClient))
            .build();

        return factory.createClient(AuthClient.class);
    }
}

// 2. 使用类型安全的客户端
@Service
public class SomeService {

    @Autowired
    private AuthClient authClient;

    public void doSomething() {
        // 类型安全的调用，编译时检查
        UserResponse user = authClient.validateToken("Bearer " + token);

        // 批量获取用户
        List<UserResponse> users = userClient.getByIds(List.of(1L, 2L, 3L));
    }
}
```

**@HttpExchange 接口定义**（位于 authsrv-api）：

```java
@HttpExchange(url = "/api/v1/auth", accept = "application/json")
public interface AuthClient {

    @GetExchange("/validate")
    UserResponse validateToken(@RequestHeader("Authorization") String token);

    @PostExchange("/login")
    LoginResponse login(@RequestBody LoginRequest request);
}

@HttpExchange(url = "/api/v1/users", accept = "application/json")
public interface UserClient {

    @GetExchange("/{id}")
    UserResponse getById(@PathVariable("id") Long id);

    @GetExchange("/batch")
    List<UserResponse> getByIds(@RequestParam("ids") List<Long> ids);
}
```

详细 API 文档：[docs/api/auth-api.md](docs/api/auth-api.md)

## 配置

### 核心配置

```yaml
# Authentication configuration
auth:
  local:
    enabled: true
    # Password policy
    password-policy:
      min-length: 8
      require-uppercase: true
      require-lowercase: true
      require-digit: true
      require-special-char: true

    # Brute force protection
    brute-force-protection:
      enabled: true
      max-attempts: 5
      lockout-duration: 15m

  # Session management
  session:
    max-concurrent: 5
    store: redis

  # OAuth2 configuration
  oauth2:
    enabled: true
    # Allowed providers
    allowed-providers:
      - google
      - github
      - enterprise

  # CORS configuration
  cors:
    allowed-origins: ${ALLOWED_ORIGINS:http://localhost:3000,http://localhost:8080}
    allowed-methods: GET,POST,PUT,DELETE,OPTIONS,PATCH
    allow-credentials: true

# Nexora Spring Boot Starters configuration
nexora:
  security:
    jwt:
      enabled: true
      secret: ${JWT_SECRET}              # JWT 签名密钥（≥256位）
      expiration: 15m                    # 访问令牌有效期
      refresh-expiration: 7d             # 刷新令牌有效期
      issuer: authsrv
      audience: authsrv-clients
    jasypt:
      enabled: true
      password: ${JASYPT_ENCRYPTOR_PASSWORD}
  resilience:
    enabled: true
  file-storage:
    enabled: true
    type: local
    upload-path: ${UPLOAD_PATH:/data/uploads/authsrv}
    base-url: ${CDN_BASE_URL:http://localhost:8080/authsrv}
    max-file-size: 5MB
```

### 默认账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | SUPER_ADMIN |

## 项目结构

```
authsrv/
├── authsrv-api/          # API SDK 层（供外部微服务依赖）
│   └── src/main/java/com/nexora/auth/api/
│       ├── client/       # @HttpExchange 客户端接口
│       ├── dto/          # 共享 DTO
│       └── event/        # 领域事件定义
├── authsrv-core/         # 核心领域层
├── authsrv-adapter/      # 适配器层（REST + HTTP Interface）
│   └── src/main/java/com/nexora/auth/adapter/
│       ├── rest/         # REST 控制器
│       ├── service/      # 应用服务
│       ├── config/       # 配置类
│       ├── mapper/       # DTO 映射器
│       ├── exception/    # 业务异常
│       └── infra/        # 基础设施实现
├── authsrv-boot/         # 启动层
├── deploy/               # 部署相关
│   ├── docker/           # Docker Compose 配置
│   ├── k8s/              # Kubernetes 清单
│   └── scripts/          # 部署脚本
├── docs/                 # 文档
├── gradle/               # Gradle 配置
└── Dockerfile            # Docker 镜像构建
```

## 文档

- [架构概览](docs/architecture/overview.md)
- [领域模型](docs/architecture/domain-model.md)
- [安全架构](docs/architecture/security.md)
- [模块规范](docs/standards/module-specifications.md)
- [代码规范](docs/standards/code-conventions.md)
- [部署指南](docs/deployment/deployment.md)

## 技术栈

| 分类 | 技术 | 版本 |
|------|------|------|
| 语言 | Java | 21 LTS |
| 框架 | Spring Boot | 3.2.7 |
| 安全 | Spring Security | 6.2.x |
| HTTP Interface | @HttpExchange | Spring 6.1.x |
| 数据库 | PostgreSQL | 16.x |
| 缓存 | Redis | 7.x |
| 迁移 | Flyway | 11.3.4 |
| 监控 | Micrometer + OpenTelemetry | 1.58.0 |

### Nexora Spring Boot Starters

| Starter | 功能 |
|---------|------|
| nexora-spring-boot-starter-web | 统一响应格式 Result<T>、全局异常处理 |
| nexora-spring-boot-starter-security | JwtTokenProvider、Jasypt 配置加密 |
| nexora-spring-boot-starter-redis | Redis 缓存、Token 黑名单 |
| nexora-spring-boot-starter-kafka | 事件发布、DLQ 支持 |
| nexora-spring-boot-starter-resilience | 断路器、重试、超时 |
| nexora-spring-boot-starter-file-storage | 文件上传处理 |

## 开发

### 构建项目

```bash
# 清理构建
./gradlew clean build

# 运行测试
./gradlew test

# 生成 Docker 镜像
./gradlew jibDockerBuild
```

### 代码规范

- [代码规范](docs/standards/code-conventions.md)
- [模块规范](docs/standards/module-specifications.md)
- SonarQube 覆盖率 ≥ 80%

## 部署

### Docker Compose

```bash
# 开发环境
./deploy/scripts/docker-deploy.sh -e dev -a up

# 生产环境
./deploy/scripts/docker-deploy.sh -e prod -a up
```

### Kubernetes

```bash
# 开发环境
kubectl apply -k deploy/k8s/dev

# 生产环境
kubectl apply -k deploy/k8s/prod
```

详细部署文档：[deploy/README.md](deploy/README.md)

### 健康检查

```bash
# 存活探针
/actuator/health/liveness

# 就绪探针
/actuator/health/readiness

# Prometheus 指标
/actuator/prometheus
```

## 安全检查清单

部署前确认：

- [ ] 修改默认密码
- [ ] 使用强随机 JWT_SECRET（≥256位）
- [ ] 启用 HTTPS
- [ ] 配置 CORS 白名单
- [ ] 关闭 DEBUG 日志
- [ ] 依赖库无已知漏洞

## 协议对比

| 特性 | REST API | HTTP Interface |
|------|----------|----------------|
| 协议 | HTTP/HTTPS | HTTP/HTTPS |
| 数据格式 | JSON | JSON |
| 用途 | 前端、第三方调用 | 内部微服务调用 |
| 性能 | 中等 | 高（连接复用） |
| 易用性 | 高（通用标准） | 高（类型安全） |
| 服务发现 | K8s Service | K8s Service |

## 许可证

Copyright (c) 2025 Nexora

## 联系方式

- 项目主页: [https://codeup.aliyun.com/638a07cb09a6ccfdd6a1f934/authsrv](https://codeup.aliyun.com/638a07cb09a6ccfdd6a1f934/authsrv)
- 问题反馈: [Issues](https://codeup.aliyun.com/638a07cb09a6ccfdd6a1f934/authsrv/issues)
