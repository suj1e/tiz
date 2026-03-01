## Context

经过探索讨论，确定新的部署架构方案。

### 当前问题

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          当前架构问题                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   1. 依赖构建耦合                                                           │
│      Dockerfile.java 硬编码: common → llmsrv-api → contentsrv-api → 服务   │
│      每次构建都重建所有依赖，缓存无效                                         │
│                                                                             │
│   2. 网络混乱                                                               │
│      npass (172.20.x.x) + tiz-network (172.28.x.x) + tiz-backend (172.29.x.x)
│      IP 硬编码，配置复杂                                                     │
│                                                                             │
│   3. 流水线耦合                                                             │
│      一个 matrix 构建所有服务，改动一个触发全部重建                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Goals / Non-Goals

**Goals:**
- Library 独立发布到 GitHub Packages
- 服务按需触发构建
- 网络统一，配置简化
- Dockerfile 极简化

**Non-Goals:**
- Kubernetes 部署
- 多环境 (dev/staging/prod)

## Decisions

### D1: Library 发布到 GitHub Packages

**决策**: common, llmsrv-api, contentsrv-api 发布到 GitHub Packages

**理由:**
- 与 GitHub 仓库集成，私有免费
- GITHUB_TOKEN 自动认证
- 解耦服务构建

**配置:**
```kotlin
// build.gradle.kts
publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/suj1e/tiz")
            credentials {
                username = System.getenv("GITHUB_ACTOR") ?: "token"
                password = System.getenv("GITHUB_TOKEN")
            }
        }
    }
}
```

### D2: 网络统一到 npass

**决策**: 所有服务加入 npass 网络，移除 tiz-network 和 tiz-backend

**理由:**
- 简化网络配置
- 使用 DNS 名称代替 IP
- 与 npass 反向代理无缝集成

**架构:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          npass 网络                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   基础设施: mysql, redis, kafka, nacos, elasticsearch                       │
│   微服务: gatewaysrv, authsrv, chatsrv, contentsrv, practicesrv,            │
│           quizsrv, llmsrv, usersrv                                          │
│   前端: tiz-web                                                             │
│                                                                             │
│   所有服务通过 DNS 名称互访 (如 mysql:3306, authsrv:8101)                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### D3: Base Image + 独立 Dockerfile

**决策**: 创建 base-jre 基础镜像，每个服务独立 Dockerfile

**理由:**
- 服务 Dockerfile 极简 (~15行)
- 安全补丁统一更新
- 构建速度快

**Base Image:**
```dockerfile
# tiz-backend/docker/Dockerfile.base-jre
FROM eclipse-temurin:21-jre-alpine
RUN apk add --no-cache ca-certificates curl tzdata && \
    addgroup -S tiz && adduser -S -G tiz tiz
WORKDIR /app
USER tiz
```

**服务 Dockerfile:**
```dockerfile
# tiz-backend/authsrv/Dockerfile
FROM ghcr.io/suj1e/tiz/base-jre:21 AS runtime
COPY --from=builder /build/app/build/libs/*.jar app.jar
EXPOSE 8101
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### D4: 独立流水线 (方案A)

**决策**: 每个服务独立 workflow 文件

**理由:**
- 清晰隔离，易于调试
- 按需触发，精确控制
- 依赖关系通过 workflow_call 传递

**流水线结构:**
```
.github/workflows/
├── lib-publish.yml          # Library 发布
├── base-images.yml          # 基础镜像 (每周/手动)
├── srv-authsrv.yml          # authsrv
├── srv-chatsrv.yml          # chatsrv
├── srv-contentsrv.yml       # contentsrv
├── srv-practicesrv.yml      # practicesrv
├── srv-quizsrv.yml          # quizsrv
├── srv-usersrv.yml          # usersrv
├── srv-gatewaysrv.yml       # gatewaysrv
├── srv-llmsrv.yml           # llmsrv (Python)
├── web-tiz-web.yml          # tiz-web
└── deploy.yml               # 部署
```

**触发逻辑:**
```
common 变更 → lib-publish.yml → 触发所有依赖服务
服务变更 → srv-*.yml → 只构建该服务
Tag 推送 → deploy.yml → 部署
```

### D5: Gradle 配置统一

**决策**:
- common gradle-wrapper: 8.5 → 9.3.1
- 每个项目添加 gradle.properties

**gradle.properties 内容:**
```properties
org.gradle.jvmargs=-Xmx2g
org.gradle.parallel=true
org.gradle.caching=true
version=1.0.0-SNAPSHOT
group=io.github.suj1e
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| workflow 文件多 (15个) | 使用模板，逻辑统一 |
| GitHub Packages 需要认证 | CI 中自动注入 GITHUB_TOKEN |
| base image 需要定期更新 | 设置每周自动构建 |

## Migration Plan

### 阶段 1: 基础配置
1. 统一 Gradle 版本
2. 添加 gradle.properties
3. 配置 GitHub Packages 发布

### 阶段 2: 网络重构
1. 修改 infra/docker-compose.yml
2. 修改 deploy/docker-compose.yml
3. 验证服务互通

### 阶段 3: Dockerfile 重构
1. 创建 base-jre Dockerfile
2. 创建服务独立 Dockerfile
3. 删除旧 Dockerfile

### 阶段 4: 流水线重构
1. 创建 lib-publish.yml
2. 创建 srv-*.yml
3. 更新 deploy.yml
4. 验证 CI/CD

### 阶段 5: 验证
1. 完整构建测试
2. 部署测试
3. 归档此 change
