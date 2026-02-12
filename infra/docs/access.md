# 服务访问指南

## 密码信息

| 服务 | 用户名 | 密码 |
|------|--------|------|
| MySQL | root | `Nexora@2026` |
| MySQL | nexora | `Nexora@2026` |
| Redis | - | `Nexora@2026` |
| Elasticsearch | elastic | `Nexora@2026` |
| Kibana | kibana_system | `g+bEkV*2AxbWMhXT=Gpk` |
| Nacos | nacos | `nacos` |
| Grafana | admin | `Nexora@2026` |

## 服务端口

| 服务 | 端口 | 协议 |
|------|------|------|
| MySQL | 30001 | TCP |
| Redis | 30002 | TCP |
| Elasticsearch | 30003 | HTTP |
| Kibana | 30005 | HTTP |
| Nacos | 30006 | HTTP |
| Kafka | 30009 | TCP |
| Kafka UI | 30010 | HTTP |
| Tempo | 30014 | HTTP |
| Grafana | 30018 | HTTP |

## 命令行访问

### MySQL

```bash
# 本地连接
mysql -h 127.0.0.1 -P 30001 -u root -pNexora@2026

# 进入容器
docker exec -it nexora-mysql mysql -u root -pNexora@2026

# 连接字符串
mysql://root:Nexora@2026@127.0.0.1:30001/nexora
```

### Redis

```bash
# 本地连接
redis-cli -h 127.0.0.1 -p 30002 -a "Nexora@2026"

# 进入容器
docker exec -it nexora-redis redis-cli -a "Nexora@2026"

# 连接字符串
redis://:Nexora@2026@127.0.0.1:30002
```

### Elasticsearch

```bash
# 健康检查
curl -u elastic:Nexora@2026 http://localhost:30003/_cluster/health

# 查看节点
curl -u elastic:Nexora@2026 http://localhost:30003/_cat/nodes

# 查看索引
curl -u elastic:Nexora@2026 http://localhost:30003/_cat/indices
```

### Kafka

```bash
# 进入容器
docker exec -it nexora-kafka bash

# 列出主题
kafka-topics --bootstrap-server localhost:9094 --list

# 创建主题
kafka-topics --bootstrap-server localhost:9094 --create --topic test-topic --partitions 3 --replication-factor 1

# 查看主题详情
kafka-topics --bootstrap-server localhost:9094 --describe --topic test-topic
```

## Web 界面访问

| 服务 | URL | 账号 |
|------|-----|------|
| Kibana | http://localhost:30005 | elastic/Nexora@2026 |
| Nacos | http://localhost:30006/nacos | nacos/nacos |
| Kafka UI | http://localhost:30010 | - |
| Tempo | http://localhost:30014 | - |
| Grafana | http://localhost:30018 | admin/Nexora@2026 |

### Kibana

- 访问: http://localhost:30005
- 用户名: `elastic`
- 密码: `Nexora@2026`

### Nacos

- 访问: http://localhost:30006/nacos
- 用户名: `nacos`
- 密码: `nacos`

### Kafka UI

- 访问: http://localhost:30010
- 无需登录

### Tempo (链路追踪)

- 访问: http://localhost:30014
- 无需登录

### Grafana

- 访问: http://localhost:30018
- 用户名: `admin`
- 密码: `Nexora@2026`
- 已预配置 Elasticsearch 和 Tempo 数据源

## 健康检查

```bash
# 运行健康检查脚本
./scripts/docker/status.sh

# 或手动检查
docker ps
```

## 常见操作

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f mysql
docker-compose logs -f redis
docker-compose logs -f elasticsearch
docker-compose logs -f nacos
docker-compose logs -f kafka
```

### 重启服务

```bash
# 重启所有服务
./scripts/docker/stop.sh
./scripts/docker/start.sh

# 重启单个服务
docker-compose restart mysql
docker-compose restart redis
```

### 备份数据

```bash
./scripts/docker/backup.sh
```

## 网络信息

### Docker 网络

- 网络名称: `nexora-network`
- 子网: `172.28.0.0/16`

### 容器固定 IP

| 服务 | IP 地址 |
|------|---------|
| MySQL | 172.28.0.10 |
| Redis | 172.28.0.11 |
| Elasticsearch | 172.28.0.12 |
| Kibana | 172.28.0.13 |
| Nacos | 172.28.0.14 |
| Kafka | 172.28.0.15 |
| Kafka UI | 172.28.0.16 |
| Tempo | 172.28.0.18 |
| Grafana | 172.28.0.19 |

### 容器间访问

容器之间可以使用服务名或固定 IP 进行通信：

```bash
# MySQL
mysql://root:Nexora@2026@mysql:3306/nexora
# 或
mysql://root:Nexora@2026@172.28.0.10:3306/nexora

# Redis
redis://:Nexora@2026@redis:6379
# 或
redis://:Nexora@2026@172.28.0.11:6379

# Elasticsearch
http://elastic:Nexora@2026@elasticsearch:9200
# 或
http://elastic:Nexora@2026@172.28.0.12:9200

# Nacos
http://nacos:8848/nacos
# 或
http://172.28.0.14:8848/nacos

# Kafka
kafka:9094
# 或
172.28.0.15:9094
```
