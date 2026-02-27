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

**决定**: 每个服务是独立的 Gradle 项目，使用 api + app 子模块结构

```
tiz-backend/
├── common/                          # 精简的共享库（无子模块）
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
├── contentsrv/                      # 独立 Gradle 项目（api + app 子模块）
│   ├── settings.gradle.kts          # include("api", "app")
│   ├── build.gradle.kts             # 父配置
│   ├── gradle/
│   │   ├── libs.versions.toml
│   │   └── wrapper/
│   ├── api/                         # 公开 API（发布到 Maven Local）
│   │   ├── build.gradle.kts
│   │   └── src/main/java/io/github/suj1e/content/
│   │       ├── client/              # ContentClient
│   │       └── dto/                 # QuestionResponse, etc.
│   └── app/                         # 内部实现（不发布）
│       ├── build.gradle.kts
│       └── src/main/java/io/github/suj1e/content/
│           ├── ContentApplication.java
│           ├── controller/
│           ├── service/
│           └── repository/
│
├── gatewaysrv/                      # 网关不需要 api（不对外提供接口）
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   └── src/...
│
└── ...其他服务同理（authsrv, chatsrv, practicesrv, quizsrv, usersrv）
```

**api + app 子模块的优势**:
- api 模块独立发布到 Maven Local，其他服务依赖
- app 模块不发布，包含所有内部实现
- 清晰的公开/私有边界
- 支持并行开发（api 契约先定，app 实现后补）

**例外**:
- `common` 不需要子模块（纯共享库）
- `gatewaysrv` 不需要 api（不对外提供接口）
- `llmsrv` 是 Python 服务，其 Java api 在独立的 `llmsrv-api` 项目中

### 2. Client 位置

**决定**: Client 放在服务提供方的 `api` 子模块中

| Client | 移动到 |
|--------|--------|
| ContentClient | contentsrv/api/src/.../client/ |
| UserClient | usersrv/api/src/.../client/ |
| WebhookClient | usersrv/api/src/.../client/ |

**理由**: 契约由服务提供方维护，调用方依赖提供方的 api。

### 3. 依赖关系

**决定**: 通过 Maven Local 传递依赖

```kotlin
// practicesrv/app/build.gradle.kts
dependencies {
    implementation(project(":api"))              // 本地 api 子模块
    implementation("io.github.suj1e:common:1.0.0-SNAPSHOT")
    implementation("io.github.suj1e:contentsrv-api:1.0.0-SNAPSHOT")  // Maven Local
    implementation("io.github.suj1e:llmsrv-api:1.0.0-SNAPSHOT")      // Python 服务的 Java api
}
```

**构建顺序**:
1. `common:publishToMavenLocal`
2. `llmsrv-api:publishToMavenLocal`
3. 各服务的 `api:publishToMavenLocal`（可并行）
4. 各服务的 `app:compileJava`（可并行）

### 4. 包结构

**决定**: api 和 app 子模块使用相同的包名，但目录分离

```java
// api 子模块（发布到 Maven Local）
io.github.suj1e.content.client.ContentClient
io.github.suj1e.content.dto.QuestionResponse

// app 子模块（不发布）
io.github.suj1e.content.ContentApplication
io.github.suj1e.content.service.LibraryService
io.github.suj1e.content.entity.Question
```

**注意**: DTO 中不能依赖 entity 类（api 模块无法访问 app 模块的代码）

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
