## Context

当前 tiz-backend 结构：

```
tiz-backend/
├── settings.gradle.kts      # 管理所有子项目（单体特征）
├── build.gradle.kts         # 根构建配置
├── common/
│   └── client/              # 所有服务间调用的 Client
├── authsrv/                 # 依赖 common 的版本目录
├── contentsrv/              # 依赖 common 的版本目录
└── ...
```

**问题**：
1. 所有服务共享同一份依赖版本 → 无法独立升级
2. common 包含 client → 耦合度高
3. Gradle 多项目 → 实际上是一个大项目

## Goals / Non-Goals

**Goals:**
- 每个服务成为独立的 Gradle 项目
- 每个服务独立管理依赖版本
- common 精简为纯共享代码库
- client 移到对应服务的 api 包下
- 服务间通过 Maven Local 依赖 api

**Non-Goals:**
- 不改变服务功能代码
- 不改变 API 接口
- 不拆分为独立仓库

## Decisions

### 1. 目录结构

**决定**: 每个服务是独立的 Gradle 项目

```
tiz-backend/
├── common/                          # 精简的共享库
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   ├── gradle/
│   │   ├── libs.versions.toml
│   │   └── wrapper/
│   └── src/main/java/io/github/suj1e/common/
│       ├── annotation/              # @NoAuth, @CurrentUserId
│       ├── config/                  # JacksonConfig, JpaAuditingConfig
│       ├── entity/                  # BaseEntity, SoftDeletableEntity
│       ├── error/                   # ErrorCode, CommonErrorCode
│       ├── exception/               # BusinessException, NotFoundException
│       ├── response/                # ApiResponse, PagedResponse
│       └── util/                    # 工具类
│
├── contentsrv/                      # 独立 Gradle 项目
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   ├── gradle/
│   │   ├── libs.versions.toml
│   │   └── wrapper/
│   └── src/main/java/io/github/suj1e/content/
│       ├── api/                     # 公开 API
│       │   ├── client/              # ContentClient
│       │   └── dto/                 # QuestionResponse, etc.
│       └── internal/                # 内部实现
│           ├── ContentApplication.java
│           ├── controller/
│           ├── service/
│           └── repository/
│
└── ...其他服务同理
```

**替代方案**:
- api/service 分开为子模块 → 拒绝，对当前规模过度设计
- 完全独立仓库 → 拒绝，增加管理成本

### 2. Client 位置

**决定**: Client 放在服务提供方的 `api` 包下

| Client | 移动到 |
|--------|--------|
| ContentClient | contentsrv/src/.../api/client/ |
| UserClient | usersrv/src/.../api/client/ |
| WebhookClient | usersrv/src/.../api/client/ |

**理由**: 契约由服务提供方维护，调用方依赖提供方的 api。

### 3. 依赖关系

**决定**: 通过 Maven Local 传递依赖

```kotlin
// practicesrv/build.gradle.kts
dependencies {
    implementation(project(":common"))           // 本地 common
    implementation("io.github.suj1e:contentsrv:1.0.0-SNAPSHOT")  // Maven Local
    implementation("io.github.suj1e:llmsrv-api:1.0.0-SNAPSHOT")  // Python 服务的 Java api
}
```

**构建顺序**:
1. `common:publishToMavenLocal`
2. `contentsrv:publishToMavenLocal`
3. `usersrv:publishToMavenLocal`
4. 其他服务

### 4. 包结构

**决定**: 使用 `api` 和 `internal` 包区分公开和私有

```java
// 公开 API（其他服务可依赖）
io.github.suj1e.content.api.client.ContentClient
io.github.suj1e.content.api.dto.QuestionResponse

// 内部实现（不对外暴露）
io.github.suj1e.content.internal.ContentApplication
io.github.suj1e.content.internal.service.LibraryService
```

## Risks / Trade-offs

**风险 1**: 构建顺序复杂化
→ 解决: 提供构建脚本或文档说明顺序

**风险 2**: 版本不一致风险
→ 解决: 各服务独立管理，但初始版本保持一致

**风险 3**: 重构工作量大
→ 解决: 分服务逐步重构，每个服务独立提交

## Migration Plan

1. 精简 common 模块
2. 重构 contentsrv（作为模板）
3. 重构 usersrv
4. 重构 authsrv
5. 重构 chatsrv
6. 重构 practicesrv
7. 重构 quizsrv
8. 重构 gatewaysrv
9. 删除根目录 Gradle 配置
10. 更新文档
