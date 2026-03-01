## Why

当前基础设施配置只有一套 docker-compose.yml，无法区分 dev/staging/prod 环境。不同环境需要不同的资源配置、端口策略和数据持久化方案。

## What Changes

- 创建 `infra/envs/` 目录结构，按环境区分配置
- 为 dev/staging/prod 分别创建独立的 docker-compose 文件
- 创建统一的管理脚本支持环境切换
- dev 环境保持当前配置（Docker 命名卷、较低资源配置）
- staging 环境使用宿主机目录挂载、中等资源配置
- prod 环境使用宿主机目录挂载、高资源配置、最小化端口暴露

## Capabilities

### New Capabilities

- `multi-env-infra`: 多环境基础设施配置管理能力

### Modified Capabilities

无

## Impact

- 新增目录：`infra/envs/dev/`, `infra/envs/staging/`, `infra/envs/prod/`
- 修改文件：`infra/infra.sh` 支持环境参数
- 现有 `infra/docker-compose.yml` 迁移到 `infra/envs/dev/`
