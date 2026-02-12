# 端口映射文档

## 概述

Nexora 基础设施使用 **30000~31000** 外部端口范围，避免与系统端口冲突。

## 完整端口映射表

### 核心服务

| 服务 | 外部端口 | 内部端口 | 协议 | 访问方式 | 说明 |
|------|----------|----------|------|----------|------|
| MySQL | 30001 | 3306 | TCP | CLI | 主数据库 |
| Redis | 30002 | 6379 | TCP | CLI | 缓存服务 |
| Elasticsearch | 30003 | 9200 | HTTP | Web | ES API 接口 |
| Elasticsearch | 30004 | 9300 | TCP | Internal | ES 集群通信 |
| Kibana | 30005 | 5601 | HTTP | Web | ES 可视化界面 |

### 中间件服务

| 服务 | 外部端口 | 内部端口 | 协议 | 访问方式 | 说明 |
|------|----------|----------|------|----------|------|
| Nacos | 30006 | 8848 | HTTP | Web | Nacos 控制台 |
| Nacos | 31006 | 9848 | gRPC | Internal | Nacos gRPC |
| Nacos | 31007 | 9849 | gRPC | Internal | Nacos gRPC |
| Kafka | 30009 | 9092 | TCP | CLI | 消息队列 (KRaft) |

### 管理工具

| 服务 | 外部端口 | 内部端口 | 协议 | 访问方式 | 说明 |
|------|----------|----------|------|----------|------|
| Kafka UI | 30010 | 8080 | HTTP | Web | Kafka 管理界面 |
| OTEL Collector | 30011 | 4317 | gRPC | Internal | OTLP 接收器 |
| OTEL Collector | 30012 | 4318 | HTTP | Internal | OTLP 接收器 |
| OTEL Collector | 30013 | 8888 | HTTP | Web | Metrics 端点 |
| Jaeger UI | 30014 | 16686 | HTTP | Web | 分布式追踪界面 |

## 连接示例

### MySQL

```bash
# 命令行连接
mysql -h <服务器IP> -P 30001 -u root -p nexora

# 连接字符串
mysql://root:Nexora@2026@<服务器IP>:30001/nexora
```

### Redis

```bash
# 命令行连接
redis-cli -h <服务器IP> -p 30002 -a Nexora@2026

# 连接字符串
redis://:<密码>@<服务器IP>:30002
```

### Elasticsearch

```bash
# API 访问
curl http://<服务器IP>:30003

# 带认证
curl -u elastic:Nexora@2026 http://<服务器IP>:30003
```

### Kafka

```bash
# 生产者
kafka-console-producer.sh --bootstrap-server <服务器IP>:30009

# 消费者
kafka-console-consumer.sh --bootstrap-server <服务器IP>:30009
```

## Web 访问地址

| 服务 | URL | 默认账号 |
|------|-----|----------|
| Kibana | http://<IP>:30005 | elastic/Nexora@2026 |
| Nacos | http://<IP>:30006/ | nacos/nacos |
| Kafka UI | http://<IP>:30010 | - |
| Jaeger UI | http://<IP>:30014 | - |

## 端口分配规则

```
30001 ~ 30009  - 核心数据存储服务
30010 ~ 30014  - 可观测性和管理工具
30015 ~ 30019  - 预留扩展
30020 ~ 30029  - 预留扩展
30030 ~ 31000  - 未来服务预留
```

## 防火墙配置

如果服务器启用了防火墙，需要开放以下端口：

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 30001:30014/tcp

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=30001-30014/tcp
sudo firewall-cmd --reload

# 云服务器安全组
# 添加入站规则: TCP 30001-30014
```

## 端口冲突处理

如果遇到端口冲突，可以修改 `docker-compose.yml`:

```yaml
services:
  mysql:
    ports:
      - "30001:3306"  # 修改左侧端口
```

修改后运行：
```bash
docker-compose down
docker-compose up -d
```
