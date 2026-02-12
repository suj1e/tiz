# GatewaySrv 配置规范

本文档描述 GatewaySrv 的完整配置规范和配置分层架构。

---

## 配置分层架构

GatewaySrv 采用两层配置设计，实现配置外部化和敏感数据隔离：

```
┌─────────────────────────────────────────────────────────────────┐
│                        配置分层                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │ application.yml │───▶│     Nacos       │───▶│  Env Vars   │ │
│  │   (Bootstrap)   │    │  (Business)     │    │  (Secrets)  │ │
│  │                 │    │                 │    │             │ │
│  │ • 端口          │    │ • 路由配置      │    │ • JWT_SECRET│ │
│  │ • Nacos 连接    │    │ • 限流规则      │    │ • REDIS_... │ │
│  │ • 基础设施      │    │ • 熔断策略      │    │             │ │
│  └─────────────────┘    │ • Redis 配置    │    └─────────────┘ │
│                         │ • 日志级别      │                    │
│                         │ • 监控追踪      │                    │
│                         └─────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 设计原则

| 层级 | 存储位置 | 类型 | 变更频率 | 示例 |
|------|----------|------|----------|------|
| **Bootstrap** | `application.yml` | 不可变 | 极少 | 端口、Nacos 地址 |
| **Business** | Nacos Config Center | 动态 | 较高 | 路由规则、限流阈值 |
| **Secrets** | Environment Variables | 注入 | 部署时 | JWT 密钥、数据库密码 |

---

## Bootstrap 配置 (application.yml)

**位置**: `src/main/resources/application.yml`

**特点**:
- 应用启动时加载，不可热更新
- 仅包含基础设施配置
- 不包含业务逻辑配置

```yaml
server:
  port: 40004                    # 服务端口
  shutdown: graceful              # 优雅关闭

management:
  server:
    port: 40005                   # 管理端口
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: 'health,info,prometheus,circuitbreakers,ratelimiters'

spring:
  application:
    name: gatewaysrv
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  config:
    import: optional:nacos:${spring.application.name}-${spring.profiles.active}.yml
  cloud:
    nacos:
      server-addr: ${NACOS_HOST:nexora-nacos}:${NACOS_PORT:8848}
      config:
        enabled: ${NACOS_CONFIG_ENABLED:true}
        refresh-enabled: true
      discovery:
        enabled: ${NACOS_DISCOVERY_ENABLED:true}
```

---

## Nacos 业务配置

### Data ID 命名规范

```
gatewaysrv-{profile}.yml
```

| 环境 | Data ID | Group |
|------|---------|-------|
| 开发 | `gatewaysrv-dev.yml` | `DEFAULT_GROUP` |
| 测试 | `gatewaysrv-test.yml` | `DEFAULT_GROUP` |
| 生产 | `gatewaysrv-prod.yml` | `DEFAULT_GROUP` |

### 配置项结构

```yaml
# ========== Server 配置 ==========
server:
  http2:
    enabled: true
  compression:
    enabled: true

# ========== Gateway 路由配置 ==========
spring:
  cloud:
    gateway:
      httpclient:
        connect-timeout: 5000
        response-timeout: 30s
      routes:
        - id: authsrv
          uri: lb://authsrv           # 使用 Nacos 服务发现
          predicates:
            - Path=/api/v1/auth/**
          filters:
            - StripPrefix=2

  # ========== Redis 配置 ==========
  data:
    redis:
      host: nexora-redis
      port: 6379
      database: 0

# ========== Resilience4j 配置 ==========
resilience4j:
  circuitbreaker:
    instances:
      authsrv:
        failure-rate-threshold: 50
  ratelimiter:
    instances:
      auth-endpoint:
        limit-for-period: 10

# ========== 安全配置 ==========
nexora:
  security:
    jwt:
      secret: ${JWT_SECRET}          # 使用环境变量占位符
```

---

## 敏感数据处理

### 环境变量占位符

敏感配置使用 `${变量名}` 占位符，实际值通过环境变量注入：

| 配置项 | 占位符 | 环境变量 |
|--------|--------|----------|
| JWT 密钥 | `${JWT_SECRET}` | `JWT_SECRET` |
| Redis 密码 | `${REDIS_PASSWORD}` | `REDIS_PASSWORD` |
| Nacos 密码 | `${NACOS_PASSWORD}` | `NACOS_PASSWORD` |

### 示例

**Nacos 配置**:
```yaml
nexora:
  security:
    jwt:
      secret: ${JWT_SECRET}
```

**环境变量**:
```bash
# .env.local (本地开发)
JWT_SECRET=your-actual-secret-key-here

# Docker
docker run -e JWT_SECRET=xxx ...

# Kubernetes Secret
env:
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: gatewaysrv-secret
        key: jwt-secret
```

### 生成密钥

```bash
# JWT 密钥 (推荐 64 字符)
openssl rand -base64 64

# Redis 密码 (推荐 32 字符)
openssl rand -base64 32
```

---

## 配置验证

### 检查配置加载

```bash
# 查看日志确认 Nacos 配置加载成功
tail -f logs/gateway.log | grep "nacos"

# 应该看到:
# Fetch config from nacos successfully, gatewaysrv-dev.yml
```

### 检查路由生效

```bash
# 查看所有路由
curl http://localhost:40004/actuator/gateway/routes | jq
```

### 检查环境变量注入

```bash
# 查看生效的配置
curl http://localhost:40004/actuator/env | jq '.propertySources[]'
```

---

## 常见问题

### 配置加载失败

**症状**: 启动报错 `Could not resolve placeholder`

**检查清单**:
- [ ] Nacos 服务可访问
- [ ] Data ID 存在且格式正确 (`gatewaysrv-{profile}.yml`)
- [ ] Group 匹配 (`DEFAULT_GROUP`)
- [ ] 环境变量已设置

### 敏感数据未注入

**症状**: `Could not resolve placeholder 'JWT_SECRET'`

**检查清单**:
- [ ] `.env.local` 文件存在且格式正确
- [ ] 环境变量在启动前已加载
- [ ] Nacos 配置中占位符格式为 `${JWT_SECRET}`

---

## 配置检查清单

发布前检查：

- [ ] Data ID 命名正确: `gatewaysrv-{profile}.yml`
- [ ] Group 设置正确: `DEFAULT_GROUP`
- [ ] 敏感信息使用 `${VAR_NAME}` 占位符
- [ ] 路由服务名称与 Nacos 注册名一致
- [ ] 限流、熔断参数符合环境要求
- [ ] 必需环境变量已配置

---

*最后更新: 2026-02-04*
