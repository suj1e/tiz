## Why

当前微服务的发布和部署依赖 GitHub Actions，本地开发时无法方便地执行相同操作。每个服务需要独立的管理脚本，方便各团队独立维护和操作。

## What Changes

- 为每个微服务添加 `svc.sh` 脚本
- 支持 publish（Maven 发布）、image（Docker 构建）、build、run、test 等命令
- 添加版本管理、运维、依赖检查等进阶功能
- 添加 `publish-all.sh` 批量发布脚本

## Capabilities

### New Capabilities

- `service-cli`: 标准化的服务命令行工具，提供统一的服务管理接口

### Modified Capabilities

无

## Impact

**新增文件 (11个)**:
- `tiz-backend/auth-service/svc.sh`
- `tiz-backend/chat-service/svc.sh`
- `tiz-backend/content-service/svc.sh`
- `tiz-backend/practice-service/svc.sh`
- `tiz-backend/quiz-service/svc.sh`
- `tiz-backend/user-service/svc.sh`
- `tiz-backend/gateway/svc.sh`
- `tiz-backend/llm-service/svc.sh`
- `tiz-backend/llm-api/svc.sh`
- `tiz-backend/common/svc.sh`
- `tiz-backend/publish-all.sh`

**影响的团队**:
- 各服务团队可独立使用和维护自己的脚本
