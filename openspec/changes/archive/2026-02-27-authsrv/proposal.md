# authsrv

## Why

认证服务是整个平台的基础，负责用户注册、登录、Token 管理。

## What Changes

### 1. 用户认证

- 用户注册 (邮箱 + 密码)
- 用户登录 (返回 Access Token + Refresh Token)
- Token 刷新
- 登出 (撤销 Refresh Token)

### 2. Token 管理

- Access Token: 30 分钟有效期
- Refresh Token: 7 天有效期，存储在数据库
- 支持 Token 撤销

### 3. 内部 API

- 用户信息查询 (供其他服务调用)

## Scope

### In Scope

- 注册/登录/登出
- Token 生成和验证
- Refresh Token 管理
- 内部用户查询 API

### Out of Scope

- 第三方登录 (OAuth)
- 多因素认证
- 密码重置
