# Nacos 配置指南

## 概述

GatewaySrv 使用 Nacos 作为**配置中心**和**服务发现中心**：

- **配置中心**：存储所有业务配置（路由、限流、熔断、Redis、日志等）
- **服务发现**：通过 `lb://` 协议路由到注册的服务

## 配置分层

| 位置 | 类型 | 内容 |
|------|------|------|
| `application.yml` | Bootstrap | 端口、Nacos 连接 |
| Nacos 配置中心 | 业务配置 | 路由、限流、熔断、Redis、日志、监控等 |

---

## 配置清单

### 需要在 Nacos 创建的配置

| Data ID | Group | 格式 | 说明 |
|---------|-------|------|------|
| `gatewaysrv-dev.yml` | DEFAULT_GROUP | YAML | 开发环境配置 |
| `gatewaysrv-test.yml` | DEFAULT_GROUP | YAML | 测试环境配置 |
| `gatewaysrv-prod.yml` | DEFAULT_GROUP | YAML | 生产环境配置 |

---

## 配置内容模板

**完整的配置模板文件**: `docs/nacos-config-template.yml`

请直接复制模板文件内容到 Nacos 控制台。

### 配置键迁移说明（Spring Boot 3.x）

Spring Boot 3.x 对部分配置键进行了调整，使用新路径可避免启动警告：

| 旧配置键 | 新配置键 |
|---------|---------|
| `management.metrics.export.prometheus.*` | `management.prometheus.metrics.export.*` |
| `spring.cloud.gateway.httpclient.*` | `spring.cloud.gateway.server.webflux.httpclient.*` |
| `spring.cloud.gateway.routes` | `spring.cloud.gateway.server.webflux.routes` |

### 快速配置步骤

1. 打开 Nacos 控制台
2. 进入 **配置管理** → **配置列表**
3. 选择对应的 **命名空间**（dev/test/prod）
4. 点击 **+** 创建配置：
   - **Data ID**: `gatewaysrv-dev.yml`（或其他环境）
   - **Group**: `DEFAULT_GROUP`
   - **配置格式**: YAML
   - **配置内容**: 复制 `docs/nacos-config-template.yml` 的内容

---

### 环境差异说明

| 配置项 | 开发环境 | 生产环境 |
|--------|----------|----------|
| `environment` 标签 | `${spring.profiles.active}` | 自动填充 |
| OTLP endpoint | `${OTLP_ENDPOINT}` | 实际 Tempo 服务地址 |
| Redis host | `${REDIS_HOST}` | 实际 Redis 地址 |
| 追踪采样率 | 0.1 | 0.05-0.1 |
| 熔断等待时间 | 30s | 60s |
| 限流阈值 | 较宽松 | 较严格 |

---

## 敏感信息处理

### 需要使用环境变量占位符的配置项

- `nexora.security.jwt.secret` - JWT 签名密钥
- `spring.data.redis.password` - Redis 密码
- `spring.cloud.nacos.password` - Nacos 认证密码（如需要）

### 使用方法

在 Nacos 配置中使用 `${变量名}` 占位符：

```yaml
# Nacos 配置
nexora:
  security:
    jwt:
      secret: ${JWT_SECRET}

spring:
  data:
    redis:
      password: ${REDIS_PASSWORD}
```

启动时通过环境变量传入实际值：

```bash
# 本地开发 (.env.local)
JWT_SECRET=your-actual-secret-key
REDIS_PASSWORD=your-redis-password

# Docker 运行
docker run -e JWT_SECRET=xxx -e REDIS_PASSWORD=yyy ...

# Kubernetes (通过 Secret)
env:
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: gatewaysrv-secret
        key: jwt-secret
```

### 生成密钥

```bash
# 生成 JWT 密钥
openssl rand -base64 64

# 生成 Redis 密码
openssl rand -base64 32
```

---

## Nacos 控制台操作

### 1. 登录 Nacos

```
URL: http://your-nacos-host:8848/nacos
用户名: nacos
密码: nacos
```

### 2. 创建配置

1. 点击左侧 **「配置管理」** → **「配置列表」**
2. 点击右上角 **「+」** 创建配置
3. 填写配置信息：

```
Data ID: gatewaysrv-dev.yml
Group: DEFAULT_GROUP
配置格式: YAML
配置内容: [粘贴上面的模板内容]
```

4. 点击 **「发布」**

### 3. 编辑配置

1. 在配置列表找到目标配置
2. 点击 **「编辑」**
3. 修改内容
4. 点击 **「发布」**
5. 应用会自动刷新配置（无需重启）

### 4. 历史版本

- Nacos 会保存配置的历史版本
- 可在 **「历史版本」** 标签页查看和回滚

---

## 配置验证

### 检查配置是否加载

```bash
# 查看应用日志
tail -f logs/gateway.log | grep "nacos"

# 应该看到类似输出：
# Fetch config from nacos successfully, gatewaysrv-dev.yml
```

### 检查路由是否生效

```bash
# 查看所有路由
curl http://localhost:40004/actuator/gateway/routes

# 应该看到配置的路由列表
```

---

## 常见问题

### 1. 配置加载失败

**症状**：应用启动报错 `Could not resolve placeholder`

**排查**：
- 检查 `NACOS_HOST` 和 `NACOS_PORT` 是否正确
- 检查 Data ID 是否存在：`gatewaysrv-{profile}.yml`
- 检查 Group 是否匹配：`DEFAULT_GROUP`
- 检查 Nacos 配置格式是否正确（YAML）

### 2. 环境变量未设置

**症状**：应用启动报错 `Could not resolve placeholder 'JWT_SECRET'`

**排查**：
- 检查环境变量是否设置：`echo $JWT_SECRET`
- 检查 Nacos 配置中占位符格式：`${JWT_SECRET}`
- 确认环境变量在启动前已加载

### 3. 配置不刷新

**症状**：修改 Nacos 配置后应用未生效

**排查**：
- 检查 `spring.cloud.nacos.config.refresh-enabled: true`
- 查看日志是否有配置刷新事件
- 确认配置类上有 `@RefreshScope` 注解（如需要）

---

## 配置检查清单

发布前检查：

- [ ] Data ID 命名正确：`gatewaysrv-{profile}.yml`
- [ ] Group 设置正确：`DEFAULT_GROUP`
- [ ] 配置格式正确：YAML
- [ ] 敏感信息已使用环境变量占位符（${VAR_NAME}）
- [ ] 路由配置的服务名称正确
- [ ] 限流、熔断参数合理
- [ ] 必需的环境变量已配置

---

## 附录：快速生成密钥

```bash
# 生成 JWT 密钥（推荐 64 字符）
openssl rand -base64 64

# 生成 Redis 密码（推荐 32 字符）
openssl rand -base64 32
```

---

*文档版本：v1.0*
*创建日期：2026-02-03*
