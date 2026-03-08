## ADDED Requirements

### Requirement: Service directory naming convention

所有微服务目录 SHALL 使用 `*-service` 后缀命名格式。

#### Scenario: Standard service naming
- **WHEN** 创建新的微服务目录
- **THEN** 目录名 SHALL 使用 `<name>-service` 格式（如 `user-service`, `auth-service`）

#### Scenario: API module naming
- **WHEN** 创建独立的 API 模块（非服务）
- **THEN** 模块名 SHALL 使用 `<name>-api` 格式（如 `llm-api`）

### Requirement: Gradle project naming

Gradle 项目名 SHALL 与目录名保持一致。

#### Scenario: Project name matches directory
- **WHEN** 查看服务的 settings.gradle.kts
- **THEN** `rootProject.name` SHALL 与目录名相同

### Requirement: Maven artifact naming

Maven artifact ID SHALL 与服务名保持一致。

#### Scenario: Artifact ID format
- **WHEN** 发布服务到 Maven 仓库
- **THEN** artifact ID SHALL 使用 `<name>-service` 或 `<name>-api` 格式

### Requirement: Docker image naming

Docker 镜像名 SHALL 使用 `nxo/<name>-service` 格式。

#### Scenario: Docker image format
- **WHEN** 构建 Docker 镜像
- **THEN** 镜像名 SHALL 使用 `registry.cn-hangzhou.aliyuncs.com/nxo/<name>-service` 格式
