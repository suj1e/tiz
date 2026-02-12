# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Nexora Infrastructure** is an event-driven infrastructure platform supporting both Docker Compose (development/testing) and Kubernetes (production) deployments. The architecture emphasizes **eventual consistency** over distributed transactions, with full observability via OpenTelemetry tracing.

### Architecture Principles

- **Event-First**: Cross-service communication via Kafka events, not synchronous calls
- **No Distributed Transactions**: Seata was intentionally removed; use Outbox Pattern for DB-Kafka consistency
- **Application-Layer Resilience**: Sentinel/ElasticJob removed in favor of Resilience4j/Quartz clustering
- **Kafka KRaft Mode**: ZooKeeper removed; Kafka uses KRaft for metadata management

## Common Commands

### Docker Compose Operations

```bash
# Pre-download images (reads from docker-compose.yml)
./scripts/docker/pull-images.sh

# Start all services (uses --pull never, requires images to exist)
./scripts/docker/start.sh

# Check service health and resource usage
./scripts/docker/status.sh

# Stop all services
./scripts/docker/stop.sh

# Backup data (MySQL, Nacos config, Redis, ES)
./scripts/docker/backup.sh
```

### Kubernetes Operations

```bash
# Deploy to Kubernetes
./scripts/k8s/deploy.sh

# Delete all resources
./scripts/k8s/delete.sh

# Check deployment status
kubectl get all -n nexora-infra

# View logs
kubectl logs -f deployment/<name> -n nexora-infra
```

### Direct Docker Commands

```bash
# View logs for a specific service
docker-compose logs -f [service]

# View resource usage
docker stats

# Exec into a container
docker exec -it nexora-redis redis-cli -a "Nexora@2026"
docker exec -it nexora-mysql mysql -u root -pNexora@2026
```

## Service Access

| Service | Port | Credentials |
|---------|------|-------------|
| MySQL | 30001 | root/Nexora@2026 |
| Redis | 30002 | password: `Nexora@2026` |
| Elasticsearch | 30003 | elastic/Nexora@2026 |
| Kibana | 30005 | kibana_system/g+bEkV*2AxbWMhXT=Gpk |
| Nacos | 30006 | nacos/nacos |
| Kafka | 30009 | - |
| Kafka UI | 30010 | - |
| Tempo (Tracing) | 30014 | - |
| Grafana | 30018 | admin/Nexora@2026 |

## Network Architecture

### Docker Compose Network
- **Network**: `nexora-network` (172.28.0.0/16)
- **Storage**: Bind mounts to `/opt/dev/dockermnt/{service}` (NOT Docker volumes)

**Fixed IP Allocation**:
```
172.28.0.10  MySQL
172.28.0.11  Redis
172.28.0.12  Elasticsearch
172.28.0.13  Kibana
172.28.0.14  Nacos
172.28.0.15  Kafka
172.28.0.16  Kafka UI
172.28.0.18  Tempo
172.28.0.19  Grafana
```

### Kubernetes Namespace
- **Namespace**: `nexora-infra`
- Services use Cluster-internal DNS for discovery

## Startup Phases (Docker Compose)

The `start.sh` script uses phased rollout to ensure dependencies are ready:

1. **Phase 1**: MySQL + Redis (30s wait)
2. **Phase 2**: Elasticsearch (60s wait)
3. **Phase 3**: Kibana + Nacos + Kafka (40s wait)
4. **Phase 4**: Kafka UI + Tempo + Grafana (20s wait)

## Key Configuration Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Main orchestration with health checks |
| `config/docker/redis/redis.conf` | Redis config (1GB max, LRU eviction) |
| `config/docker/mysql/init/` | SQL initialization scripts |
| `config/docker/grafana/provisioning/` | Grafana datasources (auto-provisioned) |
| `config/k8s/components/*/` | Kubernetes manifests per service |

## Event-Driven Architecture

### Topic Naming Convention
```
{domain}.{entity}.{action}.v{version}

Example: order.order.created.v1
```

### Outbox Pattern for DB-Kafka Consistency

When a service needs to publish events and update DB atomically:

1. Write business tables + `outbox_event` table in same transaction
2. Quartz job scans `outbox_event` for `status=NEW`
3. Publish to Kafka, mark as `SENT`

**Standard Outbox Table**:
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

### Trace Propagation

| Scenario | Method |
|----------|--------|
| HTTP | `traceparent` header |
| Kafka | Headers |
| Quartz | Generate new trace context |

**OTEL Endpoint**: `http://serverIP:30011` (or `http://otel-collector:4317` within Docker network)

## Components Status

| Component | Version | Notes |
|-----------|---------|-------|
| MySQL | 9.2 | Using DaoCloud mirror |
| Redis | 7.4-alpine | 1GB max memory, LRU eviction |
| Elasticsearch | 8.19.1 | xpack.security enabled |
| Nacos | 3.1.1 | MySQL-backed persistence |
| Kafka | 7.8 | KRaft mode (no ZooKeeper) |
| Tempo | latest | Distributed tracing |
| Grafana | latest | Pre-provisioned datasources |

### Intentionally Removed

- **Seata**: Distributed transactions prohibited; use eventual consistency
- **Sentinel**: Use application-layer Resilience4j
- **ElasticJob**: Use application-layer Quartz clustering
- **ZooKeeper**: Kafka uses KRaft mode
- **Jaeger**: Replaced by Tempo (config files may still reference Jaeger)

## Commit Convention

This project uses emoji-based conventional commits. Examples:
- `✨ feat:` - New feature
- `🐛 fix:` - Bug fix
- `📝 docs:` - Documentation
- `♻️ refactor:` - Code refactoring

## Troubleshooting

### Elasticsearch fails to start
```bash
sudo sysctl -w vm.max_map_count=262144
```

### Check service health
```bash
./scripts/docker/status.sh
```

### View logs for a service
```bash
docker-compose logs -f [service]
```

## Memory Optimization (16GB System)

Current allocation: ~3GB total
- MySQL: ~200MB
- Redis: 1GB max (with LRU)
- Elasticsearch: 512MB (Xms/Xmx limited)
- Kibana: 512MB (NODE_OPTIONS limited)
- Nacos: 256MB (JVM limited)
- Kafka: 512MB (heap limited)
- Tempo/Grafana: Minimal

## Documentation Language

Most documentation files (README.md, docs/) are in **Chinese**. When updating docs, maintain the existing language convention.
