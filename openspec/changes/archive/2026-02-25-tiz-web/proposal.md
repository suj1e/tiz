# tiz-web: AI 驱动的知识练习平台

## 文档清单

| 文档 | 路径 | 说明 |
|------|------|------|
| 产品方案 | `openspec/changes/tiz-web/proposal.md` | 本文档 |
| 前端规范 | `standards/frontend.md` | 前端开发规范 |
| 后端规范 | `standards/backend.md` | 后端开发规范 |
| API 文档 | `standards/api.md` | 接口详细文档 |
| Postman | `standards/postman.json` | Postman Collection |

## 概述

tiz-web 是一个基于 AI 的知识练习平台 Web 端。用户通过对话式交互，与 AI 一起探索学习需求，然后生成个性化的练习题和测验。

## 目标

- 让用户通过自然语言对话，轻松生成专属练习题
- 支持选择题和简答题两种题型
- 提供练习模式和测验模式
- 用户可保存题库，随时回顾和练习

## 核心功能

### 1. 对话式探索

用户不需要写精准的 prompt，而是通过对话让 AI 理解需求：

- 用户输入想学习的主题/目标
- AI 主动提问，澄清需求细节
- 双方达成共识后，确认生成

### 2. AI 生成题目

- **题型**：选择题、简答题（可配置）
- **难度**：AI 根据对话自动判断
- **分类和标签**：AI 生成，用户可调整
- **简答题评分**：AI 分析匹配答案

### 3. 练习模式

- 无时间限制
- 即时显示答案和解析
- 难度由用户选择

### 4. 测验模式

- 限时
- 打分（选择题不倒扣，简答题 AI 评分）
- 题目数量用户可定义
- 完成后显示结果报告和错题回顾

### 5. 题库管理

- 保存生成的题目到个人题库
- 按分类/标签筛选
- 搜索、编辑、删除
- 再次练习或测验

### 6. 试用体验

- 未登录用户可以试用对话和生成题目
- 保存题库时提示登录/注册

## 用户流程

```
访问落地页 → 开始试用(对话) → AI生成题目 → 练习/测验
     ↓              ↓              ↓           ↓
  点击注册      探索需求        预览调整      查看结果
     ↓              ↓              ↓           ↓
  创建账号      确认生成        选择模式      保存题库
```

## 页面清单

### 公开页面（无需登录）

| 路径 | 页面 | 说明 |
|------|------|------|
| `/` | 落地页 | 产品介绍，开始使用入口 |
| `/login` | 登录 | 邮箱 + 密码登录 |
| `/register` | 注册 | 邮箱 + 密码注册 |
| `/chat` | 试用对话 | 未登录可用的对话探索 |

### 登录后页面

| 路径 | 页面 | 说明 |
|------|------|------|
| `/home` | 首页 | 对话探索界面 |
| `/library` | 我的题库 | 管理保存的题目 |
| `/generate/:id` | 生成结果 | 预览生成的题目，选择模式 |
| `/practice/:id` | 练习模式 | 做练习题 |
| `/quiz/:id` | 测验模式 | 限时测验 |
| `/result/:id` | 结果页 | 测验结果和错题回顾 |
| `/settings` | 设置 | 主题切换、账号设置 |

## 数据模型（初步）

### User（用户）
- id
- email
- password_hash
- created_at

### KnowledgeSet（知识集）
- id
- user_id
- title
- category（分类）
- tags[]（标签）
- source_prompt（原始对话）
- difficulty（难度）
- created_at
- questions[]（题目列表）

### Question（题目）
- id
- type（choice | essay）
- content（题干）
- options[]（选项，选择题用）
- answer（答案）
- explanation（解析）
- rubric（评分标准，简答题用）

### QuizAttempt（测验记录）
- id
- user_id
- knowledge_set_id
- score
- answers[]
- completed_at

## 技术栈

### 核心技术

| 类别 | 技术 | 说明 |
|------|------|------|
| 包管理器 | pnpm | 快速、节省磁盘、严格依赖管理 |
| 构建工具 | Vite 5.x | 快速开发体验 |
| 框架 | React 18 + TypeScript 5.x (strict) | 类型安全 |
| 路由 | React Router 6.x | 声明式路由 |
| 状态管理 | Zustand | 轻量、简单 |
| UI | shadcn/ui + Tailwind CSS + Radix UI | 极简风格、深色/浅色主题 |
| 图标 | Lucide React | 丰富的图标库 |
| 流式处理 | 原生 fetch + ReadableStream | 灵活适配后端 |
| Mock | MSW 2.x | 前后端并行开发 |
| 部署 | Docker + Nginx | 统一管理 |

### 代码规范

| 类别 | 工具 | 说明 |
|------|------|------|
| ESLint | @antfu/eslint-config | 现代、规则宽松 |
| 格式化 | Prettier | 配合 ESLint |
| Git Hooks | Husky + lint-staged | 提交前检查 |
| 提交规范 | Conventional Commits | feat/fix/refactor 等 |

### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件夹 | kebab-case | `user-profile` |
| 组件文件 | PascalCase | `ChatMessage.tsx` |
| Hook 文件 | camelCase + use 前缀 | `useChat.ts` |
| 工具文件 | camelCase | `utils.ts` |
| 类型文件 | camelCase | `chat.ts` |
| 常量 | UPPER_SNAKE_CASE | `API_BASE_URL` |

### 目录结构

```
tiz-web/
├── src/
│   ├── app/                    # 路由和页面
│   │   ├── (auth)/             # 登录/注册 (layout)
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── (main)/             # 需要登录 (layout)
│   │   │   ├── home/
│   │   │   ├── library/
│   │   │   ├── practice/
│   │   │   ├── quiz/
│   │   │   ├── result/
│   │   │   └── settings/
│   │   ├── chat/               # 试用对话
│   │   └── layout.tsx
│   ├── components/             # 通用组件
│   │   ├── ui/                 # shadcn/ui
│   │   ├── chat/               # 对话组件
│   │   ├── question/           # 题目组件
│   │   └── layout/             # 布局组件
│   ├── hooks/                  # 自定义 hooks
│   ├── stores/                 # Zustand stores
│   ├── services/               # API 调用
│   ├── types/                  # TypeScript 类型
│   ├── lib/                    # 工具函数
│   └── mocks/                  # MSW mocks
├── public/
├── Dockerfile
├── .github/
│   └── workflows/
│       └── ci.yml
├── tailwind.config.js
├── tsconfig.json
├── vite.config.ts
└── package.json
```

### 后端对接

- **API 网关**：gatewaysrv（Java/Spring Cloud Gateway）
- **AI 模型**：国产模型，流式输出
- **接口文档**：前端先行设计，后端配合实现

### 网关路由配置

```
/api/auth/v1/**     → auth-service
/api/chat/v1/**     → chat-service
/api/content/v1/**  → content-service
/api/practice/v1/** → practice-service
/api/quiz/v1/**     → quiz-service
/api/user/v1/**     → user-service
```

## API 接口设计

### 路径规范

```
/api/{service}/v1/{resource}

示例：/api/auth/v1/login
      /api/content/v1/library
```

### 微服务划分

| 服务 | 前缀 | 职责 |
|------|------|------|
| authsrv | /api/auth/v1 | 认证：注册、登录、登出、用户信息 |
| chatsrv | /api/chat/v1 | 对话：SSE 流式对话、确认生成 |
| contentsrv | /api/content/v1 | 内容：题库管理、分类、标签、生成题目 |
| practicesrv | /api/practice/v1 | 练习：开始练习、提交答案 |
| quizsrv | /api/quiz/v1 | 测验：开始测验、提交测验、获取结果 |
| usersrv | /api/user/v1 | 用户：设置、偏好 |

### 统一响应结构

参考 Stripe API 设计规范：

```typescript
// 成功响应
{
  "data": { ... }
}

// 错误响应
{
  "error": {
    "type": "validation_error",    // 错误类型（大类）
    "code": "email_exists",        // 具体错误码
    "message": "该邮箱已被注册"     // 用户友好提示
  }
}
```

### HTTP 状态码

| 状态码 | 含义 | 错误类型 |
|--------|------|----------|
| 200 | 成功 | - |
| 201 | 创建成功 | - |
| 400 | 参数错误 | validation_error |
| 401 | 未认证 | authentication_error |
| 403 | 无权限 | permission_error |
| 404 | 不存在 | not_found_error |
| 429 | 请求过多 | rate_limit_error |
| 500 | 服务器错误 | api_error |

### 错误类型

| type | 说明 | 常见 code |
|------|------|-----------|
| validation_error | 参数校验错误 | missing_field, invalid_email, email_exists |
| authentication_error | 认证错误 | invalid_credentials, token_invalid, token_expired |
| permission_error | 权限错误 | forbidden |
| not_found_error | 资源不存在 | user_not_found, resource_not_found |
| rate_limit_error | 请求频繁 | too_many_requests |
| api_error | 服务器错误 | internal_error, ai_service_error |

### 接口列表

#### 认证模块 (auth-service)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/auth/v1/register | 注册 | 否 |
| POST | /api/auth/v1/login | 登录 | 否 |
| POST | /api/auth/v1/logout | 登出 | 是 |
| GET | /api/auth/v1/me | 获取当前用户 | 是 |

#### 对话模块 (chat-service)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/chat/v1/stream | 对话探索（SSE） | 可选 |
| POST | /api/chat/v1/confirm | 确认生成题目 | 是 |
| GET | /api/chat/v1/history/:id | 获取对话历史 | 是 |

#### 内容模块 (content-service)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/content/v1/generate | 生成题目（同步分批） | 是 |
| GET | /api/content/v1/generate/:id/batch | 获取后续批次 | 是 |
| GET | /api/content/v1/library | 获取题库列表 | 是 |
| GET | /api/content/v1/library/:id | 获取题库详情 | 是 |
| PATCH | /api/content/v1/library/:id | 更新题库 | 是 |
| DELETE | /api/content/v1/library/:id | 删除题库 | 是 |
| GET | /api/content/v1/categories | 获取分类列表 | 是 |
| GET | /api/content/v1/tags | 获取标签列表 | 是 |

#### 练习模块 (practice-service)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/practice/v1/start | 开始练习 | 是 |
| POST | /api/practice/v1/:id/answer | 提交答案 | 是 |
| POST | /api/practice/v1/:id/complete | 完成练习 | 是 |

#### 测验模块 (quiz-service)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/quiz/v1/start | 开始测验 | 是 |
| POST | /api/quiz/v1/:id/submit | 提交测验 | 是 |
| GET | /api/quiz/v1/result/:id | 获取测验结果 | 是 |

#### 用户模块 (user-service)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | /api/user/v1/settings | 获取用户设置 | 是 |
| PATCH | /api/user/v1/settings | 更新用户设置 | 是 |

### SSE 事件格式

```
event: session
data: {"session_id": "xxx"}

event: message
data: {"content": "你好！想学什么？"}

event: confirm
data: {"summary": {...}}

event: done
data: {}

event: error
data: {"type": "api_error", "code": "ai_service_error", "message": "AI 服务异常"}
```

## 组件设计

### 组件分层

```
页面组件 (Pages)
├── LoginPage, HomePage, LibraryPage, ...
│   └── 业务组件 (Features)
│       ├── ChatPanel, QuestionCard, QuizTimer, ...
│       └── 基础组件 (UI - shadcn/ui)
│           └── Button, Input, Dialog, Card, ...
```

### 核心组件

#### 布局组件 (layout/)

| 组件 | 说明 |
|------|------|
| AppLayout | 整体布局（侧边栏 + 主内容） |
| Sidebar | 侧边导航 |
| Header | 顶部栏（主题切换、用户菜单） |
| AuthLayout | 认证页面布局（居中卡片） |

#### 对话组件 (chat/)

| 组件 | 说明 |
|------|------|
| ChatPanel | 对话面板（消息列表 + 输入框） |
| ChatMessage | 单条消息（用户/AI） |
| ChatInput | 消息输入框 |
| ChatConfirm | 确认生成卡片 |
| TypingIndicator | AI 输入中动画 |

#### 题目组件 (question/)

| 组件 | 说明 |
|------|------|
| QuestionCard | 题目卡片（题干 + 选项/输入） |
| ChoiceQuestion | 选择题 |
| EssayQuestion | 简答题 |
| QuestionNav | 题目导航（上一题/下一题） |
| QuestionProgress | 进度条 |
| AnswerFeedback | 答案反馈（正确/错误 + 解析） |

#### 题库组件 (library/)

| 组件 | 说明 |
|------|------|
| LibraryList | 题库列表 |
| LibraryCard | 题库卡片 |
| LibraryFilter | 筛选器（分类、标签） |
| TagList | 标签列表 |

#### 测验组件 (quiz/)

| 组件 | 说明 |
|------|------|
| QuizTimer | 倒计时 |
| QuizResult | 测验结果 |
| WrongAnswerReview | 错题回顾 |

#### 通用组件 (common/)

| 组件 | 说明 |
|------|------|
| ThemeToggle | 主题切换 |
| UserMenu | 用户菜单 |
| EmptyState | 空状态 |
| LoadingState | 加载状态 |
| ErrorBoundary | 错误边界 |

### 目录结构

```
src/components/
├── ui/              # shadcn/ui 基础组件
├── layout/          # 布局组件
├── chat/            # 对话组件
├── question/        # 题目组件
├── library/         # 题库组件
├── quiz/            # 测验组件
└── common/          # 通用组件
```

## 状态设计 (Zustand)

### Store 划分

| Store | 职责 |
|-------|------|
| authStore | 用户信息、登录状态、token |
| chatStore | 会话 ID、消息列表、生成摘要、加载状态 |
| libraryStore | 题库列表、分类、标签、筛选条件 |
| practiceStore | 当前练习、题目、答案、进度 |
| quizStore | 当前测验、题目、答案、计时、结果 |
| uiStore | 主题、侧边栏状态 |

### 核心类型定义

```typescript
interface User {
  id: string
  email: string
  created_at: string
  settings: { theme: "light" | "dark" | "system" }
}

interface Message {
  id: string
  role: "user" | "assistant"
  content: string
  created_at: string
}

interface Question {
  id: string
  type: "choice" | "essay"
  content: string
  options?: string[]
  answer: string
  explanation?: string
}

interface KnowledgeSet {
  id: string
  title: string
  category: string
  tags: string[]
  difficulty: "easy" | "medium" | "hard"
  question_count: number
  created_at: string
}
```

## Mock 方案

### 使用 MSW (Mock Service Worker)

```
浏览器 fetch → Service Worker (MSW) → Mock 响应 / 真实后端
```

### 目录结构

```
src/mocks/
├── handlers/       # 接口 mock 处理
│   ├── auth.ts
│   ├── chat.ts
│   ├── library.ts
│   ├── practice.ts
│   └── quiz.ts
├── data/           # 模拟数据
├── browser.ts      # 浏览器端启动
└── server.ts       # Node 端启动
```

### 环境控制

```bash
# 开发时使用 mock
VITE_MOCK=true pnpm dev

# 联调时使用真实后端
VITE_MOCK=false pnpm dev
```

### Mock 策略

| 阶段 | 策略 |
|------|------|
| 开发阶段 | VITE_MOCK 控制是否使用 mock |
| 联调阶段 | 部分接口 mock，部分真实后端 |
| 生产阶段 | MSW 完全关闭 |

## 路由设计

### 路由结构

```typescript
// 公开页面
"/"              → LandingPage
"/login"         → LoginPage
"/register"      → RegisterPage
"/chat"          → ChatPage (试用，无需登录)

// 需要登录
"/home"          → HomePage
"/library"       → LibraryPage
"/practice/:id"  → PracticePage
"/quiz/:id"      → QuizPage
"/result/:id"    → ResultPage
"/settings"      → SettingsPage

// 404
"*"              → NotFoundPage
```

### 路由守卫

- 使用 `ProtectedRoute` 组件包装需要登录的页面
- 未登录时跳转到 `/login`，保存原路径
- 登录成功后跳转回原页面

### 懒加载

- 所有页面组件使用 `React.lazy()` 懒加载
- 使用 `Suspense` 包装，显示加载状态

## 错误处理

### 分层

1. **全局错误边界** - 捕获 React 渲染错误
2. **API 错误拦截** - 统一处理 HTTP 错误
3. **组件级错误** - 局部错误提示 (Toast)
4. **表单错误** - 字段级错误展示

### API 错误处理

- 封装 `api` 请求工具类
- 401 自动跳转登录
- 统一 Toast 提示错误信息

## 性能优化

- 路由懒加载
- 组件懒加载 (大型组件)
- 数据缓存 (5 分钟 TTL)
- 图片懒加载
- 按需引入图标

## 测试策略

### 测试工具

- Vitest - 单元测试
- @testing-library/react - 组件测试
- Playwright - E2E 测试

### 测试范围

| 类型 | 范围 |
|------|------|
| 单元测试 | utils、hooks、store |
| 组件测试 | 通用组件 |
| E2E 测试 | 登录流程、对话流程、做题流程 |

## CI/CD

### GitHub Actions

```yaml
main 分支 push / PR:
  1. pnpm install
  2. pnpm lint
  3. pnpm typecheck
  4. pnpm test
  5. pnpm build
  6. pnpm test:e2e (可选)
  7. docker build & push (main 分支)
```

### Dockerfile

- 多阶段构建
- node:20-alpine 构建
- nginx:alpine 运行

### Nginx 配置

- SPA 路由支持
- /api 代理到后端
- SSE 流式支持
- 静态资源缓存
- gzip 压缩

### 开发命令

```bash
pnpm dev          # 开发环境
pnpm dev:mock     # 开发环境 + Mock
pnpm build        # 构建
pnpm lint         # 代码检查
pnpm test         # 单元测试
pnpm test:e2e     # E2E 测试
```

## 响应式设计

### 断点定义

| 断点 | 宽度 | 设备 |
|------|------|------|
| sm | 640px | 手机横屏 |
| md | 768px | 平板 |
| lg | 1024px | 小屏电脑 |
| xl | 1280px | 桌面 |

### 关键调整

| 组件 | PC (lg+) | 移动端 (< lg) |
|------|----------|---------------|
| Sidebar | 固定左侧 | 汉堡菜单 + 抽屉 |
| ChatPanel | 居中，max-width | 全屏 |
| QuestionCard | 居中卡片 | 全屏 |
| ChoiceQuestion | 选项 2 列 | 选项 1 列 |
| LibraryList | 多列 grid | 单列 |
| LibraryCard | 横向布局 | 纵向堆叠 |

### 技术实现

- Tailwind CSS 响应式类 (sm:, md:, lg:)
- shadcn/ui 组件自带响应式
- useMediaQuery hook 检测屏幕尺寸

## 非目标（MVP 阶段不做）

- 管理后台
- 找回密码/重置密码
- 邮箱验证
- 分享题目给其他用户
- 多语言支持
- 移动端 App（响应式 Web 已覆盖）

## 后续迭代方向

- 重置密码功能
- 邮箱验证
- 社交分享
- 更多题型（填空、代码题等）
- 学习数据统计和分析
- AI 学习建议和路径规划
