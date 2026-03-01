## Context

当前架构中，Nacos 已部署但服务发现被禁用。服务地址通过 docker-compose.yml 环境变量硬编码：

```yaml
# deploy/docker-compose.yml 当前状态
environment:
  - GATEWAY_ROUTES_AUTHSRV_URL=http://authsrv:8101
  - GATEWAY_ROUTES_CHATSRV_URL=http://chatsrv:8102
  - LLM_SERVICE_URL=http://llmsrv:8106
  - ...
```

服务间调用使用 WebClient，但未启用 LoadBalancer，直接使用硬编码 URL。

## Goals / Non-Goals

**Goals:**
- 启用 Nacos 服务发现，服务启动时自动注册
- 网关通过 `lb://service-name` 动态路由
- 服务间调用通过服务名发现目标服务
- 移除所有硬编码服务地址

**Non-Goals:**
- 不修改 Nacos 服务器配置
- 不引入配置中心功能（保持 `config.enabled: false`）
- 不修改 Python llmsrv（无 Nacos 客户端）

## Decisions

### 1. 服务发现启用方式

**决定**: 使用 `spring.cloud.nacos.discovery.enabled: true`

**原因**:
- 依赖已添加，只需配置启用
- 与 Spring Cloud Gateway 的 `lb://` 路由方式一致

### 2. 服务间调用改造

**决定**: WebClient.Builder 添加 `@LoadBalanced` 注解

```java
@Bean
@LoadBalanced
public WebClient.Builder loadBalancedWebClientBuilder() {
    return WebClient.builder();
}
```

**原因**:
- 最小改动，保持现有 HTTP Client 接口不变
- Spring Cloud LoadBalancer 与 Nacos Discovery 自动集成

### 3. Nacos 地址配置

**决定**: 使用环境变量 `NACOS_SERVER_ADDR` 统一配置

- 本地开发: `localhost:30006`
- Docker 部署: `nacos:8848`

### 4. llmsrv 处理

**决定**: 保持 Docker DNS 方式，使用 `http://llmsrv:8106`

**原因**:
- Python 服务无 Spring Cloud Nacos 客户端
- 单实例部署，无需服务发现

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| Nacos 单点故障 | Nacos 已在 infra 中高可用部署；可考虑后续集群化 |
| 服务注册延迟 | 使用 healthcheck 确保服务就绪后再接受流量 |
| llmsrv 不可发现 | 网关直接路由到 llmsrv，其他服务通过 Docker DNS 访问 |
