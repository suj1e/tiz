## Context

当前 `infra/` 目录下只有一个 `docker-compose.yml`，所有环境共用一套配置。不同环境的需求：

| 环境 | 数据持久化 | 资源配置 | 端口策略 | 镜像源 |
|------|-----------|---------|---------|--------|
| dev | Docker 命名卷 | 低 | 全部暴露 | daocloud 镜像 |
| staging | 宿主机目录 | 中 | 全部暴露 | 官方镜像 |
| prod | 宿主机目录 | 高 | 最小暴露 | 官方镜像 |

## Goals / Non-Goals

**Goals:**
- 创建独立的目录结构区分环境配置
- 保持 dev 环境与现有配置兼容
- staging/prod 支持通过环境变量自定义关键参数
- 提供统一的管理脚本

**Non-Goals:**
- 不涉及 Kubernetes 配置
- 不涉及云托管服务（RDS、ElastiCache 等）
- 不修改应用服务配置

## Decisions

### 1. 目录结构

```
infra/
├── envs/
│   ├── dev/
│   │   ├── docker-compose.yml
│   │   └── .env
│   ├── staging/
│   │   ├── docker-compose.yml
│   │   └── .env.example
│   └── prod/
│       ├── docker-compose.yml
│       └── .env.example
├── config/              # 共享配置文件（redis.conf 等）
└── infra.sh             # 统一管理脚本
```

**理由**: 清晰的目录分离，便于管理和版本控制。

### 2. 环境差异化配置

| 配置项 | dev | staging | prod |
|--------|-----|---------|------|
| MySQL buffer pool | 256M | 1G | 2G |
| Redis maxmemory | 无限制 | 512M | 2G |
| ES heap | 512M | 1G | 2G |
| Kafka heap | 512M | 1G | 2G |
| Nacos heap | 256M | 512M | 1G |
| 数据目录 | Docker 卷 | /opt/tiz/data | /opt/tiz/data |
| Kafka UI | 包含 | 包含 | 不包含 |

### 3. 环境变量策略

staging/prod 使用 `.env` 文件配置敏感信息：
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD`
- `REDIS_PASSWORD`
- `ELASTIC_PASSWORD`
- `NACOS_AUTH_TOKEN`
- `KAFKA_CLUSTER_ID`
- `KAFKA_HOST` (Kafka 外部访问地址)
- `DATA_PATH` (数据存储路径)

## Risks / Trade-offs

**数据迁移风险** → 现有 dev 环境数据可通过 `docker volume` 命令备份

**配置漂移风险** → 三个环境的 compose 文件需要同步更新基础设施版本

**prod 无 Kafka UI** → 可通过命令行工具或临时启动 UI 容器管理
