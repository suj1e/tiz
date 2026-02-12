# Authsrv QA - 质量保证

认证服务的测试配置和脚本。

## 目录结构

```
qa/
├── k6/                      # K6 性能测试
│   ├── load-test.js         # 认证服务负载测试脚本
│   ├── load-test.sh         # 负载测试执行脚本
│   └── benchmark.sh         # 快速基准测试
└── jmh/                     # JMH 微基准测试 (待实现)
```

## 认证服务测试场景

| 场景 | 描述 | VUs | 时长 | 用途 |
|------|------|-----|------|------|
| smoke | 冒烟测试 | 10 | 30s | 快速验证基本功能 |
| load | 负载测试 | 10→100 | 10min | 模拟正常业务负载 |
| stress | 压力测试 | 10→500 | 15min | 寻找系统极限 |
| spike | 峰值测试 | 10→1000→10 | 5min | 测试突发流量 |
| soak | 浸泡测试 | 100 | 1hour | 长时间稳定性测试 |

## 测试端点

| 端点 | 方法 | 认证 | 描述 |
|------|------|------|------|
| `/actuator/health` | GET | 否 | 健康检查 |
| `/api/v1/auth/register` | POST | 否 | 用户注册 |
| `/api/v1/auth/login` | POST | 否 | 用户登录 |
| `/api/v1/auth/refresh` | POST | 否 | 刷新令牌 |
| `/api/v1/auth/logout` | POST | 是 | 用户登出 |
| `/api/v1/users/me` | GET | 是 | 获取当前用户 |
| `/api/v1/users/me` | PUT | 是 | 更新用户信息 |
| `/api/v1/roles` | GET | 是 | 获取角色列表 |

## 快速开始

### 安装 K6

```bash
# macOS
brew install k6

# Linux
sudo apt-get install k6

# 验证安装
k6 version
```

### 冒烟测试（快速验证）

```bash
# 本地测试
cd qa/k6
./load-test.sh -s smoke

# 指定目标
TARGET_URL=http://localhost:40006 ./load-test.sh -s smoke
```

### 负载测试

```bash
# 完整负载测试
./load-test.sh -s load

# 指定目标
TARGET_URL=http://test-api.example.com ./load-test.sh -s load
```

### 压力测试

```bash
# 压力测试（找极限）
./load-test.sh -s stress
```

### 峰值测试

```bash
# 突发流量测试
./load-test.sh -s spike
```

### 浸泡测试

```bash
# 长时间稳定性测试
./load-test.sh -s soak
```

### 自定义测试

```bash
# 自定义并发和时长
./load-test.sh -s custom -v 50 -d 10m
```

## 快速基准测试

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

## 性能指标

### 目标指标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| P50 响应时间 | < 50ms | 50% 请求 |
| P95 响应时间 | < 200ms | 95% 请求 |
| P99 响应时间 | < 500ms | 99% 请求 |
| 错误率 | < 0.1% | HTTP 5xx |
| 登录吞吐量 | > 500 req/s | 取决于配置 |
| Token 验证吞吐量 | > 5000 req/s | 取决于配置 |

### 查看报告

```bash
# 测试完成后，报告保存在 ./reports/ 目录
ls -la reports/

# 查看报告
k6 archive reports/k6_load_20250209_123456.json --output report.html

# 或使用在线查看器
# https://k6.io/open-source/
```

## 认证测试配置

### 设置测试账号

```bash
# 使用默认测试账号
export TEST_USERNAME=admin
export TEST_PASSWORD=admin123

# 或自定义账号
export TEST_USERNAME=testuser
export TEST_PASSWORD=Test@123456
```

### JWT Token 测试

```bash
# 设置 Token
export TOKEN="your-jwt-token-here"
export TARGET_URL="http://localhost:40006"

# 运行认证压测
./load-test.sh -s load
```

## CI/CD 集成

### GitHub Actions

```yaml
# .github/workflows/performance-test.yml
name: Authsrv Performance Test

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
          TARGET_URL: http://localhost:40006
          TEST_USERNAME: admin
          TEST_PASSWORD: admin123
        args: --stage 10s:10 --stage 20s:10
```

## 故障排查

### 连接被拒绝

```bash
# 检查服务是否运行
curl http://localhost:40006/actuator/health

# 检查端口
lsof -i :40006
```

### 认证失败

```bash
# 检查测试账号
echo $TEST_USERNAME
echo $TEST_PASSWORD

# 获取新 Token
curl -X POST http://localhost:40006/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 高错误率

```bash
# 查看服务日志
kubectl logs -f deployment/authsrv -n <namespace>

# 检查资源使用
kubectl top pods -n <namespace> -l app=authsrv

# 检查 HPA 状态
kubectl get hpa -n <namespace>
```

### 数据库连接池耗尽

```bash
# 检查数据库连接数
SHOW PROCESSLIST;

# 调整 Hikari 连接池配置
# 在 Nacos authsrv-datasource.yaml 中调整
spring:
  datasource:
    hikari:
      maximum-pool-size: 50
      minimum-idle: 10
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

### 数据库连接池

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 50
      minimum-idle: 10
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

### Redis 缓存

```yaml
spring:
  data:
    redis:
      lettuce:
        pool:
          max-active: 20
          max-idle: 10
          min-idle: 5
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
  - type: Resource
    resource:
      name: memory
      target:
        averageUtilization: 80
```

## 安全测试

### 暴力破解防护测试

```bash
# 测试登录失败锁定机制
for i in {1..10}; do
  curl -X POST http://localhost:40006/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"wrong"}'
done

# 验证账号被锁定
curl -X POST http://localhost:40006/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Token 过期测试

```bash
# 获取 Token
TOKEN=$(curl -s -X POST http://localhost:40006/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | jq -r '.accessToken')

# 等待 Token 过期（默认 15 分钟）
sleep 900

# 验证 Token 过期
curl -X GET http://localhost:40006/api/v1/users/me \
  -H "Authorization: Bearer $TOKEN"
```

### SQL 注入测试

```bash
# 使用 sqlmap 测试
sqlmap -u "http://localhost:40006/api/v1/auth/login" \
  --data='{"username":"admin","password":"test"}' \
  --headers='{"Content-Type":"application/json"}'
```
