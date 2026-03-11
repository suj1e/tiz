# Design: Fix Frontend Auth and Navigation

## Context

当前前端使用 Zustand 管理 auth 状态，但存在以下问题：

1. **状态不持久化**：`login()` 只更新 Zustand state，刷新页面后状态丢失
2. **没有初始化逻辑**：`useAuth` hook 存在但未被任何页面调用
3. **isLoading 状态问题**：初始值是 `true`，但没有任何地方在应用启动时将其设为 `false`

```
当前架构：

┌─────────────────────────────────────────────────────────────┐
│ App.tsx                                                     │
│  └─ RouterProvider                                          │
│       └─ routes                                             │
│            ├─ / (LandingPage)                               │
│            ├─ /login (LoginPage)                            │
│            └─ ProtectedRoute                                │
│                 └─ /home, /library, etc.                    │
│                                                             │
│  问题：没有 AuthProvider 初始化 auth 状态                   │
└─────────────────────────────────────────────────────────────┘
```

## Goals / Non-Goals

**Goals:**
- 登录后刷新页面仍保持登录状态
- 直接访问 URL 时正确显示页面或重定向
- "开始试用"按钮根据用户状态智能跳转

**Non-Goals:**
- 不修改后端 API
- 不添加新的认证方式（如 OAuth）
- 不修改 token 格式或过期策略

## Decisions

### 1. AuthProvider 组件设计

**决策：创建 `AuthProvider` 组件包裹整个应用**

```
新架构：

┌─────────────────────────────────────────────────────────────┐
│ App.tsx                                                     │
│  └─ AuthProvider  ← 新增                                    │
│       └─ RouterProvider                                     │
│            └─ routes                                        │
│                 ├─ / (LandingPage)                          │
│                 ├─ /login (LoginPage)                       │
│                 └─ ProtectedRoute                           │
│                      └─ /home, /library, etc.               │
└─────────────────────────────────────────────────────────────┘
```

**理由：**
- 集中管理 auth 初始化逻辑
- 与 React 生命周期正确集成
- 易于测试和维护

**备选方案：**
- ❌ 在每个 ProtectedRoute 页面调用 useAuth() - 重复代码，难以维护
- ❌ 在 App.tsx 的 useEffect 中初始化 - 不够清晰，难以扩展

### 2. Token 存储方案

**决策：使用 localStorage 存储 token**

```typescript
// 存储格式
localStorage.setItem('tiz-web-token', token)
localStorage.removeItem('tiz-web-token')
```

**理由：**
- 简单可靠，浏览器原生支持
- 刷新页面后数据不丢失
- 已有代码使用相同的 key (`tiz-web-token`)

**备选方案：**
- ❌ sessionStorage - 关闭标签页后丢失，体验差
- ❌ IndexedDB - 过于复杂，不适合单一 token

### 3. AuthProvider 初始化流程

```
┌─────────────────────────────────────────────────────────────┐
│ AuthProvider 初始化流程                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 组件挂载时 (useEffect)                                   │
│     │                                                       │
│     ├─ 检查 localStorage 中是否有 token                      │
│     │   ├─ 无 token → setLoading(false), 完成               │
│     │   │                                                   │
│     │   └─ 有 token → 验证 token                            │
│     │        │                                              │
│     │        ├─ 调用 GET /auth/v1/me                        │
│     │        │                                              │
│     │        ├─ 成功 → login(user, token), setLoading(false)│
│     │        │                                              │
│     │        └─ 失败 → logout(), setLoading(false)          │
│     │                                                       │
│  2. 渲染时                                                   │
│     │                                                       │
│     └─ isLoading ? <Loading /> : <>{children}</>            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4. "开始试用"按钮逻辑

**决策：在点击时检查状态并跳转**

```typescript
const handleStartTrial = () => {
  if (!isAuthenticated) {
    navigate('/login', { state: { from: { pathname: '/chat' } } })
  } else if (!hasAiConfig) {
    navigate('/ai-config', { state: { from: { pathname: '/chat' } } })
  } else {
    navigate('/chat')
  }
}
```

**理由：**
- LandingPage 已经在 ProtectedRoute 外，需要手动检查
- 提供清晰的用户引导路径

**备选方案：**
- ❌ 直接跳转 `/chat`，让 ProtectedRoute 处理 - 用户体验差，多次跳转

### 5. 文件组织

**决策：创建 `providers/` 目录**

```
src/shared/
├── providers/
│   └── AuthProvider.tsx    ← 新建
├── stores/
│   └── authStore.ts        ← 修改
└── app/
    └── landing/
        └── LandingPage.tsx ← 修改
```

**理由：**
- providers 是独立概念，与 components 分离
- 符合 React 社区常见模式
- 便于未来添加其他 Provider

## Risks / Trade-offs

### Risk 1: Token 过期处理

**风险：** localStorage 中的 token 可能已过期，但 AuthProvider 仍会尝试使用

**缓解：**
- AuthProvider 调用 `/auth/v1/me` 验证 token
- 失败时清除 localStorage 并重置状态
- api.ts 已有 401 处理逻辑，会自动跳转登录页

### Risk 2: 初始化闪烁

**风险：** AuthProvider 初始化时显示 Loading，可能导致短暂闪烁

**缓解：**
- 初始化通常很快（< 100ms）
- 可以使用骨架屏或淡入动画优化体验

### Risk 3: SSR 兼容性

**风险：** localStorage 在 SSR 环境不可用

**缓解：**
- 当前项目是纯 CSR（Vite SPA），不涉及 SSR
- 如果未来需要 SSR，可以在 AuthProvider 中添加环境检查

## Migration Plan

### 部署步骤

1. **修改 authStore.ts**
   - login 时保存 token 到 localStorage
   - logout 时清除 localStorage

2. **创建 AuthProvider.tsx**
   - 实现初始化逻辑

3. **修改 App.tsx (desktop & mobile)**
   - 用 AuthProvider 包裹 RouterProvider

4. **修改 LandingPage.tsx**
   - 更新"开始试用"按钮逻辑

5. **修改 NotFoundPage.tsx**（可选）
   - 优化返回按钮逻辑

### 回滚策略

- 每个改动都是独立的，可以单独回滚
- localStorage 格式不变，不影响现有登录用户
