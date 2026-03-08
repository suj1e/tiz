## Why

当前 tiz-backend 微服务目录使用 `*srv` 命名风格（如 `authsrv`, `contentsrv`），可读性差且不符合行业主流规范。重命名为 `*-service` 风格可提升代码可读性，与 Spring 社区主流实践保持一致。

## What Changes

- 重命名所有微服务目录，从 `*srv` 改为 `*-service`
- 更新 Gradle 项目名 (`rootProject.name`)
- 更新 Maven artifact ID
- 更新 Docker 镜像名
- 更新 CI/CD workflow 文件
- 更新文档引用

**BREAKING**: 所有依赖这些服务的配置需要同步更新

### 重命名映射

| 当前目录名         | 新目录名           |
|-------------------|-------------------|
| authsrv           | auth-service      |
| chatsrv           | chat-service      |
| contentsrv        | content-service   |
| gatewaysrv        | gateway-service   |
| llmsrv            | llm-service       |
| llmsrv-api        | llm-api           |
| practicesrv       | practice-service  |
| quizsrv           | quiz-service      |
| usersrv           | user-service      |
| common            | common (不变)      |

## Capabilities

### New Capabilities

无新增能力

### Modified Capabilities

- `service-naming`: 标准化微服务命名规范，使用 `*-service` 后缀

## Impact

**代码层面**:
- tiz-backend/ 下所有服务目录
- 各服务的 settings.gradle.kts
- 各服务的 build.gradle.kts
- common 模块中的依赖引用

**基础设施**:
- Docker 镜像名: `nxo/authsrv` → `nxo/auth-service`
- GitHub Actions workflow 文件名和内容
- docker-compose.yml 中的服务名

**文档**:
- CLAUDE.md 中的服务列表
- README.md（如有）
