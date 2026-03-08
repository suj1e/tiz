## Why

当前项目有 17 个 GitHub Actions workflow 文件，用于自动发布 Maven 和构建 Docker 镜像。但对于小型团队/个人项目，这些自动化流水线增加了维护复杂度，而实际发布频率较低。简化为手动发布 + Dependabot 依赖检查是更轻量的选择。

## What Changes

- **删除** `.github/workflows/` 下所有 17 个 workflow 文件
  - 9 个 `docker-*.yml` (Docker 镜像构建)
  - 8 个 `publish-*.yml` (Maven 发布)
- **新增** `.github/dependabot.yml` 配置
  - Gradle 依赖检查 (Java 服务)
  - pnpm 依赖检查 (前端)
  - pixi 依赖检查 (Python 服务)
  - GitHub Actions 依赖检查 (如果有保留的 workflow)

## Capabilities

### New Capabilities

- `dependabot`: 自动检查依赖更新，创建 PR 提醒升级

### Modified Capabilities

无（这是新增能力，不修改现有 spec）

## Impact

- **删除文件**: `.github/workflows/` 下 17 个文件
- **新增文件**: `.github/dependabot.yml`
- **文档更新**: README.md、CLAUDE.md 删除 CI/CD 相关说明
- **发布方式**: 改为手动执行 `svc.sh publish` 和 `svc.sh image`
