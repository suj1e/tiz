# tiz-web 前端开发规范

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 包管理器 | pnpm | 8.x |
| 构建工具 | Vite | 5.x |
| 框架 | React | 18.x |
| 语言 | TypeScript | 5.x (strict) |
| 路由 | React Router | 6.x |
| 状态管理 | Zustand | 4.x |
| 样式 | Tailwind CSS | 3.x |
| UI 组件 | shadcn/ui | latest |
| 图标 | Lucide React | latest |
| HTTP | 原生 fetch | - |
| Mock | MSW | 2.x |

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
│   │   │   ├── home/
│   │   │   ├── library/
│   │   │   ├── practice/
│   │   │   ├── quiz/
│   │   │   ├── result/
│   │   │   └── settings/
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
│   │   │   ├── ChatPanel.tsx
│   │   │   ├── ChatMessage.tsx
│   │   │   ├── ChatInput.tsx
│   │   │   ├── ChatConfirm.tsx
│   │   │   └── TypingIndicator.tsx
│   │   ├── question/           # 题目组件
│   │   │   ├── QuestionCard.tsx
│   │   │   ├── ChoiceQuestion.tsx
│   │   │   ├── EssayQuestion.tsx
│   │   │   ├── QuestionNav.tsx
│   │   │   ├── QuestionProgress.tsx
│   │   │   └── AnswerFeedback.tsx
│   │   ├── library/            # 题库组件
│   │   │   ├── LibraryList.tsx
│   │   │   ├── LibraryCard.tsx
│   │   │   ├── LibraryFilter.tsx
│   │   │   └── TagList.tsx
│   │   ├── quiz/               # 测验组件
│   │   │   ├── QuizTimer.tsx
│   │   │   ├── QuizResult.tsx
│   │   │   └── WrongAnswerReview.tsx
│   │   └── common/             # 通用组件
│   │       ├── ThemeToggle.tsx
│   │       ├── UserMenu.tsx
│   │       ├── EmptyState.tsx
│   │       ├── LoadingState.tsx
│   │       ├── PageError.tsx
│   │       └── ErrorBoundary.tsx
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
│   │   ├── api.ts              # 基础请求封装
│   │   ├── auth.ts             # 认证 API
│   │   ├── chat.ts             # 对话 API
│   │   ├── content.ts          # 内容 API
│   │   ├── practice.ts         # 练习 API
│   │   ├── quiz.ts             # 测验 API
│   │   └── user.ts             # 用户 API
│   │
│   ├── types/                  # TypeScript 类型
│   │   ├── index.ts
│   │   ├── user.ts
│   │   ├── chat.ts
│   │   ├── question.ts
│   │   ├── library.ts
│   │   └── api.ts
│   │
│   ├── lib/                    # 工具函数
│   │   ├── utils.ts
│   │   ├── cn.ts
│   │   └── storage.ts
│   │
│   ├── mocks/                  # MSW Mock
│   │   ├── handlers/
│   │   │   ├── index.ts
│   │   │   ├── auth.ts
│   │   │   ├── chat.ts
│   │   │   ├── content.ts
│   │   │   ├── practice.ts
│   │   │   └── quiz.ts
│   │   ├── data/
│   │   │   ├── users.ts
│   │   │   ├── questions.ts
│   │   │   └── library.ts
│   │   └── browser.ts
│   │
│   ├── main.tsx                # 入口文件
│   ├── App.tsx                 # 根组件
│   ├── router.tsx              # 路由配置
│   └── vite-env.d.ts
│
├── public/
│   └── favicon.ico
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── .env.example
├── .env.development
├── .env.production
├── .eslintrc.js
├── .prettierrc
├── .gitignore
├── Dockerfile
├── nginx.conf
├── index.html
├── package.json
├── pnpm-lock.yaml
├── tailwind.config.js
├── postcss.config.js
├── tsconfig.json
├── tsconfig.node.json
└── vite.config.ts
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
| 常量文件 | camelCase | `constants.ts` |

### 代码命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 组件 | PascalCase | `ChatPanel`, `QuestionCard` |
| 函数 | camelCase | `fetchUser`, `handleSubmit` |
| 变量 | camelCase | `isLoading`, `currentUser` |
| 常量 | UPPER_SNAKE_CASE | `API_BASE_URL`, `DEFAULT_PAGE_SIZE` |
| 类型/接口 | PascalCase | `User`, `ApiResponse`, `ChatMessage` |
| 枚举 | PascalCase | `Theme`, `QuestionType` |
| CSS 类 | kebab-case (Tailwind) | `bg-primary`, `text-muted-foreground` |

## TypeScript 规范

### 类型定义

```typescript
// 优先使用 interface 定义对象类型
interface User {
  id: string
  email: string
  created_at: string
}

// 复杂类型使用 type
type Theme = "light" | "dark" | "system"
type ApiResponse<T> = {
  data: T
}

// Props 必须定义类型
interface ChatPanelProps {
  messages: Message[]
  isLoading: boolean
  onSend: (message: string) => void
}
```

### 严格模式

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

## React 规范

### 组件结构

```tsx
// 1. 导入
import { useState } from "react"
import { useNavigate } from "react-router-dom"
import { Button } from "@/components/ui/button"
import { useAuthStore } from "@/stores/authStore"
import type { LoginFormData } from "@/types"

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

  // 3.3 派生状态
  const isValid = email.length > 0

  // 3.4 Effects
  useEffect(() => {
    // ...
  }, [])

  // 3.5 Handlers
  const handleSubmit = async () => {
    await login(email, password)
  }

  // 3.6 渲染
  return (
    <div>
      {/* ... */}
    </div>
  )
}
```

### Hooks 规范

```typescript
// 自定义 Hook 示例
export function useChat(sessionId?: string) {
  const [messages, setMessages] = useState<Message[]>([])
  const [isLoading, setIsLoading] = useState(false)

  const sendMessage = useCallback(async (content: string) => {
    // ...
  }, [sessionId])

  return {
    messages,
    isLoading,
    sendMessage,
  }
}
```

## 样式规范

### Tailwind CSS

```tsx
// 使用 cn 函数合并类名
import { cn } from "@/lib/cn"

function Button({ className, ...props }) {
  return (
    <button
      className={cn(
        "px-4 py-2 rounded-lg font-medium",
        "bg-primary text-primary-foreground",
        "hover:bg-primary/90",
        "transition-colors",
        className  // 允许外部覆盖
      )}
      {...props}
    />
  )
}
```

### 响应式断点

```tsx
// 移动端优先
<div className="
  flex flex-col          // 默认纵向
  md:flex-row            // md 及以上横向
  lg:items-center        // lg 及以上居中
">
  {/* ... */}
</div>
```

## 状态管理规范

### Zustand Store

```typescript
// stores/authStore.ts
import { create } from "zustand"

interface AuthState {
  // State
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean

  // Actions
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  fetchUser: () => Promise<void>
}

export const useAuthStore = create<AuthState>((set, get) => ({
  // 初始状态
  user: null,
  isAuthenticated: false,
  isLoading: false,

  // Actions
  login: async (email, password) => {
    set({ isLoading: true })
    try {
      const { data } = await api.post("/v1/auth/login", { email, password })
      set({ user: data.user, isAuthenticated: true })
    } finally {
      set({ isLoading: false })
    }
  },

  logout: () => {
    set({ user: null, isAuthenticated: false })
  },

  fetchUser: async () => {
    const { data } = await api.get("/v1/auth/me")
    set({ user: data.user })
  },
}))
```

## API 调用规范

### 封装请求

```typescript
// services/api.ts
const API_BASE = "/api/v1"

class ApiError extends Error {
  constructor(
    public type: string,
    public code: string,
    message: string,
    public status: number
  ) {
    super(message)
  }
}

export const api = {
  async request<T>(url: string, options?: RequestInit): Promise<T> {
    const token = localStorage.getItem("token")

    const response = await fetch(API_BASE + url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...(token && { Authorization: `Bearer ${token}` }),
        ...options?.headers,
      },
    })

    const data = await response.json()

    if (!response.ok) {
      if (response.status === 401) {
        localStorage.removeItem("token")
        window.location.href = "/login"
      }
      throw new ApiError(
        data.error.type,
        data.error.code,
        data.error.message,
        response.status
      )
    }

    return data.data
  },

  get<T>(url: string) {
    return this.request<T>(url, { method: "GET" })
  },

  post<T>(url: string, body?: unknown) {
    return this.request<T>(url, {
      method: "POST",
      body: body ? JSON.stringify(body) : undefined,
    })
  },

  patch<T>(url: string, body?: unknown) {
    return this.request<T>(url, {
      method: "PATCH",
      body: body ? JSON.stringify(body) : undefined,
    })
  },

  delete<T>(url: string) {
    return this.request<T>(url, { method: "DELETE" })
  },
}
```

### SSE 流式请求

```typescript
// services/chat.ts
export async function streamChat(
  sessionId: string | null,
  message: string,
  onMessage: (content: string) => void,
  onSession: (sessionId: string) => void,
  onDone: () => void,
  onError: (error: Error) => void
) {
  const token = localStorage.getItem("token")

  const response = await fetch("/api/chat/v1/stream", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    },
    body: JSON.stringify({ session_id: sessionId, message }),
  })

  const reader = response.body?.getReader()
  const decoder = new TextDecoder()

  while (reader) {
    const { done, value } = await reader.read()
    if (done) break

    const text = decoder.decode(value)
    const lines = text.split("\n")

    for (const line of lines) {
      if (line.startsWith("data: ")) {
        const data = JSON.parse(line.slice(6))

        switch (data.type) {
          case "session":
            onSession(data.session_id)
            break
          case "message":
            onMessage(data.content)
            break
          case "done":
            onDone()
            break
          case "error":
            onError(new Error(data.message))
            break
        }
      }
    }
  }
}
```

## Git 规范

### 分支命名

```
main              主分支
develop           开发分支
feature/xxx       功能分支
fix/xxx           修复分支
refactor/xxx      重构分支
```

### Commit 规范

```
feat: 新增功能
fix: 修复 bug
refactor: 重构
style: 代码格式
docs: 文档
chore: 构建/工具
test: 测试
perf: 性能优化

示例:
feat: 添加对话面板组件
fix: 修复登录状态丢失问题
refactor: 重构 API 请求封装
```

## 开发命令

```bash
# 安装依赖
pnpm install

# 开发环境
pnpm dev

# 开发环境 + Mock
pnpm dev:mock

# 构建
pnpm build

# 预览构建结果
pnpm preview

# 代码检查
pnpm lint
pnpm lint:fix

# 类型检查
pnpm typecheck

# 单元测试
pnpm test
pnpm test:watch
pnpm test:coverage

# E2E 测试
pnpm test:e2e
```

## 依赖清单

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.22.0",
    "zustand": "^4.5.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0",
    "lucide-react": "^0.340.0",
    "class-variance-authority": "^0.7.0",
    "@radix-ui/react-dialog": "^1.0.5",
    "@radix-ui/react-dropdown-menu": "^2.0.6",
    "@radix-ui/react-label": "^2.0.2",
    "@radix-ui/react-slot": "^1.0.2",
    "@radix-ui/react-switch": "^1.0.3"
  },
  "devDependencies": {
    "vite": "^5.1.0",
    "typescript": "^5.3.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.2.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "eslint": "^8.56.0",
    "@antfu/eslint-config": "^2.6.0",
    "prettier": "^3.2.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.2.0",
    "msw": "^2.2.0",
    "vitest": "^1.3.0",
    "@testing-library/react": "^14.2.0",
    "@testing-library/jest-dom": "^6.4.0",
    "@playwright/test": "^1.41.0"
  }
}
```
