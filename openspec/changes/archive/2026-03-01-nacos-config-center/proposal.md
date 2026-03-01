## Why

当前配置分散在各服务的 application.yaml 中，存在以下问题：
- 敏感信息（密码、密钥）硬编码在代码中
- 环境差异配置（DB/Redis 地址）需要手动修改
- 无法动态调整配置（如日志级别）
- 配置重复，难以维护

## What Changes

- 启用 Nacos Config 配置中心
- 建立多环境隔离：`dev` / `staging` / `prod` namespace
- 配置分层：环境变量（敏感信息）> Nacos Config > application.yaml
- 支持配置动态刷新（`@RefreshScope`）
- 创建共享配置 `common.yaml` 和服务专属配置

## Capabilities

### New Capabilities

- `config-center`: Nacos 配置中心，支持多环境隔离和动态刷新

### Modified Capabilities

None.

## Impact

**配置文件修改：**
- 所有 Java 服务的 `application.yaml` - 启用 config，移除硬编码配置
- `deploy/docker-compose.yml` - 添加 `NACOS_NAMESPACE` 环境变量

**Nacos 配置创建：**
- 每个环境（dev/staging/prod）创建：
  - `common.yaml` - 共享配置
  - `${service-name}.yaml` - 服务专属配置

**代码修改：**
- 需要动态刷新的 Bean 添加 `@RefreshScope`

**涉及服务：**
- gatewaysrv, authsrv, chatsrv, contentsrv, practicesrv, quizsrv, usersrv
