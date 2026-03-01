## Context

Tiz 项目已完成前后端开发，需要部署到生产环境。当前状态：
- 基础设施（MySQL、Redis、Kafka、Nacos）已通过 `infra/docker-compose-lite.yml` 部署
- npass 反向代理已部署，支持通配符 SSL 证书 (*.dmall.ink)
- 前端有 Dockerfile (nginx)，llmsrv 有 Dockerfile
- Java 服务缺少 Dockerfile 和容器化配置
- 缺少 CI/CD 自动化

**约束条件：**
- 单机部署，资源有限
- 使用 GitHub Container Registry (ghcr.io)
- 域名：tiz.dmall.ink (前端)、api.tiz.dmall.ink (API)
- 需要复用现有的 npass 和基础设施

## Goals / Non-Goals

**Goals:**
- 建立 Tag 触发的 CI/CD 流水线
- 所有服务容器化
- 通过 npass 暴露服务
- 支持零停机更新

**Non-Goals:**
- Kubernetes 部署（未来考虑）
- 多环境部署（dev/staging/prod）
- 自动化测试（后续添加）

## Decisions

### D1: 镜像存储 - GitHub Container Registry

**决策**: 使用 ghcr.io 存储镜像

**理由:**
- 与 GitHub 仓库集成，无需额外配置
- 私有仓库免费
- GITHUB_TOKEN 自动认证

**格式:**
```
ghcr.io/suj1e/tiz/tiz-web:latest
ghcr.io/suj1e/tiz/gatewaysrv:latest
ghcr.io/suj1e/tiz/authsrv:latest
...
```

### D2: 部署触发 - Tag 触发

**决策**: 使用 Git Tag 触发部署

**理由:**
- 明确的版本控制
- 避免误部署
- 支持回滚到任意版本

**流程:**
```bash
git tag v1.0.0
git push origin v1.0.0
# → 自动构建 → 自动部署
```

### D3: 服务编排 - Docker Compose

**决策**: 使用 docker-compose-app.yml 管理应用服务

**理由:**
- 与现有 infra 保持一致
- 简单易维护
- 支持声明式配置

**服务清单:**
| 服务 | 端口 | 网络 |
|------|------|------|
| tiz-web | 80 | npass |
| gatewaysrv | 8080 | npass, tiz-backend |
| authsrv | 8101 | tiz-backend |
| chatsrv | 8102 | tiz-backend |
| contentsrv | 8103 | tiz-backend |
| practicesrv | 8104 | tiz-backend |
| quizsrv | 8105 | tiz-backend |
| llmsrv | 8106 | tiz-backend |
| usersrv | 8107 | tiz-backend |

### D4: 网络架构

**决策**: 双网络隔离

```
┌─────────────────────────────────────────────────────────────┐
│                         npass                                │
│  (外部访问: tiz.dmall.ink, api.tiz.dmall.ink)               │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
   ┌────┴────┐                         ┌─────┴─────┐
   │ tiz-web │                         │gatewaysrv │
   │ (nginx) │                         │  :8080    │
   └─────────┘                         └─────┬─────┘
                                             │
                                    ┌────────┴────────┐
                                    │  tiz-backend    │
                                    │  (内部网络)      │
                                    └────────┬────────┘
                                             │
              ┌──────────┬──────────┬────────┴────────┬──────────┬──────────┐
              │          │          │                 │          │          │
         ┌────┴────┐┌────┴────┐┌────┴────┐     ┌────┴────┐┌────┴────┐┌────┴────┐
         │ authsrv ││ chatsrv ││contentsr│     │ quizsrv ││ llmsrv ││ usersrv │
         └─────────┘└─────────┘└─────────┘     └─────────┘└─────────┘└─────────┘
```

### D5: Java 服务 Dockerfile

**决策**: 通用多阶段 Dockerfile

```dockerfile
# 构建阶段
FROM gradle:8.12-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle :app:bootJar --no-daemon

# 运行阶段
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/app/build/libs/*.jar app.jar
EXPOSE ${PORT}
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 单点故障 | 定期备份，监控告警 |
| 部署中断服务 | 滚动更新（后续优化） |
| 镜像过大 | 使用 alpine 基础镜像，多阶段构建 |
| Secrets 泄露 | GitHub Secrets 加密存储 |

## Migration Plan

### 阶段 1: 准备工作
1. 配置 GitHub Secrets
2. 创建 Java Dockerfile
3. 创建 docker-compose-app.yml
4. 更新 npass nginx.conf

### 阶段 2: 首次部署
1. 手动构建测试镜像
2. 启动应用服务
3. 验证服务可访问

### 阶段 3: CI/CD 上线
1. 创建 GitHub Actions workflow
2. 测试 Tag 触发
3. 验证自动部署

### 回滚策略
```bash
# 回滚到指定版本
git tag v1.0.1  # 基于 v1.0.0 修复
git push origin v1.0.1
# 或手动
docker-compose -f docker-compose-app.yml pull
docker-compose -f docker-compose-app.yml up -d
```

## Open Questions

1. ~~是否需要健康检查端点？~~ → 需要，Spring Boot Actuator 已提供
2. 日志收集方案？（当前 docker json-file，后续考虑 ELK）
3. 监控告警方案？（后续考虑）
