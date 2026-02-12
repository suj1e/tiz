# Nexora 基础设施架构文档

> 事件驱动 + 最终一致性 + 可观测性

## 架构原则

- **事件优先**: 跨服务通过 Kafka 事件通信，而非同步调用
- **最终一致性**: 不引入分布式事务（Seata）
- **去中心化**: 避免强中心调度
- **可重放**: 关键动作可补偿、可回放
- **可观测性**: 全链路追踪

---

## 架构图

```
                        ┌─────────────────┐
                        │   API Gateway   │ ← 应用层
                        │  (鉴权/限流)      │
                        └────────┬────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
              ┌─────────┐  ┌─────────┐  ┌─────────┐
              │ Service │  │ Service │  │ Service │
              │    A    │  │    B    │  │    C    │
              └────┬────┘  └────┬────┘  └────┬────┘
                   │            │            │
                   └────────────┼────────────┘
                                │
                    ┌───────────▼───────────┐
                    │      Kafka (KRaft)    │ ← 事件中枢
                    └───────────┬───────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ Downstream    │    │   ES / Logs   │    │  Notifications│
│ Consumers     │    │   (分析)       │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   OTEL + Jaeger       │ ← 链路追踪
                    └───────────────────────┘
```

---

## 技术栈

| 分类 | 技术 | 版本 | 用途 |
|------|------|------|------|
| 注册/配置 | Nacos | 3.1.1 | 服务发现、配置中心 |
| 网关 | Spring Cloud Gateway | - | 鉴权、限流、灰度（应用层）|
| 消息队列 | Kafka | 7.8 (KRaft) | 事件中枢 |
| 任务调度 | Quartz | - | 时间驱动（应用层集群）|
| 数据库 | MySQL | 9.2 | 各服务私有 |
| 缓存 | Redis + Caffeine | 7.4 | 多级缓存 |
| 搜索 | Elasticsearch | 8.19.1 | 搜索/分析 |
| 分布式锁 | Redisson | - | 业务唯一性（应用层）|
| 限流 | Resilience4j | - | 稳定性（应用层）|
| Trace | OTEL + Jaeger | 0.119 / 1.62 | 全链路追踪 |

---

## 端口映射

| 服务 | 端口 | 说明 |
|------|------|------|
| MySQL | 30001 | 主数据库 |
| Redis | 30002 | 缓存服务 |
| Elasticsearch | 30003-30004 | ES API + 集群通信 |
| Kibana | 30005 | ES 可视化 |
| Nacos | 30006, 31006-31007 | 服务注册/配置中心 |
| Kafka | 30009 | 消息队列 (KRaft) |
| Kafka UI | 30010 | Kafka 管理界面 |
| OTEL Collector | 30011-30013 | Trace/Metrics 收集 |
| Jaeger UI | 30014 | 分布式追踪界面 |

---

## 服务说明

### 核心存储

**MySQL 9.2**
- 各服务私有数据库
- 支持 Outbox Pattern（事件一致性）
- Quartz 集群调度表

**Redis 7.4**
- 缓存 + 分布式锁
- 多级缓存：Caffeine (本地) → Redis (分布式)

**Elasticsearch 8.19.1**
- 日志聚合、全文搜索
- 配合 Kibana 进行数据可视化

### 中间件

**Nacos 3.1.1**
- 服务注册发现
- 配置中心（动态配置）
- 支持 MySQL 持久化

**Kafka 7.8 (KRaft 模式)**
- 事件驱动架构的核心
- 移除 ZooKeeper 依赖
- 支持 DLQ（死信队列）

### 可观测性

**OpenTelemetry Collector**
- 接收应用层的 Trace/Metrics
- 转发到 Jaeger

**Jaeger 1.62**
- 分布式追踪后端
- 链路可视化分析

---

## 事件驱动规范

### 事件模型

```json
{
  "eventId": "snowflake-id",
  "eventType": "ORDER_CREATED",
  "bizId": "orderId",
  "occurredAt": "ISO-8601",
  "payload": {}
}
```

### Topic 命名

```
{domain}.{entity}.{action}.v{version}

示例: order.order.created.v1
```

### Kafka 配置

```yaml
KAFKA_NODE_ID: 1
KAFKA_PROCESS_ROLES: broker,controller
KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
```

---

## Outbox Pattern

### 使用场景

- DB 与 Kafka 必须一致
- 不接受事件丢失

### 表设计

```sql
CREATE TABLE outbox_event (
  id BIGINT PRIMARY KEY,
  event_type VARCHAR(64),
  topic VARCHAR(128),
  biz_id VARCHAR(64),
  payload JSON,
  status VARCHAR(16),   -- NEW / SENT / FAILED
  retry_count INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### 标准流程

```
业务事务
  ↓
写业务表 + 写 Outbox（同事务）
  ↓
提交成功
  ↓
Quartz 扫描 Outbox
  ↓
投递 Kafka
  ↓
标记 SENT
```

---

## Quartz 集群

### 数据库表

- `QRTZ_JOB_DETAILS` - 任务定义
- `QRTZ_TRIGGERS` - 触发器
- `QRTZ_SCHEDULER_STATE` - 集群状态（心跳）
- `QRTZ_LOCKS` - 分布式锁

### 运行机制

```
应用节点 A ──┐
应用节点 B ──┼──► MySQL (协调)
应用节点 C ──┘

同一任务只被一个节点执行（抢锁）
```

---

## 链路追踪

### Trace 传递

| 场景 | 方式 |
|------|------|
| HTTP | `traceparent` Header |
| Kafka | Header 传递 |
| Quartz | Job 生成 Trace |

### 应用配置

```yaml
management:
  tracing:
    sampling:
      probability: 1.0
  otlp:
    endpoint: http://服务器IP:30011
```

---

## 已移除的组件

| 组件 | 原因 |
|------|------|
| Seata | 架构禁止分布式事务，改用最终一致性 |
| Sentinel | 改用 Resilience4j（应用层） |
| ElasticJob | 改用 Quartz（应用层集群） |
| ZooKeeper | Kafka 改用 KRaft 模式 |

---

## 数据流示例

### 订单创建流程

```
1. 用户请求 → Gateway
2. Gateway → Order Service
3. Order Service 写 DB + Outbox
4. Quartz 扫描 Outbox → 发送 Kafka 事件
5.下游消费者消费事件:
   - Payment Service
   - Notification Service
   - ES (搜索索引)
   - Analytics (数据分析)

全链路 Trace 记录在 Jaeger
```

---

## 内存规划

| 组件 | 内存 | 说明 |
|------|------|------|
| MySQL | ~200MB | 默认配置 |
| Redis | ~50MB | 默认配置 |
| Elasticsearch | ~512MB | 已限制 |
| Kibana | ~512MB | 已限制 |
| Nacos | ~256MB | 已限制 |
| Kafka | ~512MB | 已限制 |
| OTEL Collector | ~128MB | 新增 |
| Jaeger | ~256MB | 新增 |
| **总计** | **~2.5GB** | 16GB 内存绰绰有余 |

---

## 运维脚本

```bash
# 启动
./scripts/docker/start.sh

# 状态检查
./scripts/docker/status.sh

# 备份
./scripts/docker/backup.sh

# 停止
./scripts/docker/stop.sh
```

---

## 下一步

1. **应用层实现**: Gateway、Resilience4j、Quartz 集群
2. **Outbox Pattern**: 各服务实现事件表
3. **Trace 接入**: 应用集成 OTEL
4. **DLQ 配置**: Kafka 死信队列处理
