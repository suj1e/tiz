## Why

当前使用 Nacos 配置中心管理服务配置，但对于 7 个微服务的规模来说过于复杂：
- 配置需要在 git（nacos-config/）和 Nacos 之间同步，容易漂移
- 部署时需要额外执行 import.sh 步骤
- 大部分配置是静态的基础设施地址，不需要动态刷新

改用环境变量更简单、透明，符合 12-factor app 原则。

## What Changes

- **BREAKING** 移除 `nacos-config/` 目录及其所有内容
- **BREAKING** 禁用所有服务的 Nacos Config 功能（保留 Nacos Discovery）
- 每个服务的 `docker-compose.yml` 改为显式声明环境变量
- 每个服务创建 `.env.dev`、`.env.staging`、`.env.prod` 文件
- `application.yaml` 中移除敏感配置的默认值

## Capabilities

### New Capabilities

无

### Modified Capabilities

- `config-center`: 配置管理方式从 Nacos Config 改为环境变量
  - 移除"从 Nacos 加载配置"的需求
  - 移除"配置动态刷新"的需求（接受改配置需重启）
  - 保留"敏感信息通过环境变量注入"的需求

## Impact

**代码变更：**
- 7 个 Java 服务的 `application.yaml`
- 8 个服务的 `docker-compose.yml`
- 创建 ~24 个 `.env.*` 文件

**删除：**
- `tiz-backend/nacos-config/` 整个目录

**文档：**
- `CLAUDE.md` 中 nacos-config 相关说明
