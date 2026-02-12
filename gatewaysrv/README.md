# GatewaySrv

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.10-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.0.0-brightgreen.svg)](https://spring.io/projects/spring-cloud)
[![Spring Cloud Alibaba](https://img.shields.io/badge/Spring%20Cloud%20Alibaba-2025.0.0.0-brightgreen.svg)](https://github.com/alibaba/spring-cloud-alibaba)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.org/projects/jdk/21)

> 基于 Spring Cloud Gateway 的 API 网关
>
> 采用响应式架构 (WebFlux + Reactor)，通过 Nacos 实现配置中心和服务发现

---

## 快速开始

### 前置要求
- JDK 21+
- Docker
- Nacos 服务

### 本地运行

```bash
# 1. 配置环境变量
cp .env.example .env.local
# 编辑 .env.local，设置必需变量（NACOS_HOST、JWT_SECRET 等）

# 2. 启动
./run.sh dev
```

### Docker 构建

```bash
# 构建镜像
docker build -t gatewaysrv:latest .

# 运行
docker run -d \
  -e NACOS_HOST=your-nacos-host \
  -e JWT_SECRET=your-jwt-secret \
  -p 40004:40004 -p 40005:40005 \
  gatewaysrv:latest
```

---

## 配置架构

**两层配置设计**：通用配置在 `application.yml`，业务配置在 Nacos

| 位置 | 内容 | 示例 |
|------|------|------|
| `application.yml` | Bootstrap（不可变） | 端口、Nacos 连接 |
| Nacos | 业务配置（动态） | 路由、限流、JWT（使用环境变量占位符） |

### 必需环境变量

```bash
NACOS_HOST=nexora-nacos           # Nacos 服务地址
NACOS_PORT=8848
JWT_SECRET=xxx                    # JWT 密钥（Nacos 配置中使用 ${JWT_SECRET}）
```

### 可观测性配置

追踪和指标配置在 Nacos 中管理：
- **追踪**：OTLP 直接发送到 Tempo (`http://tempo:4317`)
- **指标**：Prometheus 抓取 `/actuator/prometheus` 端点

详细配置：
- [配置规范](docs/config-spec.md) - 完整配置说明
- [Nacos 配置指南](docs/nacos-config.md) - Nacos 使用指南

---

## 部署

项目产出标准 Docker 镜像，支持任意容器平台部署。

详细部署指南：[部署文档](docs/deployment.md)

### 快速启动

```bash
# 构建
docker build -t gatewaysrv:latest .

# 运行
docker run -d \
  -e NACOS_HOST=your-nacos-host \
  -e JWT_SECRET=your-jwt-secret \
  -p 40004:40004 -p 40005:40005 \
  gatewaysrv:latest
```

---

## 监控端点

| 端点 | 描述 |
|------|------|
| `/actuator/health` | 健康检查 |
| `/actuator/health/liveness` | 存活探针 |
| `/actuator/health/readiness` | 就绪探针 |
| `/actuator/prometheus` | Prometheus 指标 |

---

## 命令参考

```bash
./run.sh dev          # 前台启动
./run.sh bg dev       # 后台启动
./run.sh logs         # 查看日志
./run.sh stop         # 停止服务

./gradlew bootJar     # 构建 JAR
./gradlew test        # 运行测试
./gradlew qualityCheck # 测试 + 检查

docker build -t gatewaysrv:latest .  # 构建镜像
```

---

## 技术栈

| 组件 | 版本 |
|------|------|
| Spring Boot | 3.5.10 |
| Spring Cloud Gateway | 2025.0.0 |
| Spring Cloud Alibaba | 2025.0.0.0 |
| Java | 21 |

---

## 文档

| 文档 | 说明 |
|------|------|
| [配置规范](docs/config-spec.md) | 配置分层架构、环境变量、验证清单 |
| [Nacos 配置指南](docs/nacos-config.md) | Nacos 控制台操作、配置模板、常见问题 |
| [Nacos 配置模板](docs/nacos-config-template.yml) | 完整配置模板（直接复制到 Nacos） |
| [部署指南](docs/deployment.md) | Docker、Kubernetes、监控配置 |

---

## 许可证

Apache License 2.0
