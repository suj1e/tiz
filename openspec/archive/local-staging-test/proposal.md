## Why

当前代码库存在两套服务目录命名（`xxx-service` 和 `xxxsrv`），造成混乱。需要统一命名规范，并验证本地连接 staging 基础设施的完整启动流程，为后续镜像构建和部署做准备。

## What Changes

- **BREAKING**: 移除所有 `xxxsrv` 目录（authsrv, chatsrv, contentsrv, gatewaysrv, llmsrv, practicesrv, quizsrv, usersrv）
- 为所有服务创建 `.env.staging` 配置文件，配置连接本地 staging 基础设施端口
- 验证后端服务按依赖顺序启动
- 验证前端连接本地 gateway

## Capabilities

### New Capabilities

None - 这是基础设施清理和测试任务，不涉及新功能。

### Modified Capabilities

None - 不修改现有功能需求。

## Impact

**代码清理：**
- 删除 8 个旧目录：authsrv, chatsrv, contentsrv, gatewaysrv, llmsrv, practicesrv, quizsrv, usersrv

**配置新增：**
- `auth-service/.env.staging`
- `chat-service/.env.staging`
- `content-service/.env.staging`
- `practice-service/.env.staging`
- `quiz-service/.env.staging`
- `user-service/.env.staging`
- `gateway/.env.staging`
- `llm-service/.env.staging`

**本地连接地址（staging 基础设施）：**
- MySQL: `localhost:30001`
- Redis: `localhost:30002`
- Kafka: `localhost:30009`
- Nacos: `localhost:30848`
