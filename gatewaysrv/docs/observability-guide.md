# Observability Guide

本文档说明如何配置和使用 GatewaySrv 的可观测性功能，包括指标、日志和链路追踪。

## 架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                      nexora-network (172.28.0.0/16)             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │  gatewaysrv  │    │  Prometheus  │───▶│   Grafana    │      │
│  │  :40004      │───▶│  :9090       │    │   :3000      │      │
│  │  :40005      │    │  (30019)     │    │  (30018)     │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│         │                   ▲                                   │
│         │                   │                                   │
│         ▼                   │                                   │
│  ┌──────────────┐           │                    ┌──────────────┐│
│  │    Tempo     │           │                    │ Kibana       ││
│  │  (30015)     │───────────┴────────────────────│ (30005)      ││
│  │  OTLP:4317   │           Elasticsearch         │ Elasticsearch ││
│  └──────────────┘           (30003)              └──────────────┘│
│         ▲                                                 ▲      │
│         │                                                 │      │
│  ┌──────────────┐                                  ┌─────┴──────┐│
│  │   Filebeat   │──────────────────────────────────│     ES     ││
│  │  日志采集     │                                  │  (30003)   ││
│  └──────────────┘                                  └────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## 组件端口映射

| 组件 | 内部端口 | 外部端口 | 用途 |
|------|---------|---------|------|
| **Gateway HTTP** | 40004 | 40004 | 业务请求 |
| **Gateway Management** | 40005 | 40005 | 健康检查、指标 |
| **Prometheus** | 9090 | 30019 | 指标采集 |
| **Grafana** | 3000 | 30018 | 可视化面板 |
| **Tempo HTTP** | 3200 | 30014 | 链路查询 UI |
| **Tempo OTLP gRPC** | 4317 | 30015 | 链路数据接收 |
| **Tempo OTLP HTTP** | 4318 | 30016 | 链路数据接收 |
| **Tempo Zipkin** | 9411 | 30017 | Zipkin 兼容接口 |
| **Elasticsearch** | 9200 | 30003 | 日志存储 |
| **Kibana** | 5601 | 30005 | 日志查询 UI |
| **Filebeat** | - | - | 日志采集 |

---

## 一、指标监控 (Prometheus + Grafana)

### 1.1 Nacos 配置

在 Nacos `gatewaysrv-{profile}.yml` 中配置：

```yaml
management:
  # Prometheus 指标导出
  prometheus:
    metrics:
      export:
        enabled: true
        step: 30s
  # 指标标签
  metrics:
    tags:
      application: ${spring.application.name}
      environment: ${spring.profiles.active}
  # 端点配置
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true
    circuitbreakers:
      enabled: true
    ratelimiters:
      enabled: true
  # 健康检查
  health:
    redis:
      enabled: true
    nacos:
      enabled: true
    diskspace:
      enabled: true
      threshold: 10MB
    circuitbreakers:
      enabled: true
    ratelimiters:
      enabled: true
```

### 1.2 Prometheus 配置

Prometheus 已配置自动采集 Gateway 指标（见 `infra/config/docker/prometheus/prometheus.yml`）：

```yaml
scrape_configs:
  - job_name: 'gatewaysrv'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['host.docker.internal:40005']
        labels:
          application: 'gatewaysrv'
          service: 'gateway'
```

### 1.3 Grafana 配置

#### 添加 Prometheus 数据源

1. 访问 `http://服务器IP:30018` (admin / Nexora@2026)
2. Settings → Data sources → Add data source
3. 选择 **Prometheus**
4. URL: `http://prometheus:9090`
5. 点击 **Save & Test**

#### 导入 Dashboard

推荐的 Dashboard ID：

| ID | 名称 | 用途 |
|----|------|------|
| 4701 | JVM Micrometer | JVM 内存、GC、线程 |
| 11442 | Spring Boot Gateway | 路由、请求、响应 |
| 15233 | WebFlux | Reactor 指标 |

导入步骤：
1. Dashboards → Import
2. 输入 Dashboard ID
3. 选择 Prometheus 数据源
4. 点击 Import

---

## 二、日志管理 (Filebeat + Elasticsearch + Kibana)

### 2.1 部署 Filebeat

Filebeat 配置已添加到 `infra/docker-compose.yml`，启动方式：

```bash
cd /path/to/infra
docker-compose up -d filebeat
```

### 2.2 Filebeat 配置

配置文件：`infra/config/docker/filebeat/filebeat.yml`

关键配置：
- 采集所有容器日志
- 自动添加容器元数据
- 按服务名称分索引存储

### 2.3 Kibana 查询日志

1. 访问 `http://服务器IP:30005` (elastic / Nexora@2026)

2. 创建索引模式：
   - Management → Stack Management → Index Patterns
   - 创建索引模式：`gatewaysrv-*`
   - 选择时间字段：`@timestamp`

3. 查询日志：
   - 进入 Discover
   - 选择索引模式
   - 使用 KQL 查询语法，例如：
     ```
     container.attributes.name: "nexora-gatewaysrv"
     message: "ERROR"
     ```

---

## 三、链路追踪 (Tempo)

### 3.1 Nacos 配置

在 Nacos `gatewaysrv-{profile}.yml` 中配置：

```yaml
management:
  tracing:
    enabled: true
  otlp:
    tracing:
      endpoint: ${OTLP_ENDPOINT}
```

### 3.2 环境变量

不同环境的 OTLP_ENDPOINT：

| 环境 | Endpoint |
|------|----------|
| **本地开发** | `http://host.docker.internal:30015/v1/spans` |
| **同服务器 (Docker 网络)** | `http://172.28.0.18:4317/v1/spans` |
| **跨服务器** | `http://服务器IP:30015/v1/spans` |

### 3.3 Tempo 配置

Tempo 配置文件：`infra/config/docker/tempo/config.yaml`

支持的协议：
- **OTLP gRPC**: `:4317`
- **OTLP HTTP**: `:4318`
- **Zipkin**: `:9411`

### 3.4 Grafana Tempo 数据源

1. Settings → Data sources → Add data source
2. 选择 **Tempo**
3. URL: `http://tempo:3200`
4. Save & Test

### 3.5 查询链路

**方式 1：Tempo UI**
- 访问 `http://服务器IP:30014`
- 输入 Trace ID 查询

**方式 2：Grafana**
- 在 Explore 中选择 Tempo
- 按 Trace ID、标签搜索

**方式 3：Grafana 关联查询**
- 在 Grafana Dashboard 中点击指标
- 自动跳转到对应的 Trace

---

## 四、快速部署指南

### 4.1 启动 infra 栈

```bash
cd /path/to/infra
docker-compose up -d
```

### 4.2 部署 gatewaysrv

```bash
docker run -d \
  --name gatewaysrv \
  --restart always \
  -p 40004:40004 \
  -p 40005:40005 \
  -e NACOS_HOST=172.28.0.14 \
  -e NACOS_PORT=8848 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e SPRING_CLOUD_NACOS_LOGGING_DEFAULT_CONFIG_ENABLED=false \
  -e OTLP_ENDPOINT=http://172.28.0.18:4317/v1/spans \
  gatewaysrv:latest
```

### 4.3 验证

```bash
# 检查服务状态
curl http://localhost:40004/actuator/health

# 检查指标
curl http://localhost:40005/actuator/prometheus

# 检查 Prometheus 采集
curl http://服务器IP:30019/api/v1/targets
```

---

## 五、常用查询语句

### Prometheus PromQL

```promql
# QPS
rate(http_server_requests_seconds_count{application="gatewaysrv"}[5m])

# P95 延迟
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket{application="gatewaysrv"}[5m]))

# 错误率
rate(http_server_requests_seconds_count{application="gatewaysrv",status=~"5.."}[5m]) / rate(http_server_requests_seconds_count{application="gatewaysrv"}[5m])

# JVM 堆内存使用
jvm_memory_used_bytes{application="gatewaysrv",area="heap"}
```

### Kibana KQL

```
# 按服务过滤
container.attributes.name: "nexora-gatewaysrv"

# 按日志级别
message: "ERROR" OR message: "WARN"

# 按时间范围
@timestamp: [now-1h TO now]

# 组合查询
container.attributes.name: "nexora-gatewaysrv" AND message: "Exception"
```

---

## 六、故障排查

### 指标采集不到

1. 检查 Gateway 暴露端口：
   ```bash
   curl http://localhost:40005/actuator/prometheus
   ```

2. 检查 Prometheus targets：
   ```
   http://服务器IP:30019/targets
   ```

3. 检查网络连通性（在 Prometheus 容器内）：
   ```bash
   docker exec -it nexora-prometheus wget -qO- http://host.docker.internal:40005/actuator/prometheus
   ```

### 日志不显示

1. 检查 Filebeat 状态：
   ```bash
   docker logs nexora-filebeat
   ```

2. 测试 Elasticsearch 连接：
   ```bash
   curl -u elastic:Nexora@2026 http://服务器IP:30003/_cat/indices?v
   ```

3. 检查索引是否创建：
   ```
   http://服务器IP:30005/app/dev_tools#/console
   GET _cat/indices/gatewaysrv-*
   ```

### 链路追踪没有数据

1. 检查 Gateway tracing 配置：
   ```bash
   docker exec gatewaysrv curl http://localhost:40005/actuator/health/tracing
   ```

2. 检查 Tempo 接收数据：
   ```
   http://服务器IP:30014/search
   ```

3. 验证 OTLP endpoint 连通性：
   ```bash
   docker exec gatewaysrv curl -v http://172.28.0.18:4317
   ```

---

## 七、性能优化

### Prometheus 存储优化

```yaml
# prometheus.yml
global:
  scrape_interval: 30s  # 降低采集频率
  evaluation_interval: 30s

# 启动参数
--storage.tsdb.retention.time=15d  # 保留 15 天数据
```

### Elasticsearch 索引生命周期

```yaml
# filebeat.yml
setup.ilm.enabled: true
setup.ilm.policy_name: "nexora-logs-policy"
setup.ilm.policy.rollover_age: 7d
setup.ilm.policy.delete_age: 30d
```

### Tempo 存储

```yaml
# tempo/config.yaml
distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          # 采样率（生产环境建议 10% - 30%）
          # 在应用端通过环境变量配置
```
