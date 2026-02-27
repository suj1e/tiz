## Why

当前 tiz-backend 虽然有多个服务目录，但实际上是一个 Gradle 多项目，所有服务共享依赖版本，common 模块包含了 client 代码，这违反了微服务自治原则。

重构为真正的微服务架构，让每个服务独立构建、独立管理依赖，common 只保留纯共享代码。

## What Changes

**BREAKING** - 架构级重构

- 删除根目录的 `settings.gradle.kts` 和 `build.gradle.kts`
- 删除根目录的 `gradle/libs.versions.toml`
- 精简 common 模块：移除 client 代码，只保留共享的基础类
- 每个 Java 服务成为独立的 Gradle 项目：
  - 添加自己的 `settings.gradle.kts`
  - 添加自己的 `build.gradle.kts`
  - 添加自己的 `gradle/libs.versions.toml`
  - 添加自己的 `gradle/wrapper/`
- 将 client 移到对应服务的 `api` 包下：
  - `ContentClient` → `contentsrv/src/main/java/.../api/client/`
  - `UserClient`, `WebhookClient` → `usersrv/src/main/java/.../api/client/`
- 服务依赖关系：通过 Maven Local 引用其他服务的 api

## Capabilities

### New Capabilities

无新增功能能力，纯架构重构。

### Modified Capabilities

无修改的能力需求，只是代码组织结构变化。

## Impact

- **构建方式**: 每个服务需要单独构建，不能再从根目录构建所有服务
- **依赖管理**: 每个服务独立管理依赖版本
- **发布流程**: 服务 api 需要先发布到 Maven Local，其他服务才能引用
- **开发体验**: 需要先 `./gradlew publishToMavenLocal` 发布依赖的服务

## 影响的服务

| 服务 | 变化 |
|------|------|
| common | 精简，移除 client |
| authsrv | 独立 Gradle 项目 |
| contentsrv | 独立 Gradle 项目，接收 ContentClient |
| usersrv | 独立 Gradle 项目，接收 UserClient/WebhookClient |
| chatsrv | 独立 Gradle 项目 |
| practicesrv | 独立 Gradle 项目 |
| quizsrv | 独立 Gradle 项目 |
| gatewaysrv | 独立 Gradle 项目 |
| llmsrv | 不变（Python 服务） |
