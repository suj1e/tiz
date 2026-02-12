# Nexora 基础设施部署指南

## 服务器要求

- **操作系统**: Ubuntu 20.04+ / Debian 11+
- **内存**: 16GB RAM
- **磁盘**: 50GB+ 可用空间
- **CPU**: 4核心+

## 快速开始

### 1. 安装 Docker 和 Docker Compose

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要的包
sudo apt install -y curl git ca-certificates gnupg

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version
```

### 2. 配置用户权限（可选）

```bash
# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录或运行
newgrp docker
```

### 3. 上传部署文件

```bash
# 方式1: 使用 git 克隆
git clone <your-repo-url> /opt/nexora
cd /opt/nexora

# 方式2: 手动上传（使用 scp 或 rsync）
# scp -r infra user@server:/opt/nexora
cd /opt/nexora/infra
```

### 4. 优化系统参数

```bash
# 修改系统限制
sudo tee -a /etc/sysctl.conf << EOT
# Docker & Elasticsearch 优化
vm.max_map_count=262144
fs.file-max=65536
net.ipv4.ip_forward=1
EOT

# 应用配置
sudo sysctl -p

# 配置 Docker 日志大小
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << EOT
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOT

# 重启 Docker
sudo systemctl restart docker
```

### 5. 一键启动

```bash
# 进入项目目录
cd /opt/nexora/infra

# 预下载镜像（从 docker-compose.yml 动态读取）
./scripts/docker/pull-images.sh

# 执行启动脚本（使用 --pull never，不会重复拉取）
./scripts/docker/start.sh
```

## 服务说明

**端口映射说明**: 外部端口使用 30000~31000 范围，避免与系统端口冲突

### 核心服务

| 服务 | 外部端口 | 内部端口 | 用户名/密码 | 用途 |
|------|----------|----------|-------------|------|
| MySQL | 30001 | 3306 | root/Nexora@2026 | 关系型数据库 |
| Redis | 30002 | 6379 | 密码: Nexora@2026 | 缓存 |
| Elasticsearch | 30003 | 9200 | elastic/Nexora@2026 | 搜索引擎 |
| Kibana | 30005 | 5601 | - | ES 可视化 |

### 中间件服务

| 服务 | 外部端口 | 内部端口 | 用户名/密码 | 用途 |
|------|----------|----------|-------------|------|
| Nacos | 30006, 31006~31007 | 8848, 9848~9849 | nacos/nacos | 服务注册/配置中心 |
| Kafka | 30009 | 9092 | - | 消息队列 (KRaft) |

### 管理工具

| 服务 | 外部端口 | 内部端口 | 用途 |
|------|----------|----------|------|
| Kafka UI | 30010 | 8080 | Kafka 管理界面 |
| OTEL Collector | 30011~30013 | 4317~8888 | Trace/Metrics 收集 |
| Jaeger UI | 30014 | 16686 | 分布式追踪界面 |

## 常用命令

```bash
# 启动所有服务
./scripts/docker/start.sh

# 停止所有服务
./scripts/docker/stop.sh

# 查看服务状态
./scripts/docker/status.sh

# 备份数据
./scripts/docker/backup.sh

# 查看日志
docker-compose logs -f [service-name]

# 重启单个服务
docker-compose restart [service-name]

# 查看资源使用
docker stats
```

## 故障排查

### Elasticsearch 启动失败

```bash
# 检查虚拟内存设置
sysctl vm.max_map_count

# 如果小于 262144，执行：
sudo sysctl -w vm.max_map_count=262144
```

### MySQL 连接失败

```bash
# 检查容器状态
docker-compose ps mysql

# 查看日志
docker-compose logs mysql

# 进入容器
docker-compose exec mysql bash
```

### 内存不足

```bash
# 查看内存使用
free -h

# 查看 Docker 内存占用
docker stats --no-stream

# 如需进一步优化，可暂停非必要服务
docker-compose stop kibana kafka-ui jaeger
```

## 数据持久化

所有数据都存储在 Docker volumes 中：

```bash
# 列出所有 volumes
docker volume ls | grep nexora

# 备份 volumes
docker run --rm -v nexora_mysql-data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/mysql-data.tar.gz -C /data .

# 恢复 volumes
docker run --rm -v nexora_mysql-data:/data -v $(pwd)/backups:/backup alpine tar xzf /backup/mysql-data.tar.gz -C /data
```

## 升级更新

```bash
# 停止服务
./scripts/docker/stop.sh

# 拉取最新镜像（从 docker-compose.yml 动态读取）
./scripts/docker/pull-images.sh

# 重新启动
./scripts/docker/start.sh
```

## 卸载清理

```bash
# 停止并删除容器
docker-compose down

# 删除数据卷（谨慎操作！）
docker-compose down -v

# 删除镜像
docker rmi $(docker images 'nexora-*' -q)

# 删除项目文件
rm -rf /opt/nexora
```

## 安全建议

1. **修改默认密码**: 修改 docker-compose.yml 中的所有默认密码
2. **防火墙配置**: 只开放必要的端口
3. **SSL/TLS**: 生产环境建议配置 HTTPS
4. **定期备份**: 使用 cron 定期执行备份脚本

```bash
# 添加定时备份（每天凌晨2点）
crontab -e

# 添加以下行
0 2 * * * cd /opt/nexora/infra && ./scripts/docker/backup.sh
```

## 技术支持

- 查看日志: `docker-compose logs -f [service]`
- 健康检查: `./scripts/docker/status.sh`
- 内存监控: `docker stats`
