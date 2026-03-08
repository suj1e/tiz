## Why

每个微服务将由独立团队维护，但当前存在以下问题：

1. **文档缺失**: 新团队接手服务时，不知道服务做什么、需要哪些环境变量、如何本地运行
2. **依赖版本硬编码**: 内部 API (`common`, `content-api` 等) 和部分库版本硬编码在多个文件中
3. **配置不一致**: `application.yaml` 环境变量配置方式不统一

这会增加交接成本、协调成本和出错概率。

## What Changes

### 文档与配置

- 为每个服务添加 `README.md`，说明服务职责、依赖、运行方式
- 为每个服务添加 `.env.example`，列出所有需要的环境变量
- 统一 `application.yaml` 中环境变量的配置模式（使用 `${VAR:-default}` 格式）
- 在 README 中文档化服务间的依赖关系

### 依赖管理

- 将内部 API 依赖 (`common`, `content-api`, `llm-api`, `auth-api`, `user-api`) 加入 version catalog
- 补充缺失的依赖定义 (`spring-boot-starter-webflux`, `spring-cloud-loadbalancer`, `spring-kafka`)
- 统一使用 version catalog，移除硬编码版本号

## Capabilities

### New Capabilities

- `service-readme`: 每个服务有标准化的 README 文档，包含职责说明、依赖服务、环境变量、运行命令
- `service-env-template`: 每个服务有 `.env.example` 模板，列出所有必需和可选的环境变量
- `version-catalog-internal`: 内部 API 依赖纳入 version catalog 统一管理

### Modified Capabilities

无（这是新增的开发体验改进，不改变现有功能需求）

## Impact

**涉及服务** (8个):
- auth-service
- chat-service
- content-service
- practice-service
- quiz-service
- user-service
- gateway
- llm-service (已有 README 和 .env.example，可能需要更新)

**新增文件**:
- 每个服务的 `README.md`
- 每个服务的 `.env.example`

**修改文件**:
- 每个服务的 `gradle/libs.versions.toml` - 添加内部 API 和缺失依赖
- 每个服务的 `app/build.gradle.kts` - 使用 version catalog 替代硬编码
- 部分服务的 `application.yaml` - 统一环境变量配置模式
