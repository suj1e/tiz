# Build and Deploy Staging Environment

## What
构建所有后端服务镜像并部署到 staging 环境。

## Why
本地 staging 测试通过，需要将服务容器化部署到 staging 环境。

## Scope
- 8 个 Java 服务: auth-service, chat-service, content-service, gateway, practice-service, quiz-service, user-service
- 1 个 Python 服务: llm-service (可选)
- 部署到 staging 环境

## Out of Scope
- 生产环境部署
- 前端构建部署 (tiz-web)
