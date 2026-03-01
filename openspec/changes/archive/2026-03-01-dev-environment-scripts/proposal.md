## Why

当前 infra 脚本存在问题：
- `start-lite.sh` 引用不存在的 `docker-compose-lite.yml`
- 脚本命名不清晰（lite vs 完整版）
- 缺少一键启动 dev 环境的脚本
- npass 网络需要手动创建

## What Changes

- 删除失效的 `start-lite.sh`、`stop-lite.sh`、`status.sh`
- 创建统一的 `dev-infra.sh` 脚本：启动/停止/状态/导入配置
- 脚本自动检查并创建 npass 网络
- 简化目录结构：`infra/scripts/` → `infra/`

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None.

## Impact

**删除文件：**
- `infra/scripts/docker/start-lite.sh`
- `infra/scripts/docker/stop-lite.sh`
- `infra/scripts/docker/status.sh`
- `infra/scripts/docker/pull-images-lite.sh`

**新增文件：**
- `infra/dev-infra.sh` - 统一的 dev 环境管理脚本

**修改文件：**
- `infra/scripts/nacos-import-configs.sh` → `infra/nacos-config-import.sh`
