# tiz-web 前端开发规范

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 包管理器 | pnpm | 8.x |
| 构建工具 | Vite | 7.x |
| 框架 | React | 19.x |
| 语言 | TypeScript | 5.x (strict) |
| 路由 | React Router | 7.x |
| 状态管理 | Zustand | 5.x |
| 样式 | Tailwind CSS | 4.x |
| UI 组件 | shadcn/ui | latest |
| 图标 | Lucide React | latest |
| HTTP | 原生 fetch | - |
| Mock | MSW | 2.x |
| 测试 | Vitest | 4.x |

## 目录结构

```
tiz-web/
├── src/
│   ├── app/                    # 路由和页面
│   │   ├── (auth)/             # 认证相关页面
│   │   │   ├── login/
│   │   │   │   └── LoginPage.tsx
│   │   │   └── register/
│   │   │       └── RegisterPage.tsx
│   │   ├── (main)/             # 需要登录的页面
│   │   │   ├── home/           # 首页（聊天）
│   │   │   ├── library/        # 题库
│   │   │   ├── practice/       # 练习
│   │   │   ├── quiz/           # 测验
│   │   │   ├── result/         # 结果
│   │   │   └── settings/       # 设置（含Webhook）
│   │   ├── chat/               # 试用对话（无需登录）
│   │   ├── landing/            # 落地页
│   │   └── not-found/          # 404 页面
│   │
│   ├── components/             # 通用组件
│   │   ├── ui/                 # shadcn/ui 组件
│   │   ├── layout/             # 布局组件
│   │   │   ├── AppLayout.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Header.tsx
│   │   │   └── AuthLayout.tsx
│   │   ├── chat/               # 对话组件
│   │   ├── question/           # 题目组件
│   │   ├── library/            # 题库组件
│   │   ├── quiz/               # 测验组件
│   │   └── common/             # 通用组件
│   │       ├── ThemeToggle.tsx
│   │       ├── UserMenu.tsx
│   │       ├── EmptyState.tsx
│   │       ├── LoadingState.tsx
│   │       ├── PageError.tsx
│   │       ├── ErrorBoundary.tsx
│   │       ├── RootErrorBoundary.tsx
│   │       └── ProtectedRoute.tsx
│   │
│   ├── hooks/                  # 自定义 Hooks
│   │   ├── useAuth.ts
│   │   ├── useChat.ts
│   │   ├── useTheme.ts
│   │   └── useMediaQuery.ts
│   │
│   ├── stores/                 # Zustand Stores
│   │   ├── authStore.ts
│   │   ├── chatStore.ts
│   │   ├── libraryStore.ts
│   │   ├── practiceStore.ts
│   │   ├── quizStore.ts
│   │   └── uiStore.ts
│   │
│   ├── services/               # API 服务
│   │   ├── api.ts              # 基础请求封装（支持raw选项）
│   │   ├── auth.ts             # 认证 API
│   │   ├── chat.ts             # 对话 API (SSE)
│   │   ├── content.ts          # 内容 API
│   │   ├── practice.ts         # 练习 API
│   │   ├── quiz.ts             # 测验 API
│   │   └── user.ts             # 用户 API
│   │
│   ├── types/                  # TypeScript 类型
│   ├── lib/                    # 工具函数
│   ├── mocks/                  # MSW Mock
│   │   ├── handlers/
│   │   ├── data/
│   │   └── browser.ts
│   │
│   ├── main.tsx                # 入口文件
│   ├── App.tsx                 # 根组件
│   └── router.tsx              # 路由配置（含errorElement）
│
├── public/
│   ├── favicon.svg             # 项目图标
│   └── vite.svg
│
├── index.html
├── package.json
├── vite.config.ts
├── vitest.config.ts
├── tsconfig.json
├── Dockerfile
└── nginx.conf
```

## 命名规范

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件夹 | kebab-case | `user-profile/`, `question-card/` |
| 组件文件 | PascalCase | `ChatMessage.tsx`, `QuestionCard.tsx` |
| Hook 文件 | camelCase + use 前缀 | `useChat.ts`, `useAuth.ts` |
| 工具文件 | camelCase | `utils.ts`, `storage.ts` |
| 类型文件 | camelCase | `user.ts`, `chat.ts` |
| Store 文件 | camelCase + Store 后缀 | `authStore.ts`, `chatStore.ts` |

### 代码命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 组件 | PascalCase | `ChatPanel`, `QuestionCard` |
| 函数 | camelCase | `fetchUser`, `handleSubmit` |
| 变量 | camelCase | `isLoading`, `currentUser` |
| 常量 | UPPER_SNAKE_CASE | `API_BASE_URL`, `DEFAULT_PAGE_SIZE` |
| 类型/接口 | PascalCase | `User`, `ApiResponse`, `ChatMessage` |

## React 规范

### 组件结构

```tsx
// 1. 导入
import { useState, useEffect } from "react"
import { useNavigate } from "react-router-dom"
import { Button } from "@/components/ui/button"
import { PageError } from "@/components/common/PageError"
import { useAuthStore } from "@/stores/authStore"

// 2. 类型定义
interface LoginPageProps {
  // ...
}

// 3. 组件
export function LoginPage(props: LoginPageProps) {
  // 3.1 Hooks
  const navigate = useNavigate()
  const { login, isLoading } = useAuthStore()

  // 3.2 State
  const [email, setEmail] = useState("")
  const [error, setError] = useState<Error | null>(null)

  // 3.3 派生状态
  const isValid = email.length > 0

  // 3.4 Handlers
  const handleSubmit = async () => {
    try {
      await login(email, password)
    } catch (err) {
      setError(err instanceof Error ? err : new Error('登录失败'))
    }
  }

  // 3.5 错误状态处理
  if (error) {
    return <PageError message={error.message} onRetry={handleSubmit} />
  }

  // 3.6 渲染
  return (
    <div>
      {/* ... */}
    </div>
  )
}
```

## 样式规范

### Tailwind CSS 响应式

```tsx
// 移动端优先，使用 Tailwind 断点
// 避免写死尺寸，使用动态值

// ❌ 错误：写死尺寸
<div className="min-h-[400px] h-[50px] w-[50px]">

// ✅ 正确：响应式动态尺寸
<div className="min-h-[50vh] sm:min-h-[60vh]">
<div className="h-12 w-12 sm:h-auto sm:w-auto">
<div className="min-h-14 sm:min-h-16">
```

### 响应式断点

| 断点 | 最小宽度 | 用途 |
|------|----------|------|
| (默认) | 0px | 移动端 |
| `sm:` | 640px | 小屏手机横屏/小平板 |
| `md:` | 768px | 平板 |
| `lg:` | 1024px | 桌面 |
| `xl:` | 1280px | 大屏桌面 |

## 错误处理规范

### 页面级错误处理

```tsx
// 使用 PageError 组件处理数据加载错误
export default function LibraryPage() {
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const loadData = async () => {
      try {
        const data = await contentService.getLibraries()
        setLibraries(data)
      } catch (err) {
        setError(err instanceof Error ? err : new Error('加载失败'))
      }
    }
    loadData()
  }, [])

  if (error) {
    return <PageError message={error.message} onRetry={loadData} />
  }
  // ...
}
```

### 路由级错误边界

```tsx
// router.tsx 已配置 errorElement
import { RootErrorBoundary } from '@/components/common/RootErrorBoundary'

export const router = createBrowserRouter([
  {
    path: '/',
    element: lazy(LandingPage),
    errorElement: <RouteErrorElement />,
  },
  // ...
])
```

## API 调用规范

### 基础请求

```typescript
// services/api.ts
export const api = {
  // 普通请求 - 自动提取 response.data
  get<T>(path: string, options?: RequestOptions): Promise<T>

  // 获取完整响应（含分页等）
  get<T>(path: string, { raw: true }): Promise<T>
}

// 示例
// 普通请求
const user = await api.get<User>('/user/v1/me')

// 分页请求（需要完整响应）
const response = await api.get<PaginatedResponse<Library>>('/content/v1/library', { raw: true })
// response = { data: [...], pagination: {...} }
```

## 状态管理规范

### Zustand Store

```typescript
// stores/authStore.ts
import { create } from "zustand"

interface AuthState {
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: false,

  login: async (email, password) => {
    set({ isLoading: true })
    try {
      const response = await authService.login({ email, password })
      set({ user: response.user, isAuthenticated: true })
    } finally {
      set({ isLoading: false })
    }
  },

  logout: () => {
    set({ user: null, isAuthenticated: false })
  },
}))
```

## 开发命令

```bash
# 安装依赖
pnpm install

# 开发模式 (Mock)
VITE_MOCK=true pnpm dev

# 开发模式 (连接后端)
pnpm dev

# 构建
pnpm build

# 代码检查
pnpm lint

# 测试
pnpm test
pnpm test:run
pnpm test:coverage
```

## Git 规范

### Commit 规范

```
feat: 新增功能
fix: 修复 bug
refactor: 重构
style: 代码格式
docs: 文档
chore: 构建/工具
test: 测试

示例:
feat: 添加 Webhook 配置功能
fix: 修复题库页面数据加载错误
refactor: 优化错误处理机制
```
