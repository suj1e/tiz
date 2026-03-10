## Context

当前代码库存在两套服务目录命名规范：
- `xxx-service`（如 auth-service, chat-service）- 新规范，有 svc.sh 脚本
- `xxxsrv`（如 authsrv, chatsrv）- 旧规范，已废弃

需要清理旧目录，并为所有服务创建本地 staging 测试配置。

**Staging 基础设施端口映射：**
| 服务 | Docker 内部 | 本地映射 |
|------|------------|---------|
| MySQL | mysql:3306 | localhost:30001 |
| Redis | redis:6379 | localhost:30002 |
| Kafka | kafka:9092 | localhost:30009 |
| Nacos | nacos:8848 | localhost:30848 |

## Goals / Non-Goals

**Goals:**
- 删除所有 `xxxsrv` 目录，统一使用 `xxx-service` 命名
- 为 8 个服务创建 `.env.staging` 配置文件
- 验证所有服务能按依赖顺序启动
- 验证前端能连接本地 gateway

**Non-Goals:**
- 不修改任何业务代码
- 不构建或推送 Docker 镜像
- 不部署到远程环境

## Decisions

### 1. 目录清理策略
- **决定**: 直接删除所有 `xxxsrv` 目录
- **理由**: 这些目录没有 svc.sh 脚本，说明已废弃；新的 `xxx-service` 目录有完整的构建脚本

### 2. 环境配置格式
- **决定**: 每个 `.env.staging` 文件使用相同的模板结构
- **理由**: 统一格式便于维护，各服务只需修改特定配置

### 3. 服务启动顺序
- **决定**: 按依赖关系分三批启动
  - 批次 1: auth-service, user-service, content-service, practice-service, quiz-service
  - 批次 2: llm-service, chat-service
  - 批次 3: gateway
- **理由**: gateway 依赖其他服务注册到 Nacos 后才能正确路由

## Risks / Trade-offs

| 风险 | 缓解措施 |
|-----|---------|
| 删除 xxxsrv 目录可能丢失未迁移的代码 | 启动前检查两套目录的差异，确认新目录有完整代码 |
| Nacos 刚重启，服务注册可能失败 | 等待 Nacos 完全启动后再启动服务 |
| 服务间依赖导致启动失败 | 按依赖顺序启动，观察日志 |

## 发现的问题 (2026-03-10)

### 问题 1: JAR 文件未构建
- **影响**: 除 auth-service 外，其他 7 个服务都没有构建 JAR 文件
- **原因**: 启动脚本直接使用 `java -jar`，但 JAR 文件不存在
- **解决**: 需要先执行 `gradle :app:bootJar` 构建所有服务

### 问题 2: auth-service WebClient.Builder Bean 缺失
- **影响**: auth-service 启动失败
- **错误信息**: `No qualifying bean of type 'org.springframework.web.reactive.function.client.WebClient$Builder'`
- **原因**: `WebClientConfig` 配置类存在，但可能：
  1. 未被正确打包到 JAR 中
  2. Spring Boot 4.x 自动配置变更导致 WebClient.Builder 不再自动注册
- **解决**: 需要检查 Spring Boot 4.x 的 WebClient 自动配置，或显式声明 bean

### 问题 3: 环境变量名称不一致
- **影响**: Spring Boot 无法读取数据库密码
- **原因**: `.env.staging` 使用 `MYSQL_PASSWORD`，但 Spring Boot 需要 `SPRING_DATASOURCE_PASSWORD`
- **状态**: ✅ 已修复

- **修复时间**: 2026-03-10 00:53

### 问题 4: Nacos gRPC 端口映射错误
- **影响**: 服务无法连接 Nacos，报错 `Client not connected, current status:STARTING`
- **原因**: Nacos 3.x SDK 自动计算 gRPC 端口 = HTTP API 端口 + 1000
  - 配置 `NACOS_SERVER_ADDR=localhost:30848`
  - SDK 尝试连接 gRPC 端口 31848
  - 但 Docker 映射是 `31006:9848`（不匹配）
- **解决**: 修改端口映射为 `31848:9848`
- **状态**: ✅ 已修复
- **修复时间**: 2026-03-10 07:46

### 问题 5: JAR 文件过期
- **影响**: auth-service 启动失败，找不到 WebClient.Builder bean
- **原因**: `WebClientConfig.class` 已编译但未打包到 JAR 中
- **解决**: 执行 `gradle :app:bootJar` 重新构建 JAR
- **状态**: ✅ 已修复
- **修复时间**: 2026-03-10 07:47

### 问题 6: Redis 密码变量名错误
- **影响**: Spring Boot 无法读取 Redis 密码
- **原因**: `.env.staging` 使用 `REDIS_PASSWORD`， 但 Spring Boot 需要 `SPRING_DATA_REDIS_PASSWORD`
- **状态**: ✅ 已修复
- **修复时间**: 2026-03-10 08:01

### 问题 7: QueryDSL 版本冲突 (待修复)
- **影响**: content-service, practice-service, quiz-service 启动失败
- **错误信息**: `The calling method's class hierarchy... io.github.suj1e.common.config.QuerydslConfig and com.querydsl.jpa.impl.JPAQueryFactory`
- **原因**: common 模块和 querydsl-jpa 版本不兼容
- **状态**: ⏳ 待修复

## 修复验证

| 问题 | 服务 | 验证结果 |
|------|------|--------|
| WebClient.Builder | auth-service | ✅ 启动成功 |
| Nacos gRPC | auth-service | ✅ 已注册到 Nacos |
| DataSource URL | user-service | ✅ 启动成功 |

## 当前服务启动状态

| 服务 | 端口 | 状态 |
|------|------|------|
| auth-service | 8101 | ✅ 运行中 |
| user-service | 8107 | ✅ 运行中 |
| content-service | 8103 | ❌ QueryDSL 冲突 |
| practice-service | 8104 | ❌ QueryDSL 冲突 |
| quiz-service | 8105 | ❌ QueryDSL 冲突 |
| chat-service | 8106 | ⏳ 未启动 |
| gateway | 8080 | ⏳ 未启动 |
| llm-service | 8106 | ⏳ Python 服务，
