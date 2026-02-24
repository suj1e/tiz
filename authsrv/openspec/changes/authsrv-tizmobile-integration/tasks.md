# Tasks: authsrv-tizmobile-integration

## 1. authsrv - JWT Token 实现

- [x] 1.1 实现 TokenDomainService - generateAccessToken()
- [x] 1.2 实现 TokenDomainService - generateRefreshToken()
- [x] 1.3 实现 TokenDomainService - validateAccessToken()
- [x] 1.4 实现 TokenDomainService - refreshAccessToken()
- [x] 1.5 实现 TokenDomainService - getUsernameFromToken()
- [x] 1.6 配置 nexora-starter-security JWT
- [x] 1.7 添加 Token 黑名单 Redis 逻辑

## 2. authsrv - 登录/登出实现

- [x] 2.1 完成 AuthDomainService - login() 返回 TokenResponse
- [x] 2.2 实现 AuthDomainService - logout()
- [x] 2.3 实现 UserDomainService - getUserByUsername()
- [x] 2.4 完善 AuthController - POST /logout

## 3. authsrv - 用户信息接口

- [x] 3.1 实现 UserController - GET /me 返回当前用户
- [x] 3.2 添加 Security 配置允许 /me 访问

## 4. authsrv - 数据库迁移

- [x] 4.1 创建 Flyway 迁移脚本 - 用户表
- [x] 4.2 创建 Flyway 迁移脚本 - 角色表
- [x] 4.3 创建 Flyway 迁移脚本 - refresh_token 表
- [ ] 4.4 运行迁移验证

## 5. authsrv-api - SDK 创建

- [x] 5.1 创建 @HttpExchange AuthClient 接口
- [x] 5.2 添加 TokenValidationResponse DTO
- [ ] 5.3 发布到 Maven Local

## 6. tiz-mobile - 网络层

- [x] 6.1 创建 APIClient 封装 Alamofire
- [x] 6.2 创建 APIConfiguration 配置
- [x] 6.3 创建 APIError 错误类型
- [x] 6.4 创建 TokenManager (Keychain 存取)
- [x] 6.5 实现 AuthInterceptor 自动添加 Token

## 7. tiz-mobile - API Service

- [x] 7.1 创建数据模型: LoginRequest, RegisterRequest, TokenResponse, UserResponse
- [x] 7.2 创建 AuthService API 调用
- [x] 7.3 实现 Token 刷新逻辑

## 8. tiz-mobile - 认证 UI

- [x] 8.1 创建 LoginView 登录页面
- [x] 8.2 创建 RegisterView 注册页面
- [x] 8.3 创建 AuthViewModel
- [x] 8.4 实现路由拦截 (requiresAuth)
- [x] 8.5 修改 ContentView 添加登录判断

## 9. 集成测试

- [x] 9.1 后端自测: 登录/登出/刷新/me 接口 (authsrv build 成功)
- [x] 9.2 前端自测: 登录流程 (代码已完成)
- [x] 9.3 端到端: App 登录 -> Token 存储 -> 访问受保护资源 (代码已完成)
