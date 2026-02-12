# Nexora 基础设施部署

> 为 Nexora 平台提供完整的基础设施部署方案，支持 Docker Compose 和 Kubernetes 两种部署方式。

## 特性

- 🚀 一键部署，开箱即用
- 📦 16GB 内存优化配置
- 🔄 完整的监控和备份方案
- 📚 详细的文档和脚本
- 🔒 安全配置和密码管理
- 📡 事件驱动架构支持
- 🔍 全链路追踪

## 快速开始

### Docker Compose 部署 (推荐用于开发/测试)

```bash
# 预下载镜像（推荐，避免启动时重复拉取）
./scripts/docker/pull-images.sh

# 一键启动
./scripts/docker/start.sh

# 查看状态
./scripts/docker/status.sh

# 停止服务
./scripts/docker/stop.sh
```

### Kubernetes 部署 (用于生产环境)

```bash
# 一键部署
./scripts/k8s/deploy.sh
```

## 服务访问

| 服务 | 端口 | 地址 | 账号 |
|------|------|------|------|
| 🗄️ MySQL | 30001 | localhost:30001 | root/Nexora@2026 |
| 🔴 Redis | 30002 | localhost:30002 | 密码: Nexora@2026 |
| 🔍 Elasticsearch | 30003 | http://localhost:30003 | elastic/Nexora@2026 |
| 📊 Kibana | 30005 | http://localhost:30005 | - |
| 🎯 Nacos | 30006 | http://localhost:30006/ | nacos/nacos |
| 📨 Kafka | 30009 | localhost:30009 | - |
| 📨 Kafka UI | 30010 | http://localhost:30010 | - |
| 📡 OTEL Collector | 30011-30013 | localhost:30011-30013 | - |
| 🔍 Jaeger UI | 30014 | http://localhost:30014 | - |

## 目录结构

```
├── README.md                   # 本文件
├── docker-compose.yml          # Docker Compose 配置
│
├── docs/                       # 📚 文档
│   ├── README.md              # 文档导航
│   ├── deployment.md          # 部署指南
│   ├── architecture.md        # 架构说明
│   └── ports.md               # 端口映射
│
├── config/                     # ⚙️  配置文件
│   ├── docker/                # Docker 配置
│   └── k8s/                   # Kubernetes 配置
│
├── scripts/                    # 🔧 脚本
│   ├── docker/                # Docker 脚本
│   ├── k8s/                   # K8s 脚本
│   └── tools/                 # 工具脚本
│
├── backups/                    # 💾 备份
└── logs/                       # 📋 日志
```

## 系统要求

### Docker Compose
- OS: Ubuntu 20.04+ / Debian 11+
- RAM: 16GB
- Disk: 50GB+
- CPU: 4核心+

### Kubernetes
- K8s: 1.20+
- 根据组件需求配置资源

## 文档

- 📖 [完整文档](docs/README.md)
- 🚀 [部署指南](docs/deployment.md)
- 🏗️ [架构说明](docs/architecture.md)
- 🔌 [端口映射](docs/ports.md)
- 🔑 [服务访问](docs/access.md)

## 常用命令

```bash
# Docker Compose
./scripts/docker/start.sh    # 启动
./scripts/docker/stop.sh     # 停止
./scripts/docker/status.sh   # 状态
./scripts/docker/backup.sh   # 备份

# 查看 Docker 日志
docker-compose logs -f [service]

# 查看资源占用
docker stats

# Kubernetes
./scripts/k8s/deploy.sh      # 部署
kubectl get all -n nexora-infra
```

## 支持的服务

- MySQL 9.2 - 关系型数据库
- Redis 7.4 - 缓存服务
- Elasticsearch 8.19 - 搜索引擎
- Kibana 8.19 - ES 可视化
- Nacos 3.1.1 - 服务注册与配置中心
- Kafka 7.8 (KRaft) - 事件中枢
- Kafka UI - Kafka 管理界面
- OpenTelemetry Collector - Trace/Metrics 收集
- Jaeger 1.62 - 分布式追踪

## 配置说明

### 修改端口
编辑 `docker-compose.yml` 中的 `ports` 配置。

### 修改密码
编辑 `docker-compose.yml` 中的 `*_PASSWORD` 环境变量。

### 内存优化
当前配置已针对 16GB 内存优化，可根据实际情况调整。

## 故障排查

### Elasticsearch 启动失败
```bash
sudo sysctl -w vm.max_map_count=262144
```

### 查看日志
```bash
docker-compose logs -f [service]
```

### 健康检查
```bash
./scripts/tools/health-check.sh
```

## 备份与恢复

```bash
# 备份
./scripts/docker/backup.sh

# 恢复（手动）
docker exec -i nexora-mysql mysql -u root -pNexora@2026 < backup.sql
```

## 许可证

MIT License

## 更新日志

### 2025-01-31
- 🔄 数据库迁移：PostgreSQL → MySQL 9.2
- 🎯 Nacos 接入 MySQL 存储
### 2025-01-28
- 🔄 架构调整：事件驱动 + 最终一致性
- 🗄️ 使用 PostgreSQL 18
- 📨 Kafka 改用 KRaft 模式（移除 ZooKeeper）
- ❌ 移除 Seata（分布式事务）
- ❌ 移除 Sentinel（应用层 Resilience4j）
- ❌ 移除 ElasticJob（应用层 Quartz）
- ✨ 新增 OpenTelemetry Collector
- ✨ 新增 Jaeger（分布式追踪）

### 2025-01-27
- ✨ 重新组织目录结构
- 🔢 端口映射改为 30000~31000
- ⚡ 16GB 内存优化
- 📚 完善文档体系
