## ADDED Requirements

### Requirement: Service script provides build commands

服务脚本 SHALL 支持本地构建命令。

#### Scenario: Build Java service
- **WHEN** 执行 `./svc.sh build`
- **THEN** 脚本 SHALL 执行 `gradle :app:build` 构建 JAR

#### Scenario: Build Python service
- **WHEN** 在 Python 服务目录执行 `./svc.sh build`
- **THEN** 脚本 SHALL 执行 `pixi build` 或等效命令

### Requirement: Service script provides test command

服务脚本 SHALL 支持测试命令。

#### Scenario: Run tests
- **WHEN** 执行 `./svc.sh test`
- **THEN** 脚本 SHALL 执行测试并输出结果

### Requirement: Service script provides run command

服务脚本 SHALL 支持本地运行命令。

#### Scenario: Run service locally
- **WHEN** 执行 `./svc.sh run`
- **THEN** 脚本 SHALL 启动服务并监听配置端口

#### Scenario: Run with specific environment
- **WHEN** 执行 `./svc.sh run --env staging`
- **THEN** 脚本 SHALL 加载 `.env.staging` 环境变量

### Requirement: Service script provides publish command

Java 服务脚本 SHALL 支持发布 API 到 Maven 仓库。

#### Scenario: Publish API to Maven
- **WHEN** 执行 `./svc.sh publish`
- **THEN** 脚本 SHALL 执行 `gradle :api:publish` 发布到 Aliyun Maven

### Requirement: Service script provides image command

服务脚本 SHALL 支持 Docker 镜像操作。

#### Scenario: Build and push image
- **WHEN** 执行 `./svc.sh image`
- **THEN** 脚本 SHALL 构建 Docker 镜像并推送到 registry

#### Scenario: Build image only
- **WHEN** 执行 `./svc.sh image --local`
- **THEN** 脚本 SHALL 只构建镜像，不推送

### Requirement: Service script provides version management

服务脚本 SHALL 支持版本管理。

#### Scenario: Show current version
- **WHEN** 执行 `./svc.sh version`
- **THEN** 脚本 SHALL 显示当前版本号

#### Scenario: Bump version
- **WHEN** 执行 `./svc.sh version bump`
- **THEN** 脚本 SHALL 增加 patch 版本号

### Requirement: Service script provides status and logs

服务脚本 SHALL 支持运维命令。

#### Scenario: Check service health
- **WHEN** 执行 `./svc.sh status`
- **THEN** 脚本 SHALL 检查服务健康状态

#### Scenario: View logs
- **WHEN** 执行 `./svc.sh logs`
- **THEN** 脚本 SHALL 显示服务日志

### Requirement: Service script provides validation

服务脚本 SHALL 支持配置验证。

#### Scenario: Validate configuration
- **WHEN** 执行 `./svc.sh validate`
- **THEN** 脚本 SHALL 检查必要的环境变量和凭证配置

### Requirement: Service script provides help

服务脚本 SHALL 提供帮助信息。

#### Scenario: Show help
- **WHEN** 执行 `./svc.sh help`
- **THEN** 脚本 SHALL 显示所有可用命令和用法说明
