## Why

Tiz 项目已完成前后端 API 对齐，需要建立生产环境部署能力。当前缺少 CI/CD 流水线、容器化配置和反向代理路由，无法将代码部署到生产服务器。为了支持小规模生产环境和持续迭代，需要完整的部署解决方案。

## What Changes

- 新增 GitHub Actions CI/CD 流水线（Tag 触发构建和部署）
- 新增 Java 服务通用 Dockerfile
- 新增 docker-compose-app.yml 应用编排配置
- 更新 npass nginx.conf 添加 tiz 域名路由
- 更新 npass README.md 文档

## Capabilities

### New Capabilities

- `ci-cd-pipeline`: GitHub Actions 工作流，支持 Tag 触发的自动构建和部署
- `docker-build`: 前端和后端服务的 Docker 镜像构建配置
- `docker-compose-app`: 应用服务的 Docker Compose 编排配置
- `npass-routing`: npass 反向代理的域名路由配置

### Modified Capabilities

无（这是新增的部署能力，不修改现有功能规格）

## Impact

### 新增文件

| 文件 | 说明 |
|------|------|
| `.github/workflows/deploy.yml` | CI/CD 流水线 |
| `tiz-backend/docker/Dockerfile.java` | Java 服务通用 Dockerfile |
| `infra/docker-compose-app.yml` | 应用服务编排 |
| `infra/.env.example` | 环境变量示例 |

### 修改文件

| 文件 | 说明 |
|------|------|
| `/opt/dev/apps/npass/nginx/nginx.conf` | 添加 tiz 域名路由 |
| `/opt/dev/apps/npass/README.md` | 更新文档 |

### 外部依赖

| 依赖 | 说明 |
|------|------|
| GitHub Container Registry | 镜像存储 (ghcr.io) |
| npass | 反向代理 (已部署) |
| infra/docker-compose-lite.yml | 基础设施 (已部署) |

### 服务器配置要求

| 配置项 | 说明 |
|--------|------|
| GitHub Secrets | SERVER_HOST, SERVER_USER, SSH_PRIVATE_KEY, DEPLOY_PATH |
| SSH 公钥 | 服务器 ~/.ssh/authorized_keys |
