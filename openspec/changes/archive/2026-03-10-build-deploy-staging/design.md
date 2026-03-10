# Design: Build and Deploy Staging

## 构建流程

### 1. 镜像构建
每个服务使用 `./svc.sh image` 构建 Docker 镜像：
- 镜像命名: `registry.cn-hangzhou.aliyuncs.com/nxo/<service>:latest`
- 基于 `eclipse-temurin:21-jre-alpine` (Java) 或 `python:3.11-slim` (Python)

### 2. 服务构建顺序
```
并行构建 (无依赖):
├── auth-service
├── chat-service
├── content-service
├── gateway
├── practice-service
├── quiz-service
├── user-service
└── llm-service (可选)
```

### 3. 部署方式
使用 `deploy/deploy.sh staging deploy` 部署所有服务到 staging 环境。

## 部署架构
```
                    ┌─────────────────┐
                    │   Nginx (80)    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Gateway (9080) │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │  Auth   │         │  User   │         │ Content │
   │ (8101)  │         │ (8107)  │         │ (8103)  │
   └─────────┘         └─────────┘         └─────────┘
```

## 验证步骤
1. 检查所有容器健康状态
2. 测试 API 端点连通性
3. 测试登录注册功能
