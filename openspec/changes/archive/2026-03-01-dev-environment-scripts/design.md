## Context

Dev 环境需要：
1. 启动基础设施（MySQL, Redis, Nacos, Kafka, ES）
2. 创建 npass 网络
3. 导入 Nacos 配置
4. 后端服务本地运行（gradle bootRun）

## Goals / Non-Goals

**Goals:**
- 一键启动/停止 dev 环境
- 自动检查依赖（Docker, 网络）
- 自动导入 Nacos 配置
- 清晰的状态输出

**Non-Goals:**
- 不管理 prod 部署（由 CI/CD 处理）
- 不启动应用服务（本地 gradle 运行）

## Decisions

### 1. 脚本命名

`dev-infra.sh` - 统一的 dev 基础设施管理脚本

```bash
./dev-infra.sh start     # 启动所有 infra
./dev-infra.sh stop      # 停止所有 infra
./dev-infra.sh status    # 查看状态
./dev-infra.sh logs      # 查看日志
./dev-infra.sh import    # 导入 Nacos 配置
```

### 2. 目录结构简化

```
infra/
├── docker-compose.yml       # 基础设施定义
├── dev-infra.sh             # dev 环境管理脚本
├── nacos-config-import.sh   # Nacos 配置导入
├── config/                  # 配置文件
│   └── docker/
│       ├── mysql/init/
│       ├── redis/
│       └── nacos/
└── README.md
```

### 3. 启动流程

```
dev-infra.sh start
    │
    ├─▶ 检查 Docker
    ├─▶ 检查/创建 npass 网络
    ├─▶ docker-compose up -d
    ├─▶ 等待服务就绪
    └─▶ 提示访问地址
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 脚本兼容性 | 只支持 macOS/Linux |
| 端口冲突 | 启动前检查端口 |
