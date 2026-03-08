## ADDED Requirements

### Requirement: Each service has a README file

每个微服务 SHALL 在服务根目录包含 `README.md` 文件，提供服务的自包含文档。

#### Scenario: New team member can understand service purpose
- **WHEN** 新团队成员阅读 README
- **THEN** 能在第一段理解服务职责和定位

#### Scenario: README lists all dependencies
- **WHEN** 查看 README 依赖章节
- **THEN** 能看到该服务依赖的所有其他服务和中间件（MySQL, Redis, Kafka, Nacos 等）

### Requirement: README documents environment variables

README SHALL 包含环境变量表格，列出所有必需和可选的环境变量。

#### Scenario: Required variables are clearly marked
- **WHEN** 查看环境变量表格
- **THEN** 必需变量有明确标记（如 `Required` 或 `(必填)`）

#### Scenario: Default values are documented
- **WHEN** 环境变量有默认值
- **THEN** 默认值在表格中显示

### Requirement: README documents development commands

README SHALL 包含常用开发命令，包括构建、测试、运行。

#### Scenario: Build command is documented
- **WHEN** 查看命令章节
- **THEN** 包含 `./svc.sh build` 或等效命令

#### Scenario: Run command is documented
- **WHEN** 查看命令章节
- **THEN** 包含 `./svc.sh run` 或等效命令

### Requirement: README documents API module if exists

如果服务有 `api/` 模块发布到 Maven，README SHALL 说明如何引用。

#### Scenario: Maven coordinates are documented
- **WHEN** 服务有 API 模块
- **THEN** README 显示 Maven 坐标（groupId:artifactId:version）
