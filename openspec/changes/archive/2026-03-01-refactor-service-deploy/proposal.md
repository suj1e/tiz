## Why

当前业务服务部署结构不合理：`deploy/docker-compose.yml` 集中管理所有服务，不利于独立部署；`nacos-config` 放在 `deploy/` 目录与代码分离。

## What Changes

- 删除 `deploy/docker-compose.yml`
- 移动 `deploy/nacos-config/` 到 `tiz-backend/nacos-config/`
- 为每个服务创建独立的 `docker-compose.yml`（8个服务）
- 删除空的 `deploy/` 目录

## Capabilities

### New Capabilities

- `independent-service-deploy`: 每个服务独立部署能力

### Modified Capabilities

无

## Impact

- 删除: `deploy/docker-compose.yml`, `deploy/` 目录
- 新增: `tiz-backend/*/docker-compose.yml` (8个服务)
- 移动: `deploy/nacos-config/` → `tiz-backend/nacos-config/`
