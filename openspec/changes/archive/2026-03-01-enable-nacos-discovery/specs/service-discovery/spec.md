## ADDED Requirements

### Requirement: 服务自动注册到 Nacos

所有 Java 服务启动时 SHALL 自动注册到 Nacos 服务注册中心。

#### Scenario: 服务启动成功注册
- **WHEN** Java 服务启动完成
- **THEN** 服务在 Nacos 中可见，服务名为 `spring.application.name`

#### Scenario: 服务停止自动注销
- **WHEN** Java 服务正常停止
- **THEN** 服务从 Nacos 中自动移除

### Requirement: 网关通过服务发现路由

Spring Cloud Gateway SHALL 通过 Nacos 服务发现解析后端服务地址。

#### Scenario: lb 路由解析成功
- **WHEN** 网关收到请求匹配 `lb://servicename` 路由
- **THEN** 网关从 Nacos 获取服务实例并转发请求

#### Scenario: 服务不可用时返回错误
- **WHEN** Nacos 中无可用服务实例
- **THEN** 网关返回 503 Service Unavailable

### Requirement: 服务间调用支持服务发现

服务间 HTTP 调用 SHALL 通过服务名发现目标服务。

#### Scenario: WebClient 使用服务名
- **WHEN** 服务使用 WebClient 调用 `http://contentsrv:8103`
- **THEN** 请求被 LoadBalancer 解析到实际服务实例

### Requirement: 环境变量配置 Nacos 地址

服务 SHALL 通过 `NACOS_SERVER_ADDR` 环境变量配置 Nacos 地址。

#### Scenario: Docker 环境连接 Nacos
- **WHEN** `NACOS_SERVER_ADDR=nacos:8848`
- **THEN** 服务连接到 Docker 网络中的 Nacos

#### Scenario: 本地开发连接 Nacos
- **WHEN** `NACOS_SERVER_ADDR=localhost:30006`
- **THEN** 服务连接到本地 Nacos
