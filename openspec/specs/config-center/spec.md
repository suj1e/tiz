## ADDED Requirements

### Requirement: 服务从 Nacos 加载配置

所有 Java 服务 SHALL 从 Nacos Config 加载配置。

#### Scenario: 服务启动加载共享配置
- **WHEN** 服务启动
- **THEN** 服务从 Nacos 加载 `common.yaml` 和 `${spring.application.name}.yaml`

#### Scenario: 配置优先级正确
- **WHEN** 同一配置项在多处定义
- **THEN** 优先级为：环境变量 > 服务配置 > 共享配置 > application.yaml

### Requirement: 多环境隔离

系统 SHALL 支持通过 Nacos Namespace 实现多环境隔离。

#### Scenario: 通过环境变量指定 namespace
- **WHEN** `NACOS_NAMESPACE=prod`
- **THEN** 服务从 `prod` namespace 加载配置

#### Scenario: 不同环境加载不同配置
- **WHEN** 服务在 dev 环境启动
- **THEN** 服务从 `dev` namespace 加载配置，连接 dev 数据库

### Requirement: 配置动态刷新

支持动态刷新的配置项 SHALL 在 Nacos 配置变更后自动生效。

#### Scenario: 日志级别动态调整
- **WHEN** 在 Nacos 中修改日志级别配置
- **THEN** 服务日志级别立即生效，无需重启

#### Scenario: 刷新通知
- **WHEN** Nacos 配置变更
- **THEN** 服务收到配置变更事件并应用新配置

### Requirement: 敏感信息保护

敏感配置项 SHALL 通过环境变量注入，不存储在 Nacos。

#### Scenario: 数据库密码从环境变量读取
- **WHEN** 服务需要数据库密码
- **THEN** 服务从 `SPRING_DATASOURCE_PASSWORD` 环境变量读取

#### Scenario: Nacos 配置不含敏感信息
- **WHEN** 查看 Nacos 中的配置文件
- **THEN** 配置中不包含明文密码或密钥
