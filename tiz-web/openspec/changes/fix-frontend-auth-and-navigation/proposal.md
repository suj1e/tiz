# Fix Frontend Auth and Navigation

## Why

前端存在三个关键问题影响用户体验：

1. **登录后跳转到登录页**：用户登录成功后，访问受保护页面会重新跳转到登录页
2. **直接 URL 访问一直加载中**：用户直接访问 URL（包括有效页面）时，页面一直显示"加载中..."
3. **开始试用功能需要调整**：LandingPage 的"开始试用"按钮没有考虑 AI 配置状态

## Root Cause

### 问题 1 & 2 根因

```
┌─────────────────────────────────────────────────────────────────┐
│ 问题根因                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. login() 只更新 Zustand state，没有存 localStorage            │
│                                                                 │
│ 2. useAuth() hook 负责初始化，但没有任何页面调用它               │
│                                                                 │
│ 3. App.tsx 没有任何 auth 初始化逻辑                              │
│                                                                 │
│ 结果：刷新页面或首次访问时，isLoading 永远是 true               │
│       ProtectedRoute 显示"加载中"且不会跳转                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 问题 3 根因

- LandingPage 的"开始试用"直接跳转到 `/chat`
- 没有检查用户是否登录、是否已配置 AI
- 用户可能看到错误或不完整的体验

## What

### 1. Auth 初始化重构

创建 `AuthProvider` 组件，在应用启动时：
- 从 localStorage 读取 token
- 验证 token 有效性
- 初始化 auth state

### 2. Token 持久化

修改 `authStore` 的 login/logout：
- login 时保存 token 到 localStorage
- logout 时清除 localStorage

### 3. "开始试用"按钮逻辑

- 未登录 → 跳转登录页
- 已登录未配置 AI → 跳转 AI 配置页
- 都满足 → 跳转聊天页

### 4. 404 页面优化（可选）

- "返回上页"在没有历史时跳转首页

## Scope

- 前端 auth 状态管理
- 前端路由和导航逻辑
- 不涉及后端改动

## New Capabilities

- `auth-initialization`: Auth 状态初始化和持久化

## Modified Capabilities

- 无（这是 bug 修复，不改变 API 或功能需求）

## Impact

- `authStore.ts`: 添加 localStorage 持久化
- `AuthProvider.tsx`: 新建，负责初始化
- `App.tsx`: 添加 AuthProvider 包裹
- `LandingPage.tsx`: 修改"开始试用"按钮逻辑
- `NotFoundPage.tsx`: 优化返回逻辑
