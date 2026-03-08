## 1. Dependabot 配置

- [x] 1.1 创建 `.github/dependabot.yml` 配置文件
- [x] 1.2 配置 Gradle 依赖检查（Java 服务）
- [x] 1.3 配置 pnpm 依赖检查（前端 tiz-web）
- [x] 1.4 配置 pip 依赖检查（llm-service 的 pixi/pyproject）

## 2. 删除 CI/CD Workflows

- [x] 2.1 删除 `.github/workflows/docker-*.yml` (9 个文件)
- [x] 2.2 删除 `.github/workflows/publish-*.yml` (8 个文件)
- [x] 2.3 删除 `.github/workflows/` 目录（如果为空）

## 3. 文档更新

- [x] 3.1 更新 README.md，删除 CI/CD 相关说明
- [x] 3.2 更新 CLAUDE.md，删除 CI/CD Workflows 章节
- [x] 3.3 更新 standards/backend.md，删除 CI/CD 相关内容
