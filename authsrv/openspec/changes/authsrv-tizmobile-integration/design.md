## Context

当前 Tiz 平台需要实现完整的用户认证功能。authsrv 后端服务已有基础骨架，但核心 JWT 逻辑未实现；tiz-mobile 移动端仅有 UI 占位，缺少网络层和认证流程。

### 技术栈

- **后端**: Spring Boot 3.2.7, Java 21, nexora-spring-boot-starter-security (JWT)
- **前端**: Swift 5.9+, Alamofire 5.9, KeychainAccess 4.2
- **网关**: Spring Cloud Gateway (40004 端口)
- **认证服务**: authsrv (40006 端口)

### 约束

1. 使用 nexora-starter-security 处理 JWT（不自己实现签名/验证）
2. Refresh Token 存储数据库（不是 JWT）
3. Token 黑名单使用 Redis 存储
4. 移动端通过网关访问（/api/v1/auth/*）

## Goals / Non-Goals

**Goals:**
- 实现 JWT Access Token (15min) 和 Refresh Token (7天) 生成/验证/刷新
- 实现用户登录、注册、登出功能
- 实现获取当前用户信息接口
- 创建 authsrv-api 的 @HttpExchange SDK
- 移动端实现网络层封装和认证 UI 流程

**Non-Goals:**
- 邮箱/短信验证码（后续功能）
- OAuth2 第三方登录（后续功能）
- 用户权限管理（RBAC）- 当前只需基础角色
- 重度安全加固（如设备指纹）- 后续迭代

## Decisions

### Decision 1: JWT vs Opaque Token

**选择**: Access Token 用 JWT，Refresh Token 用不透明字符串存数据库

**理由**:
- JWT 可无状态验证，减轻后端压力
- Refresh Token 存数据库可以实现主动失效（logout/密码修改）
- 符合行业最佳实践

### Decision 2: Token 存储方案

**选择**:
- Access Token: JWT (客户端存)
- Refresh Token: 数据库 + Redis 缓存
- 黑名单: Redis

**理由**:
- JWT 本身包含用户信息，无需每次查询数据库
- Refresh Token 需要可失效，必须存库
- Redis 做缓存和黑名单，性能好

### Decision 3: 移动端 Token 存储

**选择**: Keychain 存储 Access Token 和 Refresh Token

**理由**:
- KeychainAccess 库已集成
- 安全可靠，系统级加密
- 不怕 App 清理缓存

### Decision 4: 移动端网络层架构

**选择**: 单一 APIClient 类封装 Alamofire + 各功能模块的 API Service

**理由**:
- 集中管理 baseURL、headers、interceptors
- API Service 职责单一，便于维护
- 方便后续添加缓存、retry 等

## Risks / Trade-offs

### Risk 1: Token 刷新时用户同时操作
**→ Mitigation**: 刷新时使用 mutex 或队列，防止并发刷新

### Risk 2: 移动端 Token 过期但刷新失败
**→ Mitigation**: 刷新失败时清空 Token，引导重新登录

### Risk 3: 后端 JWT 配置依赖 nexora-starter
**→ Mitigation**: 提前确认 nexora-starter-security 的 JWT 配置方式

### Risk 4: 网关路由配置
**→ Mitigation**: 确保网关 Nacos 配置正确路由到 authsrv

## Migration Plan

1. **Phase 1**: authsrv 核心逻辑实现
   - 实现 TokenDomainService (JWT + DB)
   - 实现 AuthDomainService (login/logout)
   - 实现 UserController /me
   - 创建 Flyway 迁移
   - 本地测试通过

2. **Phase 2**: authsrv-api SDK
   - 创建 @HttpExchange 接口
   - 发布到 Maven Local

3. **Phase 3**: tiz-mobile 网络层
   - 封装 APIClient
   - 创建 AuthService
   - 实现 TokenManager (Keychain)

4. **Phase 4**: tiz-mobile 认证 UI
   - 登录/注册页面
   - 路由拦截器
   - 集成测试

## Open Questions

1. **Q**: nexora-starter-security 是否已支持 JWT？版本是否兼容？
   - 需要验证 nexora 依赖和配置方式

2. **Q**: 网关是否需要配置白名单路径？
   - /api/v1/auth/login, /api/v1/auth/register 应该免认证

3. **Q**: 移动端是否需要支持生物识别（Face ID/Touch ID）？
   - 当前版本先不做，后续迭代
