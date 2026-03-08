## 架构概览

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      tiz-web 双端架构                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         ┌─────────────────┐                                │
│                         │   tiz-web       │                                │
│                         │   Monorepo      │                                │
│                         └────────┬────────┘                                │
│                                  │                                          │
│          ┌───────────────────────┼───────────────────────┐                 │
│          │                       │                       │                  │
│          ▼                       ▼                       ▼                  │
│   ┌─────────────┐        ┌─────────────┐        ┌─────────────┐           │
│   │   Desktop   │        │   Mobile    │        │   Shared    │           │
│   │   (桌面端)   │        │   (移动端)   │        │   (共享层)   │           │
│   │             │        │             │        │             │           │
│   │ tiz.com     │        │ m.tiz.com   │        │ components  │           │
│   │             │        │             │        │ stores      │           │
│   │ 完整功能     │        │ 完整功能     │        │ services    │           │
│   │ 侧边栏布局   │        │ 底部导航布局 │        │ hooks       │           │
│   └─────────────┘        └─────────────┘        │ types       │           │
│                                                 └─────────────┘           │
│                                                                            │
│                         ┌─────────────────┐                                │
│                         │   Lark SDK      │                                │
│                         │   (飞书集成)     │                                │
│                         └─────────────────┘                                │
│                                                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 目录结构

```
tiz-web/
├── src/
│   ├── desktop/                    # 桌面端
│   │   ├── main.tsx                # 入口
│   │   ├── App.tsx                 # 根组件
│   │   ├── router.tsx              # 路由配置
│   │   └── layouts/
│   │       └── AppLayout.tsx       # 桌面端布局 (侧边栏)
│   │
│   ├── mobile/                     # 移动端
│   │   ├── main.tsx                # 入口
│   │   ├── App.tsx                 # 根组件
│   │   ├── router.tsx              # 路由配置
│   │   └── layouts/
│   │       └── AppLayout.tsx       # 移动端布局 (底部导航)
│   │
│   ├── shared/                     # 共享代码
│   │   ├── app/                    # 页面 (两端共用)
│   │   │   ├── (auth)/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   ├── home/
│   │   │   ├── library/
│   │   │   ├── practice/
│   │   │   ├── quiz/
│   │   │   ├── result/
│   │   │   ├── settings/
│   │   │   ├── chat/
│   │   │   └── landing/
│   │   │
│   │   ├── components/             # 共享组件
│   │   │   ├── ui/                 # shadcn/ui
│   │   │   ├── chat/
│   │   │   ├── question/
│   │   │   ├── library/
│   │   │   ├── quiz/
│   │   │   └── common/
│   │   │
│   │   ├── stores/                 # Zustand stores
│   │   ├── services/               # API 服务
│   │   ├── hooks/                  # 自定义 hooks
│   │   ├── types/                  # 类型定义
│   │   ├── lib/                    # 工具函数
│   │   └── mocks/                  # MSW mock
│   │
│   └── lark/                       # 飞书集成
│       ├── index.ts                # SDK 初始化
│       ├── auth.ts                 # 免登逻辑
│       └── types.ts                # 类型定义
│
├── index.desktop.html              # 桌面端 HTML
├── index.mobile.html               # 移动端 HTML
├── vite.config.desktop.ts          # 桌面端构建配置
├── vite.config.mobile.ts           # 移动端构建配置
│
└── package.json
```

## 构建配置

### vite.config.desktop.ts

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  root: '.',
  publicDir: 'public',
  build: {
    outDir: 'dist/desktop',
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'index.desktop.html'),
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src/shared'),
      '@desktop': path.resolve(__dirname, 'src/desktop'),
      '@lark': path.resolve(__dirname, 'src/lark'),
    },
  },
  server: {
    port: 5173,
  },
})
```

### vite.config.mobile.ts

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  root: '.',
  publicDir: 'public',
  build: {
    outDir: 'dist/mobile',
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'index.mobile.html'),
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src/shared'),
      '@mobile': path.resolve(__dirname, 'src/mobile'),
      '@lark': path.resolve(__dirname, 'src/lark'),
    },
  },
  server: {
    port: 5174,
  },
})
```

### package.json scripts

```json
{
  "scripts": {
    "dev": "pnpm dev:desktop",
    "dev:desktop": "vite --config vite.config.desktop.ts",
    "dev:mobile": "vite --config vite.config.mobile.ts",
    "build": "pnpm build:all",
    "build:desktop": "tsc -b && vite build --config vite.config.desktop.ts",
    "build:mobile": "tsc -b && vite build --config vite.config.mobile.ts",
    "build:all": "run-p build:desktop build:mobile",
    "preview:desktop": "vite preview --config vite.config.desktop.ts",
    "preview:mobile": "vite preview --config vite.config.mobile.ts"
  }
}
```

## 路由设计

两端路由结构相同，仅 Layout 不同。

### 桌面端路由

```typescript
// src/desktop/router.tsx
const routes = [
  { path: '/', element: <LandingPage /> },
  { path: '/login', element: <LoginPage /> },
  { path: '/register', element: <RegisterPage /> },
  { path: '/chat', element: <ChatPage /> },
  {
    element: <ProtectedRoute><DesktopAppLayout /></ProtectedRoute>,
    children: [
      { path: '/home', element: <HomePage /> },
      { path: '/library', element: <LibraryPage /> },
      { path: '/practice/:id', element: <PracticePage /> },
      { path: '/quiz/:id', element: <QuizPage /> },
      { path: '/result/:id', element: <ResultPage /> },
      { path: '/settings', element: <SettingsPage /> },
    ],
  },
]
```

### 移动端路由

```typescript
// src/mobile/router.tsx
const routes = [
  { path: '/', element: <LandingPage /> },
  { path: '/login', element: <LoginPage /> },
  { path: '/register', element: <RegisterPage /> },
  { path: '/chat', element: <ChatPage /> },
  {
    element: <ProtectedRoute><MobileAppLayout /></ProtectedRoute>,
    children: [
      { path: '/home', element: <HomePage /> },
      { path: '/library', element: <LibraryPage /> },
      { path: '/practice/:id', element: <PracticePage /> },
      { path: '/quiz/:id', element: <QuizPage /> },
      { path: '/result/:id', element: <ResultPage /> },
      { path: '/settings', element: <SettingsPage /> },
    ],
  },
]
```

## 布局设计

### 桌面端布局 (侧边栏)

```
┌─────────────────────────────────────────────────────────────────┐
│  Header                                                          │
├──────────────┬──────────────────────────────────────────────────┤
│              │                                                  │
│   Sidebar    │                   Main Content                   │
│              │                                                  │
│  ┌────────┐  │                                                  │
│  │ Home   │  │                                                  │
│  │ Library│  │                                                  │
│  │ Chat   │  │                                                  │
│  │Settings│  │                                                  │
│  └────────┘  │                                                  │
│              │                                                  │
│              │                                                  │
├──────────────┴──────────────────────────────────────────────────┤
└─────────────────────────────────────────────────────────────────┘
```

### 移动端布局 (底部导航)

```
┌─────────────────────────────┐
│  Header                      │
├─────────────────────────────┤
│                             │
│                             │
│       Main Content          │
│                             │
│                             │
│                             │
│                             │
│                             │
├─────────────────────────────┤
│  Home │ Library │ Settings  │  ← BottomNav
└─────────────────────────────┘
```

## 飞书免登流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  main.tsx (desktop/mobile)                                                  │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. 检测是否在飞书环境                                                │   │
│  │     - 检查 UA 是否包含 "Lark" 或 "Feishu"                             │   │
│  │     - 或检查 URL 参数 ?from=lark                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ├── 不在飞书环境 → 正常渲染应用                                       │
│       │                                                                     │
│       ▼ 在飞书环境                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  2. 加载飞书 JS SDK (动态插入 script)                                 │   │
│  │     https://lf1-cdn-tos.bytegoofy.com/obj/h5sdk/h5sdk.js             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  3. 调用免登 API                                                      │   │
│  │     tt.requestAuthCode({                                              │   │
│  │       app_id: 'cli_xxx',                                              │   │
│  │       success: (res) => { code = res.code }                           │   │
│  │     })                                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  4. 调用后端登录接口                                                  │   │
│  │     POST /auth/v1/lark/login { code: 'xxx' }                          │   │
│  │     → 返回 { data: { user, token } }                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  5. 存储 token，渲染应用                                              │   │
│  │     authStore.login(token, user)                                      │   │
│  │     → ReactDOM.createRoot().render(<App />)                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 飞书集成代码

### src/lark/index.ts

```typescript
declare global {
  interface Window {
    tt?: {
      requestAuthCode: (options: {
        app_id: string
        success: (res: { code: string }) => void
        fail: (err: unknown) => void
      }) => void
    }
  }
}

export const LARK_APP_ID = import.meta.env.VITE_LARK_APP_ID || ''

export function isInLarkEnv(): boolean {
  const ua = navigator.userAgent
  return ua.includes('Lark') || ua.includes('Feishu') ||
         new URLSearchParams(window.location.search).has('mock_lark')
}

export function loadLarkSDK(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (window.tt) {
      resolve()
      return
    }

    const script = document.createElement('script')
    script.src = 'https://lf1-cdn-tos.bytegoofy.com/obj/h5sdk/h5sdk.js'
    script.onload = () => resolve()
    script.onerror = reject
    document.head.appendChild(script)
  })
}

export function getLarkAuthCode(): Promise<string> {
  return new Promise((resolve, reject) => {
    if (!window.tt) {
      reject(new Error('Lark SDK not loaded'))
      return
    }

    window.tt.requestAuthCode({
      app_id: LARK_APP_ID,
      success: (res) => resolve(res.code),
      fail: (err) => reject(err),
    })
  })
}
```

### src/lark/auth.ts

```typescript
import { authService } from '@/services/auth'
import { useAuthStore } from '@/stores/auth'
import { isInLarkEnv, loadLarkSDK, getLarkAuthCode } from './index'

export async function tryLarkLogin(): Promise<boolean> {
  if (!isInLarkEnv()) {
    return false
  }

  try {
    await loadLarkSDK()
    const code = await getLarkAuthCode()
    const { user, token } = await authService.larkLogin(code)

    useAuthStore.getState().setUser(user)
    useAuthStore.getState().setToken(token)

    return true
  } catch (error) {
    console.error('Lark login failed:', error)
    return false
  }
}
```

### src/shared/services/auth.ts (新增方法)

```typescript
export const authService = {
  // ... existing methods

  larkLogin: (code: string): Promise<LoginResponse> => {
    return api.post<LoginResponse>('/auth/v1/lark/login', { code })
  },
}
```

## 后端接口设计

### POST /auth/v1/lark/login

**Request:**
```json
{
  "code": "abc123xyz"
}
```

**Response (成功):**
```json
{
  "data": {
    "user": {
      "id": "user_001",
      "email": "user@example.com",
      "name": "张三"
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Response (失败):**
```json
{
  "error": {
    "type": "AUTH_ERROR",
    "code": "LARK_AUTH_FAILED",
    "message": "飞书登录失败，请重试"
  }
}
```

**后端逻辑:**
1. 用 code 调用飞书 API 获取 user_info (open_id, name, email)
2. 查找是否已有用户绑定了该 open_id
3. 如果没有，检查 email 是否已存在
   - 存在 → 自动绑定 lark_open_id
   - 不存在 → 创建新用户
4. 生成 JWT token 返回

## Nginx 配置

```nginx
# 桌面端
server {
    listen 443 ssl;
    server_name tiz.com www.tiz.com;

    ssl_certificate     /path/to/tiz.com.crt;
    ssl_certificate_key /path/to/tiz.com.key;

    # 移动设备检测和重定向
    set $mobile_rewrite do_not_perform;

    if ($http_user_agent ~* "(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|ipad|tablet") {
        set $mobile_rewrite perform;
    }

    if ($mobile_rewrite = perform) {
        return 301 https://m.tiz.com$request_uri;
    }

    root /var/www/tiz-desktop;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}

# 移动端
server {
    listen 443 ssl;
    server_name m.tiz.com;

    ssl_certificate     /path/to/tiz.com.crt;
    ssl_certificate_key /path/to/tiz.com.key;

    root /var/www/tiz-mobile;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```
