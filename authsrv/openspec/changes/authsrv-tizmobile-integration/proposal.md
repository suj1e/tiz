# Proposal: authsrv-tizmobile-integration

## Why

当前 Tiz 平台的认证服务 (authsrv) 核心功能未实现（JWT Token 生成、logout、用户信息接口），且移动端 (tiz-mobile) 缺乏网络层和认证 UI，无法实现前后端对接。需要完善后端认证逻辑并实现前端网络通信和登录流程，使平台具备完整的用户认证能力。

## What Changes

### authsrv (后端)

- 实现 JWT Access Token 和 Refresh Token 生成、验证、刷新
- 实现 logout 接口（Token 黑名单/失效）
- 实现 /me 接口返回当前用户信息
- 创建 @HttpExchange SDK 供网关调用
- 添加 Flyway 数据库迁移

### tiz-mobile (前端)

- 封装 Alamofire 网络客户端
- 创建 API 数据模型 (Codable)
- 实现登录/注册页面
- Token 存储到 Keychain
- 添加登录拦截器

## Capabilities

### New Capabilities

- `jwt-auth`: JWT Token 生成、验证、刷新机制
- `user-session`: 用户登录状态管理 (login/logout/me)
- `mobile-api-client`: 移动端 API 客户端封装
- `mobile-auth-flow`: 移动端登录注册流程

### Modified Capabilities

- (无)

## Impact

- `authsrv-adapter/.../TokenDomainServiceImpl.java` - 实现 token 逻辑
- `authsrv-adapter/.../AuthDomainServiceImpl.java` - 完成 login/logout
- `authsrv-adapter/.../UserController.java` - 实现 /me
- `authsrv-api/.../client/AuthClient.java` - 新增 @HttpExchange
- `tiz-mobile/Sources/Tiz/Networking/` - 新增网络层
- `tiz-mobile/Sources/Tiz/Features/Auth/` - 新增认证模块
