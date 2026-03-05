## ADDED Requirements

### Requirement: SNAPSHOT 版本发布到 Snapshot 仓库

当模块版本包含 "SNAPSHOT" 时，系统 SHALL 将其发布到阿里云 Snapshot 仓库。

#### Scenario: 发布 SNAPSHOT 版本
- **WHEN** 模块版本为 `1.0.0-SNAPSHOT`
- **AND** 执行 `./gradlew publish`
- **THEN** 构建产物发布到 `https://packages.aliyun.com/.../snapshot-qazpfx`

### Requirement: RELEASE 版本发布到 Release 仓库

当模块版本不包含 "SNAPSHOT" 时，系统 SHALL 将其发布到阿里云 Release 仓库。

#### Scenario: 发布 RELEASE 版本
- **WHEN** 模块版本为 `1.0.0`
- **AND** 执行 `./gradlew publish`
- **THEN** 构建产物发布到 `https://packages.aliyun.com/.../release-epshtr`

### Requirement: 本地开发认证支持

系统 SHALL 支持通过 `~/.gradle/gradle.properties` 配置阿里云仓库凭据。

#### Scenario: 使用本地凭据发布
- **WHEN** `~/.gradle/gradle.properties` 包含 `aliyunMavenUsername` 和 `aliyunMavenPassword`
- **AND** 未设置环境变量 `ALIYUN_MAVEN_USERNAME`
- **THEN** 系统使用 gradle.properties 中的凭据

### Requirement: CI/CD 环境变量认证支持

系统 SHALL 支持通过环境变量 `ALIYUN_MAVEN_USERNAME` 和 `ALIYUN_MAVEN_PASSWORD` 配置凭据。

#### Scenario: 使用环境变量凭据发布
- **WHEN** 设置了环境变量 `ALIYUN_MAVEN_USERNAME` 和 `ALIYUN_MAVEN_PASSWORD`
- **THEN** 系统使用环境变量中的凭据

### Requirement: 消费端从阿里云拉取依赖

各服务 SHALL 配置阿里云 Snapshot 和 Release 仓库，以拉取 common 和其他 api 模块。

#### Scenario: 拉取 SNAPSHOT 依赖
- **WHEN** 服务依赖 `io.github.suj1e:common:1.0.0-SNAPSHOT`
- **AND** 本地 Maven Local 不存在该依赖
- **THEN** 系统从阿里云 Snapshot 仓库拉取

#### Scenario: 拉取 RELEASE 依赖
- **WHEN** 服务依赖 `io.github.suj1e:common:1.0.0`
- **THEN** 系统从阿里云 Release 仓库拉取

### Requirement: GitHub Actions 按路径触发发布

每个可发布单元 SHALL 有独立的 workflow 文件，仅当对应路径变更时触发发布。

#### Scenario: common 变更触发发布
- **WHEN** 推送代码到 main 分支
- **AND** 变更路径包含 `tiz-backend/common/**`
- **THEN** 触发 `publish-common.yml` workflow

#### Scenario: 服务 api 变更触发发布
- **WHEN** 推送代码到 main 分支
- **AND** 变更路径包含 `tiz-backend/contentsrv/api/**`
- **THEN** 触发 `publish-contentsrv-api.yml` workflow

#### Scenario: 非发布路径变更不触发
- **WHEN** 推送代码到 main 分支
- **AND** 变更路径仅包含 `tiz-backend/contentsrv/app/**`
- **THEN** 不触发任何发布 workflow
