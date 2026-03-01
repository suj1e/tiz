## 1. 清理失效脚本

- [x] 1.1 删除 `infra/scripts/docker/` 目录（包含所有失效脚本）

## 2. 移动和重命名脚本

- [x] 2.1 移动 `infra/scripts/nacos-import-configs.sh` → `infra/nacos-config-import.sh`
- [x] 2.2 删除空的 `infra/scripts/` 目录

## 3. 创建 dev-infra.sh

- [x] 3.1 创建 `infra/dev-infra.sh` 支持子命令：start/stop/restart/status/logs/import
- [x] 3.2 实现 npass 网络自动检查创建
- [x] 3.3 实现服务健康检查
- [x] 3.4 输出清晰的访问地址信息

## 4. 更新文档

- [x] 4.1 脚本自带帮助信息
