## REMOVED Requirements

### Requirement: 服务从 Nacos 加载配置
- **Reason**: 改用环境变量管理配置，更简单透明
- **Migration**: 删除 `spring.cloud.nacos.config` 配置块，配置通过环境变量注入，Spring Boot 自动映射

### Requirement: 配置动态刷新
- **Reason**: 接受改配置需重启，日志级别调整不频繁
- **Migration**: 删除 `@RefreshScope` 注解（如有），配置变更后重启服务

## MODIFIED Requirements

### Requirement: 敏感信息通过环境变量注入

敏感信息 SHALL 通过环境变量注入，不硬编码在配置文件中。

#### Scenario: 数据库密码从环境变量读取
- **WHEN** 服务需要数据库密码
- **THEN** 服务从 `SPRING_DATASOURCE_PASSWORD` 环境变量读取

#### Scenario: JWT 密钥从环境变量读取
- **WHEN** 服务需要 JWT 密钥
- **THEN** 服务从 `JWT_SECRET` 环境变量读取

#### Scenario: 生产环境无默认值
- **WHEN** 部署到生产环境
- **THEN** 敏感配置必须显式设置，无默认值

## ADDED Requirements

### Requirement: 服务配置通过环境变量管理

所有服务配置 SHALL 通过环境变量管理，在 `docker-compose.yml` 中显式声明。

#### Scenario: docker-compose.yml 声明所有配置
- **WHEN** 查看 docker-compose.yml
- **THEN** 所有配置项以 `${VAR:-default}` 格式声明
- **AND** 开发环境有合理默认值

#### Scenario: 环境特定配置通过 .env 文件
- **WHEN** 部署到特定环境
- **THEN** 读取对应 `.env.{env}` 文件覆盖默认值

### Requirement: 每个服务独立管理环境配置

每个服务 SHALL 在自己的目录下管理 `.env.*` 文件。

#### Scenario: 服务目录结构
- **WHEN** 查看服务目录
- **THEN** 存在 `.env.dev`、`.env.staging`、`.env.prod` 文件
- **AND** 文件包含该服务需要的环境特定配置

#### Scenario: 服务可独立部署
- **WHEN** 需要单独部署某个服务
- **THEN** 该服务目录包含完整配置，无需依赖外部配置文件
