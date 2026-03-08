# Lark Auth (飞书免登)

## 概述

飞书企业内应用免登能力，允许用户在飞书 App 内打开网页应用时自动完成身份认证，无需再次输入账号密码。

## 适用场景

- 飞书桌面端打开网页应用
- 飞书移动端打开网页应用
- 用户通过飞书邮箱注册后，在飞书内自动关联账户

## 前置条件

1. 飞书开放平台已创建企业自建应用
2. 应用已配置网页应用地址 (桌面端/移动端)
3. 应用已开通 `contact:user.base:readonly` 权限
4. 后端已实现 `/auth/v1/lark/login` 接口

## 技术规范

### 环境检测

通过以下方式检测是否在飞书环境：

1. User-Agent 包含 `Lark` 或 `Feishu`
2. URL 参数包含 `mock_lark=true` (开发测试用)

```typescript
function isInLarkEnv(): boolean {
  const ua = navigator.userAgent
  return ua.includes('Lark') ||
         ua.includes('Feishu') ||
         new URLSearchParams(window.location.search).has('mock_lark')
}
```

### SDK 加载

飞书 H5 SDK 地址：`https://lf1-cdn-tos.bytegoofy.com/obj/h5sdk/h5sdk.js`

动态加载方式：
```typescript
const script = document.createElement('script')
script.src = 'https://lf1-cdn-tos.bytegoofy.com/obj/h5sdk/h5sdk.js'
document.head.appendChild(script)
```

### 获取 Auth Code

```typescript
window.tt.requestAuthCode({
  app_id: 'cli_xxx',
  success: (res) => {
    const code = res.code
    // 调用后端登录接口
  },
  fail: (err) => {
    // 处理错误
  }
})
```

### 登录接口

**POST /auth/v1/lark/login**

Request:
```json
{
  "code": "string"
}
```

Response (成功):
```json
{
  "data": {
    "user": {
      "id": "string",
      "email": "string",
      "name": "string"
    },
    "token": "string"
  }
}
```

Response (失败):
```json
{
  "error": {
    "type": "AUTH_ERROR",
    "code": "LARK_AUTH_FAILED",
    "message": "飞书登录失败"
  }
}
```

### 用户绑定逻辑

后端处理飞书登录时的用户绑定逻辑：

1. 用 code 调用飞书 API 获取 `open_id` 和用户信息
2. 查询 `users` 表 `lark_open_id` 字段
   - 如果找到 → 直接返回该用户的 token
   - 如果未找到 → 检查邮箱是否已存在
     - 邮箱已存在 → 绑定 `lark_open_id` 到该用户
     - 邮箱不存在 → 创建新用户并绑定 `lark_open_id`

## 错误处理

| 错误码 | 说明 | 处理方式 |
|--------|------|----------|
| LARK_AUTH_FAILED | 飞书授权失败 | 提示用户重试 |
| LARK_CODE_EXPIRED | Auth code 已过期 | 重新获取 code |
| LARK_API_ERROR | 飞书 API 调用失败 | 记录日志，提示用户稍后重试 |

## 安全考虑

1. Auth code 仅能使用一次，且有效期很短 (通常 5 分钟)
2. 后端应验证 code 的有效性，不能信任前端传来的任何用户信息
3. `lark_open_id` 应设置唯一索引，防止重复绑定
4. Token 应设置合理的过期时间

## 开发测试

### Mock 模式

在 URL 添加 `?mock_lark=true` 参数可模拟飞书环境：

- 触发飞书免登流程
- MSW 拦截 `/auth/v1/lark/login` 返回 mock 数据

### Mock Handler

```typescript
// src/shared/mocks/handlers/auth.ts
http.post('/api/auth/v1/lark/login', () => {
  return HttpResponse.json({
    data: {
      user: {
        id: 'mock_user_001',
        email: 'mock@lark.com',
        name: '飞书测试用户'
      },
      token: 'mock_jwt_token'
    }
  })
})
```
