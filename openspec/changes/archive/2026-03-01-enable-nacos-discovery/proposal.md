## Why

当前 Nacos 服务发现被禁用（`discovery.enabled: false`），所有服务地址通过环境变量硬编码到 docker-compose.yml 中。这导致：
- 服务扩缩容需要手动修改配置
- 无法利用 Nacos 的健康检查和自动摘除能力
- 服务间调用依赖 Docker DNS，与网关的 `lb://` 路由方式不一致

## What Changes

- 启用所有 Java 服务的 Nacos 服务发现（`discovery.enabled: true`）
- 修改 WebClient 配置，使用 `@LoadBalanced` 支持服务名解析
- 移除 docker-compose.yml 中的硬编码服务地址环境变量
- 统一使用 `NACOS_SERVER_ADDR` 环境变量配置 Nacos 地址

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- **service-discovery**: 启用 Nacos 服务发现，服务自动注册与发现

## Impact

**配置文件修改：**
- `tiz-backend/*/app/src/main/resources/application.yaml` (7 个服务)
- `tiz-backend/gatewaysrv/src/main/resources/application.yaml`
- `deploy/docker-compose.yml`

**代码修改：**
- `*ClientConfig.java` - 添加 `@LoadBalanced` 注解 (4-5 个文件)

**涉及服务：**
- gatewaysrv, authsrv, chatsrv, contentsrv, practicesrv, quizsrv, usersrv
