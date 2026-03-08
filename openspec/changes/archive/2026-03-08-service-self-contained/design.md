## Context

当前有 8 个微服务将分配给独立团队维护。每个服务需要能够独立理解、构建和运行。

**当前问题**:
- 6 个服务没有 README 文档
- 7 个服务没有 `.env.example` 模板
- 内部 API 版本号 (`1.0.0-SNAPSHOT`) 在多处硬编码
- 部分依赖版本硬编码 (QueryDSL, Spring Security, Spring Kafka)
- `application.yaml` 环境变量配置不一致

**约束**:
- 不改变现有功能，只改进开发体验
- 每个服务保持独立的 `libs.versions.toml`（独立团队维护）
- 保持向后兼容

## Goals / Non-Goals

**Goals:**
- 每个服务有自包含的 README 和 `.env.example`
- 统一环境变量配置模式
- 内部 API 依赖纳入 version catalog 管理
- 消除硬编码版本号

**Non-Goals:**
- 不创建共享的 gradle 配置文件（各团队独立维护）
- 不改变服务间通信方式
- 不升级任何依赖版本

## Decisions

### D1: 每个服务维护独立的 `libs.versions.toml`

**决定**: 每个服务保留自己的 version catalog，但内容保持一致。

**理由**:
- 独立团队可以自主升级依赖
- 不需要协调所有团队同步修改
- 新服务可以直接复制模板

**替代方案**:
- ❌ 共享 `gradle/catalog.toml` - 增加协调成本，不符合独立团队原则

### D2: 内部 API 命名规范

**决定**: 使用短名 `auth-api`, `content-api` 等，而不是 `authsrv-api`。

```toml
# libs.versions.toml
[libraries]
common = { module = "io.github.suj1e:common", version.ref = "common" }
auth-api = { module = "io.github.suj1e:auth-api", version.ref = "auth-api" }
content-api = { module = "io.github.suj1e:content-api", version.ref = "content-api" }
llm-api = { module = "io.github.suj1e:llm-api", version.ref = "llm-api" }
user-api = { module = "io.github.suj1e:user-api", version.ref = "user-api" }
```

**理由**: 简洁，与 Maven artifactId 一致。

### D3: README 模板结构

**决定**: 使用统一的 README 结构，包含以下章节：

1. 服务概述（一句话说明职责）
2. 依赖服务（其他服务、中间件）
3. 环境变量表格
4. 本地开发命令
5. API 模块说明（如果有的话）

### D4: `.env.example` 格式

**决定**: 包含所有环境变量，带注释说明，使用示例值或占位符。

```bash
# Database
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/tiz
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=<your-password>

# Required
JWT_SECRET=<your-jwt-secret>
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 各服务 version catalog 漂移 | 提供 `libs.versions.toml` 模板，文档化 |
| README 过时 | 在 PR 模板中提醒更新 README |
| 内部 API 版本升级需要协调 | 版本号在 catalog 中集中管理，易于追踪 |

## Migration Plan

1. **Phase 1**: 更新 `libs.versions.toml`（所有服务同步）
2. **Phase 2**: 更新 `app/build.gradle.kts` 使用 catalog
3. **Phase 3**: 添加 README 和 `.env.example`
4. **Phase 4**: 统一 `application.yaml` 环境变量格式

**回滚**: 每个阶段独立提交，可单独回滚。

## Open Questions

无。
