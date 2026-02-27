## Why

当前后端服务（authsrv、chatsrv、contentsrv、practicesrv、quizsrv、llmsrv、usersrv、gatewaysrv）散落在 tiz 根目录，与前端（tiz-web）、基础设施（infra）等混杂，结构不够清晰。

将所有后端服务统一到 `tiz-backend` 目录，可以实现：
- 清晰的 monorepo 结构，前后端分离
- 独立的后端构建配置（Gradle 多项目）
- 更好的代码组织和可维护性

## What Changes

- 创建 `tiz-backend/` 目录
- 移动所有后端服务到 `tiz-backend/`:
  - `authsrv/` → `tiz-backend/authsrv/`
  - `chatsrv/` → `tiz-backend/chatsrv/`
  - `contentsrv/` → `tiz-backend/contentsrv/`
  - `practicesrv/` → `tiz-backend/practicesrv/`
  - `quizsrv/` → `tiz-backend/quizsrv/`
  - `llmsrv/` → `tiz-backend/llmsrv/`
  - `usersrv/` → `tiz-backend/usersrv/`
  - `gatewaysrv/` → `tiz-backend/gatewaysrv/`
  - `common/` → `tiz-backend/common/`
- 移动 Gradle 配置文件到 `tiz-backend/`:
  - `build.gradle.kts` → `tiz-backend/build.gradle.kts`
  - `settings.gradle.kts` → `tiz-backend/settings.gradle.kts`
  - `gradle/` → `tiz-backend/gradle/`
- 更新 .gitignore 路径

## Capabilities

### New Capabilities

无新增能力，纯重构。

### Modified Capabilities

无修改的能力，只是代码组织结构变化。

## Impact

- **代码路径**: 所有后端服务路径变更
- **构建**: Gradle 根目录从 `tiz/` 变为 `tiz/tiz-backend/`
- **开发工作流**: 开发后端时需要 `cd tiz-backend`
- **CI/CD**: 可能需要更新构建脚本路径
- **IDE**: 需要重新导入 Gradle 项目
