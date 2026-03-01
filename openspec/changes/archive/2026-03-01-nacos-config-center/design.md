## Context

当前配置管理方式：
- 所有配置硬编码在 `application.yaml`
- 敏感信息（DB 密码、JWT Secret）暴露在代码中
- 环境差异通过 docker-compose 环境变量覆盖，但覆盖不完整

目标：使用 Nacos Config 实现配置集中管理和多环境隔离。

## Goals / Non-Goals

**Goals:**
- 启用 Nacos Config，配置集中管理
- 多环境隔离：dev / staging / prod
- 敏感信息通过环境变量注入，不进入配置中心
- 支持动态刷新（日志级别、功能开关等）

**Non-Goals:**
- 不修改 Nacos 服务器配置
- 不实现配置加密（敏感信息走环境变量）
- 不迁移 llmsrv（Python 服务）

## Decisions

### 1. Namespace 命名

**决定**: `dev` / `staging` / `prod`

### 2. 配置文件结构

```
Nacos Config (namespace: prod)
├── common.yaml          # 所有服务共享
│   ├── spring.datasource.url
│   ├── spring.data.redis.host
│   └── kafka.bootstrap-servers
│
├── authsrv.yaml         # 服务专属
├── chatsrv.yaml
├── contentsrv.yaml
├── practicesrv.yaml
├── quizsrv.yaml
├── usersrv.yaml
└── gatewaysrv.yaml
```

### 3. 配置优先级

```
环境变量 > Nacos Config (${service}.yaml) > Nacos Config (common.yaml) > application.yaml
```

### 4. 敏感信息处理

| 配置项 | 存储位置 | 原因 |
|-------|---------|------|
| `spring.datasource.password` | 环境变量 | 敏感 |
| `spring.data.redis.password` | 环境变量 | 敏感 |
| `jwt.secret` | 环境变量 | 敏感 |
| `openai.api-key` | 环境变量 | 敏感 |
| `spring.datasource.url` | Nacos common.yaml | 非敏感，环境差异 |
| `logging.level.*` | Nacos ${service}.yaml | 需动态调整 |

### 5. 动态刷新

**启用方式**: `spring.cloud.nacos.config.refresh-enabled: true`

**需要动态刷新的配置**:
- 日志级别
- 功能开关（如有）

**不需要动态刷新的配置**:
- 数据库连接池（重启生效）
- 服务端口

### 6. application.yaml 改造

改造后只保留：
- `server.port` - 服务端口
- `spring.application.name` - 服务名
- `spring.cloud.nacos.*` - Nacos 连接配置（使用 `${}` 占位符）
- 本地开发默认值

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| Nacos 不可用导致服务启动失败 | 保留 `application.yaml` 中的本地默认值 |
| 配置刷新导致连接池重建 | 只对需要动态刷新的 Bean 加 `@RefreshScope` |
| 配置误操作 | Nacos 有配置历史回滚功能 |

## Migration Plan

1. 创建 Nacos namespaces（dev/staging/prod）
2. 创建 common.yaml 和各服务配置文件
3. 修改 application.yaml，启用 config
4. 移除硬编码配置
5. 更新 docker-compose.yml 添加 NACOS_NAMESPACE
6. 验证各环境
