# 应用日志接入指南

## 概述

本文档说明如何将应用日志接入到 Nexora 基础设施的 **Elasticsearch + Kibana** 日志栈。

## 日志架构

```
应用 → stdout/stderr → Docker → Filebeat → Elasticsearch → Kibana
```

## 方案一：Filebeat 收集（推荐）

### 1. 在应用 docker-compose.yml 中添加 Filebeat

```yaml
version: '3.9'

services:
  # 你的应用服务
  gatewaysrv:
    image: nexora/gatewaysrv:latest
    ports:
      - "40004:40004"
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
    networks:
      - nexora-network
    # 日志标签，方便 Kibana 筛选
    logging:
      driver: "json-file"
      options:
        labels: "app,environment"
        tag: "gatewaysrv"

  # Filebeat 日志收集
  filebeat:
    image: elastic/filebeat:8.19.1
    container_name: gatewaysrv-filebeat
    user: root
    command: filebeat -e -strict.perms=false
    volumes:
      - ./config/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - ELASTICSEARCH_HOST=elasticsearch
      - ELASTICSEARCH_PORT=9200
      - ELASTICSEARCH_USERNAME=elastic
      - ELASTICSEARCH_PASSWORD=Nexora@2026
    networks:
      - nexora-network
    depends_on:
      - elasticsearch

networks:
  nexora-network:
    external: true
    name: nexora-network
```

### 2. 创建 Filebeat 配置

```bash
# 在应用目录创建配置
mkdir -p config/filebeat
```

**config/filebeat/filebeat.yml**

```yaml
filebeat.inputs:
  # 采集 Docker 容器日志
  - type: container
    enabled: true
    paths:
      - '/var/lib/docker/containers/*/*.log'
    processors:
      # 解析 JSON 日志
      - decode_json_fields:
          fields: ["message"]
          target: "json"
          overwrite_keys: true

      # 添加 Docker 元数据
      - add_docker_metadata:
          host: "unix:///var/run/docker.sock"

      # 添加应用标签
      - add_fields:
          target: ''
          fields:
            environment: dev
            project: nexora

# 采集的日志索引
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml

# 输出到 Elasticsearch
output.elasticsearch:
  hosts: ["${ELASTICSEARCH_HOST:elasticsearch}:${ELASTICSEARCH_PORT:9200}"]
  username: ${ELASTICSEARCH_USERNAME:elastic}
  password: ${ELASTICSEARCH_PASSWORD:Nexora@2026}
  indices:
    - index: "nexora-logs-%{+yyyy.MM.dd}"
      when.equals:
        docker.container.name: "gatewaysrv"

# Kibana 配置（用于自动创建索引模式）
setup.kibana:
  host: "${KIBANA_HOST:kibana}:5601"
  username: ${ELASTICSEARCH_USERNAME:elastic}
  password: ${ELASTICSEARCH_PASSWORD:Nexora@2026}

# 日志级别
logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
```

### 3. 启动服务

```bash
# 确保 infra 基础设施已启动
cd /opt/nexora/infra
./scripts/docker/start.sh

# 启动应用（在同一网络中）
cd /path/to/your/app
docker-compose up -d
```

---

## 方案二：OpenTelemetry Collector（统一可观测性）

如果已使用 OTEL 收集 Trace/Metrics，可以统一收集 Logs。

### 1. 更新应用配置

**application.yml**

```yaml
# 日志输出到 stdout（Docker 自动收集）
logging:
  level:
    root: INFO
    com.nexora.gateway: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"

# OTEL 配置
management:
  otlp:
    logging:
      endpoint: http://otel-collector:4318
  tracing:
    sampling:
      probability: 1.0
```

### 2. 更新 infra 的 OTEL Collector 配置

**infra/config/docker/otel-collector/config.yaml**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

  # 新增：接收文件日志
  filelog:
    include:
      - /var/lib/docker/containers/*/*.log
    start_at: beginning
    include_file_path: true
    include_file_name: true
    operators:
      - type: json_parser
        parse_from: body
      - type: regex_parser
        regex: '^({"log":"(?P<log>.*)","stream":"(?P<stream>.*)","time":"(?P<time>.*)"})$'

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024

  resource:
    attributes:
      - key: service.namespace
        value: nexora
        action: insert
      - key: deployment.environment
        value: dev
        action: insert

exporters:
  # 日志导出到 Elasticsearch
  elasticsearch:
    endpoints:
      - http://elasticsearch:9200
    username: elastic
    password: Nexora@2026
    index: nexora-logs
    tls:
      insecure: true

  # Trace 导出到 Tempo
  otlp:
    endpoint: tempo:4317
    tls:
      insecure: true

  logging:
    loglevel: info

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, resource]
      exporters: [otlp, logging]

    logs:
      receivers: [otlp, filelog]
      processors: [batch, resource]
      exporters: [elasticsearch, logging]

    metrics:
      receivers: [otlp]
      processors: [batch, resource]
      exporters: [logging]
```

---

## 在 Kibana 中查看日志

### 1. 访问 Kibana

```
URL: http://localhost:30005
用户名: elastic
密码: Nexora@2026
```

### 2. 创建索引模式

1. 左侧菜单 → **Stack Management**
2. **Index Patterns** → **Create index pattern**
3. 输入索引模式：`nexora-logs-*`
4. 选择时间字段：`@timestamp`
5. 点击 **Create index pattern**

### 3. 查看日志

1. 左侧菜单 → **Discover**
2. 选择索引模式：`nexora-logs-*`
3. 设置时间范围（如 Last 15 minutes）
4. 查看日志流

### 4. 常用查询

```
# 按服务名筛选
docker.container.name: "gatewaysrv"

# 按日志级别筛选
json.level: "ERROR"

# 按时间范围
@timestamp: [now-1h TO now]

# 组合查询
docker.container.name: "gatewaysrv" AND json.level: "ERROR"

# 全文搜索
"NullPointerException"
```

---

## 方案三：直接集成 Logback（Spring Boot 应用）

在 Spring Boot 应用中直接集成 Elasticsearch。

### 1. 添加依赖

**build.gradle.kts**

```kotlin
dependencies {
    implementation("co.elastic.logging:logback-ecs-encoder:1.6.0")
}
```

### 2. 配置 Logback

**src/main/resources/logback-spring.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="co.elastic.logging.logback.EcsEncoder">
            <serviceName>${spring.application.name}</serviceName>
            <serviceNodeName>${HOSTNAME}</serviceNodeName>
            <serviceEnvironment>${ENVIRONMENT:dev}</serviceEnvironment>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
    </root>
</configuration>
```

### 3. 验证 ECS 格式日志

```bash
docker logs gatewaysrv | jq .
```

输出示例：

```json
{
  "@timestamp": "2026-02-01T12:34:56.789Z",
  "message": "Request received",
  "log.level": "INFO",
  "process.thread.name": "http-nio-8080-exec-1",
  "service.name": "gatewaysrv",
  "service.environment": "dev",
  "event.dataset": "gatewaysrv"
}
```

---

## 最佳实践

### 1. 日志格式

使用结构化日志（JSON），方便查询和分析：

```java
// ❌ 不好
log.info("User {} logged in from {}", userId, ip);

// ✅ 好
log.info("User logged in",
    Fields.of("user_id", userId, "ip", ip));
```

### 2. 日志级别

| 级别 | 用途 |
|------|------|
| ERROR | 需要立即关注的错误 |
| WARN | 潜在问题，但服务可继续 |
| INFO | 关键业务流程（登录、订单、支付） |
| DEBUG | 调试信息（仅开发/测试环境） |
| TRACE | 最详细的跟踪信息 |

### 3. 敏感信息脱敏

```java
// ❌ 暴露密码
log.info("User {} login with password {}", user, password);

// ✅ 脱敏
log.info("User {} login", user);
```

### 4. 日志采样

高流量场景下，对 DEBUG/TRACE 日志进行采样：

```yaml
logging:
  level:
    root: INFO
    com.nexora.gateway: ${LOG_LEVEL:INFO}
```

---

## 故障排查

### Filebeat 无法连接 Elasticsearch

```bash
# 检查 Filebeat 日志
docker logs gatewaysrv-filebeat

# 检查 Elasticsearch 健康状态
curl -u elastic:Nexora@2026 http://localhost:30003/_cluster/health
```

### Kibana 看不到日志

1. 检查索引是否创建：
```bash
curl -u elastic:Nexora@2026 http://localhost:30003/_cat/indices?v | grep nexora-logs
```

2. 检查 Filebeat 是否正常运行：
```bash
docker ps | grep filebeat
```

3. 检查日志是否输出到容器：
```bash
docker logs gatewaysrv --tail 100
```

---

## 快速启动脚本

**infra/scripts/docker/enable-logging.sh**

```bash
#!/bin/bash
set -e

echo "配置日志收集..."

# 复制 Filebeat 配置模板到 infra
cp -r templates/filebeat config/docker/

# 重启相关服务
docker-compose restart elasticsearch kibana

echo "日志收集已启用，请按照各应用文档配置 Filebeat"
```
