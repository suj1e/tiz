# GatewaySrv 部署指南

本文档描述 GatewaySrv 的部署方式和最佳实践。

---

## 部署架构

```
                                    ┌─────────────┐
                                    │   Client    │
                                    └──────┬──────┘
                                           │
                                           ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Nacos     │────▶│  Gateway    │────▶│   Backend   │     │   Tempo     │
│  (Config +  │     │  (Multiple  │     │   Services  │     │  (Tracing)  │
│  Discovery) │     │  Instances) │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │   Redis     │
                     │  (Rate Lim) │
                     └─────────────┘
```

---

## 前置条件

### 依赖服务

| 服务 | 用途 | 端口 |
|------|------|------|
| Nacos | 配置中心 + 服务发现 | 8848 |
| Redis | 分布式限流 | 6379 |
| Tempo | 分布式追踪 (可选) | 4317 |
| Prometheus | 指标采集 (可选) | 9090 |

### 必需环境变量

```bash
NACOS_HOST=<nacos-host>           # Nacos 地址
NACOS_PORT=8848
JWT_SECRET=<jwt-secret-key>       # JWT 签名密钥
```

### 可选环境变量

```bash
SPRING_PROFILES_ACTIVE=dev        # 环境标识
REDIS_HOST=<redis-host>           # Redis 地址
REDIS_PASSWORD=<password>         # Redis 密码
```

---

## Docker 部署

### 构建镜像

**基础构建**（使用默认 Maven 仓库）：
```bash
docker build -t gatewaysrv:latest .
```

**使用私有 Maven 仓库**（CI/CD 流水线）：
```bash
docker build \
  --build-arg MAVEN_USERNAME=<用户名> \
  --build-arg MAVEN_PASSWORD=<密码> \
  -t gatewaysrv:latest .
```

**切换到其他 Maven 仓库**：
```bash
docker build \
  --build-arg MAVEN_USERNAME=<用户名> \
  --build-arg MAVEN_PASSWORD=<密码> \
  --build-arg MAVEN_REPO_URL=<仓库URL> \
  -t gatewaysrv:latest .
```

**构建参数说明**：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `MAVEN_USERNAME` | Maven 仓库用户名 | - |
| `MAVEN_PASSWORD` | Maven 仓库密码 | - |
| `MAVEN_REPO_URL` | Maven 仓库地址 | 阿里云 Packages (在 build.gradle.kts 中配置) |

### 运行容器

```bash
docker run -d \
  --name gatewaysrv \
  -e NACOS_HOST=nexora-nacos \
  -e NACOS_PORT=8848 \
  -e JWT_SECRET=your-secret-key \
  -p 40004:40004 \
  -p 40005:40005 \
  gatewaysrv:latest
```

### 健康检查

```bash
# 存活探针
curl http://localhost:40004/actuator/health/liveness

# 就绪探针
curl http://localhost:40004/actuator/health/readiness

# 指标端点
curl http://localhost:40004/actuator/prometheus
```

---

## Kubernetes 部署

### Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: gateway
```

### Secret (敏感数据)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gatewaysrv-secret
  namespace: gateway
type: Opaque
stringData:
  jwt-secret: "your-jwt-secret-key-here"
  redis-password: "your-redis-password"
```

### ConfigMap (非敏感配置)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gatewaysrv-config
  namespace: gateway
data:
  SPRING_PROFILES_ACTIVE: "prod"
  NACOS_HOST: "nexora-nacos"
  NACOS_PORT: "8848"
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatewaysrv
  namespace: gateway
  labels:
    app: gatewaysrv
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gatewaysrv
  template:
    metadata:
      labels:
        app: gatewaysrv
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "40005"
        prometheus.io/path: "/actuator/prometheus"
    spec:
      containers:
      - name: gatewaysrv
        image: gatewaysrv:latest
        imagePullPolicy: Always
        ports:
        - name: http
          containerPort: 40004
          protocol: TCP
        - name: management
          containerPort: 40005
          protocol: TCP
        env:
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: gatewaysrv-secret
              key: jwt-secret
        - name: NACOS_HOST
          valueFrom:
            configMapKeyRef:
              name: gatewaysrv-config
              key: NACOS_HOST
        - name: NACOS_PORT
          valueFrom:
            configMapKeyRef:
              name: gatewaysrv-config
              key: NACOS_PORT
        - name: SPRING_PROFILES_ACTIVE
          valueFrom:
            configMapKeyRef:
              name: gatewaysrv-config
              key: SPRING_PROFILES_ACTIVE
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: management
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: management
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: gatewaysrv
  namespace: gateway
  labels:
    app: gatewaysrv
spec:
  type: ClusterIP
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  - name: management
    port: 40005
    targetPort: management
    protocol: TCP
  selector:
    app: gatewaysrv
```

### Ingress (可选)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gatewaysrv-ingress
  namespace: gateway
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - gateway.example.com
    secretName: gateway-tls
  rules:
  - host: gateway.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gatewaysrv
            port:
              number: 80
```

---

## Docker Compose 部署

```yaml
version: '3.8'

services:
  gatewaysrv:
    image: gatewaysrv:latest
    container_name: gatewaysrv
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - NACOS_HOST=nexora-nacos
      - NACOS_PORT=8848
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - "40004:40004"
      - "40005:40005"
    depends_on:
      - nexora-nacos
      - nexora-redis
    networks:
      - nexora-net
    restart: unless-stopped

networks:
  nexora-net:
    external: true
```

---

## 部署验证

### 配置验证

```bash
# 检查 Nacos 配置加载
curl http://localhost:40004/actuator/env | jq '.propertySources[]'

# 检查路由配置
curl http://localhost:40004/actuator/gateway/routes | jq
```

### 健康检查

```bash
# 综合健康检查
curl http://localhost:40004/actuator/health | jq

# 检查各组件健康状态
curl http://localhost:40004/actuator/health | jq '.components'
```

### 功能测试

```bash
# 测试路由转发
curl http://localhost:40004/api/v1/auth/health

# 测试限流（连续请求）
for i in {1..20}; do
  curl -w "\n" http://localhost:40004/api/v1/auth/login
done
```

---

## 监控配置

### Prometheus ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: gatewaysrv
  namespace: gateway
  labels:
    app: gatewaysrv
spec:
  selector:
    matchLabels:
      app: gatewaysrv
  endpoints:
  - port: management
    path: /actuator/prometheus
    interval: 30s
```

### 关键指标

| 指标 | 说明 |
|------|------|
| `gateway_requests_seconds` | 请求延迟 |
| `gateway_requests_total` | 请求总数 |
| `resilience4j_circuitbreaker_state` | 熔断器状态 |
| `resilience4j_ratelimiter_available` | 限流可用许可 |

---

## 故障排查

### 常见问题

| 症状 | 可能原因 | 排查方法 |
|------|----------|----------|
| 启动失败 | Nacos 连接失败 | 检查 `NACOS_HOST`/`NACOS_PORT` |
| 路由不生效 | Nacos 配置未加载 | 检查 Data ID 命名 |
| 限流失效 | Redis 连接失败 | 检查 Redis 连接 |
| 健康检查失败 | 后端服务不可用 | 检查服务注册状态 |

### 日志查看

```bash
# Kubernetes
kubectl logs -f deployment/gatewaysrv -n gateway

# Docker
docker logs -f gatewaysrv
```

---

## 安全建议

1. **Secret 管理**: 使用 Kubernetes Secret 或外部密钥管理系统
2. **网络隔离**: 使用 NetworkPolicy 限制 Pod 间通信
3. **最小权限**: ServiceAccount 使用最小 RBAC 权限
4. **镜像扫描**: 定期扫描镜像漏洞
5. **资源限制**: 设置合理的 requests/limits

---

*最后更新: 2026-02-04*
