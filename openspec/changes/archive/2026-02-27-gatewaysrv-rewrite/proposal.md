# gatewaysrv-rewrite

## Why

1. **现有代码不匹配**: 当前 gatewaysrv 的路由配置与 tiz-web 前端的 API 需求不匹配
2. **需要重构**: 路由规则、认证逻辑需要重新设计以适配新的微服务架构
3. **统一规范**: 采用新的包名 `io.github.suj1e` 和 Spring Boot 4.0.2 版本

## What Changes

### 1. 路由配置

重新配置 API Gateway 路由规则：

| 路径 | 目标服务 |
|------|----------|
| `/api/auth/v1/**` | authsrv:8101 |
| `/api/user/v1/**` | usersrv:8107 |
| `/api/chat/v1/**` | chatsrv:8102 |
| `/api/content/v1/**` | contentsrv:8103 |
| `/api/practice/v1/**` | practicesrv:8104 |
| `/api/quiz/v1/**` | quizsrv:8105 |

### 2. 认证过滤器

- JWT Token 验证
- 双 Token 支持 (Access Token + Refresh Token)
- 白名单路径配置

### 3. 跨服务通信

- 基于 Nacos 的服务发现
- 负载均衡 (Spring Cloud LoadBalancer)
- 熔断器 (Resilience4j)

## Scope

### In Scope

- 路由规则配置
- JWT 认证过滤器
- 全局异常处理
- CORS 配置
- 健康检查端点

### Out of Scope

- 限流功能 (后续迭代)
- API 版本管理
- 灰度发布
