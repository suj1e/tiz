## Context

当前项目部署配置分散：
- 前端在 `tiz-web/` 有独立的 Dockerfile 和 docker-compose.yml
- 后端每个服务在自己的目录下有 Dockerfile 和 docker-compose.yml
- 基础设施在 `infra/` 目录管理
- 没有统一的部署脚本，需要手动操作

这种分散结构导致：
1. 部署操作繁琐，需要进入多个目录
2. 前端 desktop/mobile 分别构建，镜像冗余
3. 缺乏统一的运维工具（rollback、logs 等）

## Goals / Non-Goals

**Goals:**
- 统一部署目录 `deploy/`，集中管理 staging 和 prod 环境
- 合并前端为单容器，通过 nginx UA 分流
- 提供完整功能的 `deploy.sh` 脚本
- 支持一键部署所有应用服务

**Non-Goals:**
- 不涉及 CI/CD 流程（后续独立处理）
- 不修改 `infra/` 目录结构
- 不修改后端服务的 Dockerfile

## Decisions

### 1. 部署目录结构

```
deploy/
├── staging/
│   ├── docker-compose.yml
│   └── .env
├── prod/
│   ├── docker-compose.yml
│   └── .env
└── deploy.sh
```

**Rationale**: 按环境分目录，与 `infra/` 保持一致的风格。`.env` 文件存放敏感配置，不提交到 git。

### 2. 前端合并方案

使用 nginx 根据 User-Agent 分流：

```nginx
# 检测移动端 UA
map $http_user_agent $frontend_root {
    default /usr/share/nginx/html/desktop;
    ~*mobile|android|iphone /usr/share/nginx/html/mobile;
}

server {
    root $frontend_root;
}
```

**Rationale**: 单容器减少镜像数量，UA 分流对用户透明，无需修改访问方式。

**Alternatives considered**:
- 两个独立容器 + 负载均衡：更复杂，增加运维负担
- 响应式设计：需要大量前端重构

### 3. docker-compose.yml 内容

每个环境包含 9 个服务：
- `tiz-web` (frontend)
- `gateway`
- `auth-service`, `chat-service`, `content-service`
- `practice-service`, `quiz-service`, `user-service`
- `llm-service`

**Rationale**: 全栈部署，确保所有服务版本一致。基础设施由 `infra/` 管理，保持关注点分离。

### 4. deploy.sh 命令设计

```bash
./deploy.sh <env> <command> [options]

Commands:
  deploy [service]   拉取镜像并启动服务（可选指定单个服务）
  stop               停止所有服务
  restart [service]  重启服务
  logs [service]     查看日志（默认所有服务）
  status             健康检查
  ps                 列出容器
  rollback <service> 回滚到上一版本
```

**Rationale**: 覆盖常用运维操作，与 `infra.sh` 风格一致。

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| 前端合并后 nginx 配置复杂度增加 | 充分测试各种 UA 场景 |
| 统一部署影响单个服务更新灵活性 | deploy.sh 支持指定单个服务部署 |
| rollback 功能依赖镜像版本管理 | 保留 latest 和 sha-xxx 两个标签 |

## Migration Plan

1. 创建 `deploy/` 目录结构
2. 编写合并版前端 Dockerfile
3. 创建 staging 和 prod 的 docker-compose.yml
4. 编写 deploy.sh 脚本
5. 测试 staging 环境部署
6. 文档更新
