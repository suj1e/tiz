# QA - 质量保证

测试相关配置和脚本。

## 目录结构

```
qa/
├── k6/              # K6 性能测试
│   ├── load-test.js         # 通用负载测试脚本
│   ├── load-test.sh         # 负载测试执行脚本
│   ├── load-test-auth.sh    # 认证接口压力测试
│   └── benchmark.sh         # 快速基准测试
└── jmh/             # JMH 微基准测试 (待实现)
```

## K6 性能测试

### 安装 K6

```bash
# macOS
brew install k6

# Linux
sudo apt-get install k6

# 或使用二进制包
curl https://github.com/grafana/k6/releases/download/v0.50.0/k6-v0.50.0-linux-amd64.tar.gz -L | tar xvz
```

### 测试场景

| 场景 | 描述 | VUs | 时长 | 用途 |
|------|------|-----|------|------|
| smoke | 冒烟测试 | 10 | 30s | 快速验证基本功能 |
| load | 负载测试 | 10→100 | 10min | 模拟正常业务负载 |
| stress | 压力测试 | 10→500 | 15min | 寻找系统极限 |
| spike | 峰值测试 | 10→1000→10 | 5min | 测试突发流量 |
| soak | 浸泡测试 | 100 | 1hour | 长时间稳定性测试 |

### 使用方法

#### 冒烟测试（快速验证）

```bash
# 本地测试
cd qa/k6
./load-test.sh -s smoke

# 指定目标
TARGET_URL=http://api.example.com ./load-test.sh -s smoke
```

#### 负载测试

```bash
# 完整负载测试
./load-test.sh -s load

# 指定目标
TARGET_URL=http://test-api.example.com ./load-test.sh -s load
```

#### 压力测试

```bash
# 压力测试（找极限）
./load-test.sh -s stress
```

#### 峰值测试

```bash
# 突发流量测试
./load-test.sh -s spike
```

#### 浸泡测试

```bash
# 长时间稳定性测试
./load-test.sh -s soak
```

#### 自定义测试

```bash
# 自定义并发和时长
./load-test.sh -s custom -v 50 -d 10m
```

### 认证测试

```bash
# 设置 Token
export TOKEN="your-jwt-token-here"
export TARGET_URL="http://localhost:40004"

# 运行认证压测
./load-test-auth.sh
```

### 快速基准测试

```bash
# 使用 wrk（推荐）
brew install wrk
./benchmark.sh

# 或使用 hey
brew install hey
./benchmark.sh

# 或使用 ab (Apache Bench)
brew install ab
./benchmark.sh
```

## 测试端点

负载测试脚本会随机访问以下端点：

| 端点 | 方法 | 认证 | 描述 |
|------|------|------|------|
| `/actuator/health` | GET | 否 | 健康检查 |
| `/api/v1/auth/login` | POST | 否 | 登录 |
| `/api/v1/seqra/meals` | GET | 是 | 膳食列表 |
| `/api/v1/seqra/recommend` | GET | 是 | 推荐服务 |
| `/api/v1/mix/data` | GET | 是 | Mix 数据 |

## 性能指标

### 目标指标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| P50 响应时间 | < 100ms | 50% 请求 |
| P95 响应时间 | < 500ms | 95% 请求 |
| P99 响应时间 | < 1000ms | 99% 请求 |
| 错误率 | < 1% | HTTP 5xx |
| 吞吐量 | > 1000 req/s | 取决于配置 |

### 查看报告

```bash
# 测试完成后，报告保存在 ./reports/ 目录
ls -la reports/

# 查看报告
k6 archive reports/k6_load_20250202_123456.json --output report.html

# 或使用在线查看器
# https://k6.io/open-source/
```

## 集成测试（待实现）

### API 集成测试

```bash
# TODO: 使用 Postman/Newman 运行集成测试
npm install -g newman
newman run qa/postman/collection.json
```

### 混沌工程（待实现）

```bash
# TODO: 使用 Chaos Mesh 进行混沌测试
kubectl apply -f qa/chaos/network-delay.yaml
kubectl apply -f qa/chaos/pod-kill.yaml
```

## CI/CD 集成

### GitHub Actions

```yaml
# .github/workflows/performance-test.yml
name: Performance Test

on:
  pull_request:
    paths:
      - 'src/**'
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨 2 点运行

jobs:
  k6-smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: grafana/k6-action@v0.3.1
        with:
          filename: qa/k6/load-test.js
        env:
          TARGET_URL: http://localhost:40004
        args: --stage 10s:10 --stage 20s:10
```

## 故障排查

### 连接被拒绝

```bash
# 检查服务是否运行
curl http://localhost:40004/actuator/health

# 检查端口
lsof -i :40004
```

### 认证失败

```bash
# 检查 Token
echo $TOKEN

# 获取新 Token
curl -X POST http://localhost:40004/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'
```

### 高错误率

```bash
# 查看服务日志
kubectl logs -f deployment/gatewaysrv -n <namespace>

# 检查资源使用
kubectl top pods -n <namespace> -l app=gatewaysrv

# 检查 HPA 状态
kubectl get hpa -n <namespace>
```

## 性能调优建议

### JVM 参数

```bash
JAVA_OPTS="
  -XX:+UseG1GC
  -XX:MaxRAMPercentage=75.0
  -XX:+UseStringDeduplication
  -XX:MaxGCPauseMillis=200
  -XX:+AlwaysPreTouch
"
```

### Netty 连接池

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        pool:
          type: elastic
          max-connections: 500
        connect-timeout: 3000
        response-timeout: 30s
```

### HPA 配置

```yaml
# 根据压测结果调整
spec:
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```
