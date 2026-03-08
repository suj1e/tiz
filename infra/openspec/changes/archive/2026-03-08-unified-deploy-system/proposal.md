## Why

当前部署配置分散在各服务目录中，缺乏统一管理。前端 desktop/mobile 分开构建导致镜像冗余，且没有统一的部署脚本来管理多环境部署和运维操作。需要建立一套标准化的部署体系，简化部署流程，提高运维效率。

## What Changes

- 新建 `deploy/` 目录，统一管理 staging 和 prod 环境的部署配置
- 合并前端 desktop/mobile 为单个容器，通过 nginx UA 分流
- 创建统一 `deploy.sh` 脚本，支持完整的部署生命周期管理
- 每个 `docker-compose.yml` 包含所有应用服务（frontend + 8 backend services）

## Capabilities

### New Capabilities

- `unified-deploy`: 统一部署系统，包含多环境配置、统一脚本和前端合并部署

### Modified Capabilities

- `frontend-build`: 修改前端构建流程，从双容器改为单容器 UA 分流模式

## Impact

- **新增目录**: `deploy/staging/`, `deploy/prod/`, `deploy/scripts/`
- **修改文件**: `tiz-web/Dockerfile` (合并 desktop/mobile)
- **新增文件**: `deploy/deploy.sh`, `deploy/staging/docker-compose.yml`, `deploy/prod/docker-compose.yml`
- **依赖**: 依赖 `infra/` 目录提供的基础设施服务（mysql, redis, kafka 等）
