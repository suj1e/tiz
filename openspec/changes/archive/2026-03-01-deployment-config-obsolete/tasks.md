## 1. Dockerfile 创建

- [x] 1.1 创建 tiz-backend/docker/Dockerfile.java (Java 服务通用 Dockerfile)
- [x] 1.2 优化 tiz-web/Dockerfile (确保生产就绪)
- [x] 1.3 优化 tiz-backend/llmsrv/Dockerfile (确保生产就绪)

## 2. Docker Compose 配置

- [x] 2.1 创建 infra/docker-compose-app.yml (应用服务编排)
- [x] 2.2 创建 infra/.env.example (环境变量示例)
- [x] 2.3 配置 tiz-backend 网络隔离
- [x] 2.4 配置健康检查
- [x] 2.5 配置资源限制

## 3. npass 路由配置

- [x] 3.1 更新 /opt/dev/apps/npass/nginx/nginx.conf 添加 tiz 前端路由
- [x] 3.2 更新 /opt/dev/apps/npass/nginx/nginx.conf 添加 tiz API 路由
- [x] 3.3 更新 /opt/dev/apps/npass/README.md 文档
- [ ] 3.4 重启 npass 服务验证路由

## 4. GitHub Actions CI/CD

- [x] 4.1 创建 .github/workflows/deploy.yml (部署流水线)
- [x] 4.2 配置 Java 服务构建矩阵
- [x] 4.3 配置前端构建步骤
- [x] 4.4 配置 llmsrv 构建步骤
- [x] 4.5 配置镜像推送到 ghcr.io
- [x] 4.6 配置 SSH 部署步骤
- [x] 4.7 配置部署通知
- [x] 4.8 配置 GitHub Secrets 支持（将敏感信息从服务器迁移到 GitHub Secrets）

## 5. 文档更新

- [x] 5.1 更新 tiz/README.md 添加部署说明
- [ ] 5.2 创建 DEPLOYMENT.md 详细部署指南
- [x] 5.3 更新 CLAUDE.md 添加部署相关说明

## 6. 验证测试

- [ ] 6.1 本地构建测试 (docker-compose up)
- [ ] 6.2 首次部署测试 (手动触发)
- [ ] 6.3 Tag 触发测试 (v0.1.0)
- [ ] 6.4 访问验证 (tiz.dmall.ink, api.tiz.dmall.ink)
- [ ] 6.5 健康检查验证

## 7. 清理和收尾

- [ ] 7.1 删除临时测试镜像
- [ ] 7.2 归档此 OpenSpec change
