# tiz-web 前端开发任务清单

## 阶段一：项目初始化

### 1.1 创建项目
- [x] 使用 Vite 创建 React + TypeScript 项目
  ```bash
  pnpm create vite tiz-web --template react-ts
  cd tiz-web
  pnpm install
  ```

### 1.2 配置 Tailwind CSS
- [x] 安装 Tailwind CSS 及相关依赖
  ```bash
  pnpm add -D tailwindcss autoprefixer postcss
  pnpm exec tailwindcss init -p
  ```
- [x] 配置 `tailwind.config.js`
- [x] 配置 `postcss.config.js`
- [x] 添加 Tailwind 指令到 `index.css`

### 1.3 安装 shadcn/ui
- [x] 初始化 shadcn/ui
  ```bash
  pnpm dlx shadcn-ui@latest init
  ```
- [x] 安装常用组件
  ```bash
  pnpm dlx shadcn-ui@latest add button input card dialog sheet tabs avatar dropdown-menu label textarea switch toast
  ```

### 1.4 配置代码规范
- [x] 安装 ESLint + Prettier
  ```bash
  pnpm add -D eslint @antfu/eslint-config prettier
  ```
- [x] 配置 `.eslintrc.js`
- [x] 配置 `.prettierrc`
- [x] 配置 Husky + lint-staged
  ```bash
  pnpm add -D husky lint-staged
  pnpm exec husky init
  ```

### 1.5 配置路径别名
- [x] 配置 `vite.config.ts` 添加 `@` 别名
- [x] 配置 `tsconfig.json` 添加路径映射

---

## 阶段二：基础架构

### 2.1 目录结构
- [x] 创建标准目录结构
  ```
  src/
  ├── app/
  ├── components/
  │   ├── ui/
  │   ├── layout/
  │   ├── chat/
  │   ├── question/
  │   ├── library/
  │   ├── quiz/
  │   └── common/
  ├── hooks/
  ├── stores/
  ├── services/
  ├── types/
  ├── lib/
  └── mocks/
  ```

### 2.2 工具函数
- [x] 创建 `lib/cn.ts` (className 合并)
- [x] 创建 `lib/utils.ts` (通用工具函数)
- [x] 创建 `lib/storage.ts` (localStorage 封装)

### 2.3 类型定义
- [x] 创建 `types/user.ts`
- [x] 创建 `types/chat.ts`
- [x] 创建 `types/question.ts`
- [x] 创建 `types/library.ts`
- [x] 创建 `types/api.ts`
- [x] 创建 `types/index.ts` (统一导出)

---

## 阶段三：状态管理

### 3.1 Zustand Stores
- [x] 创建 `stores/authStore.ts` (认证状态)
- [x] 创建 `stores/chatStore.ts` (对话状态)
- [x] 创建 `stores/libraryStore.ts` (题库状态)
- [x] 创建 `stores/practiceStore.ts` (练习状态)
- [x] 创建 `stores/quizStore.ts` (测验状态)
- [x] 创建 `stores/uiStore.ts` (UI 状态)

---

## 阶段四：API 层

### 4.1 API 封装
- [x] 创建 `services/api.ts` (基础请求封装)
  - 统一错误处理
  - Token 注入
  - 401 自动跳转

### 4.2 服务模块
- [x] 创建 `services/auth.ts`
- [x] 创建 `services/chat.ts` (含 SSE 流式处理)
- [x] 创建 `services/content.ts`
- [x] 创建 `services/practice.ts`
- [x] 创建 `services/quiz.ts`
- [x] 创建 `services/user.ts`

---

## 阶段五：Mock 服务

### 5.1 MSW 配置
- [x] 安装 MSW
  ```bash
  pnpm add -D msw
  pnpm exec msw init public/ --save
  ```
- [x] 创建 `mocks/browser.ts`
- [x] 在 `main.tsx` 中配置 MSW 启动

### 5.2 Mock Handlers
- [x] 创建 `mocks/handlers/auth.ts`
- [x] 创建 `mocks/handlers/chat.ts`
- [x] 创建 `mocks/handlers/content.ts`
- [x] 创建 `mocks/handlers/practice.ts`
- [x] 创建 `mocks/handlers/quiz.ts`
- [x] 创建 `mocks/handlers/user.ts`
- [x] 创建 `mocks/handlers/index.ts` (统一导出)

### 5.3 Mock 数据
- [x] 创建 `mocks/data/users.ts`
- [x] 创建 `mocks/data/questions.ts`
- [x] 创建 `mocks/data/library.ts`

---

## 阶段六：布局组件

### 6.1 通用布局
- [x] 创建 `components/layout/AppLayout.tsx` (主布局)
- [x] 创建 `components/layout/Sidebar.tsx` (侧边栏)
- [x] 创建 `components/layout/Header.tsx` (顶部栏)
- [x] 创建 `components/layout/AuthLayout.tsx` (认证页面布局)

### 6.2 通用组件
- [x] 创建 `components/common/ThemeToggle.tsx`
- [x] 创建 `components/common/UserMenu.tsx`
- [x] 创建 `components/common/EmptyState.tsx`
- [x] 创建 `components/common/LoadingState.tsx`
- [x] 创建 `components/common/PageError.tsx`
- [x] 创建 `components/common/ErrorBoundary.tsx`
- [x] 创建 `components/common/ProtectedRoute.tsx`

---

## 阶段七：页面开发

### 7.1 路由配置
- [x] 安装 react-router-dom
  ```bash
  pnpm add react-router-dom
  ```
- [x] 创建 `router.tsx` (路由配置)
- [x] 配置路由守卫

### 7.2 公开页面
- [x] 创建落地页 `app/landing/LandingPage.tsx`
- [x] 创建登录页 `app/(auth)/login/LoginPage.tsx`
- [x] 创建注册页 `app/(auth)/register/RegisterPage.tsx`
- [x] 创建试用对话页 `app/chat/ChatPage.tsx`
- [x] 创建 404 页面 `app/not-found/NotFoundPage.tsx`

### 7.3 登录后页面
- [x] 创建首页 `app/(main)/home/HomePage.tsx`
- [x] 创建题库页 `app/(main)/library/LibraryPage.tsx`
- [x] 创建练习页 `app/(main)/practice/PracticePage.tsx`
- [x] 创建测验页 `app/(main)/quiz/QuizPage.tsx`
- [x] 创建结果页 `app/(main)/result/ResultPage.tsx`
- [x] 创建设置页 `app/(main)/settings/SettingsPage.tsx`

---

## 阶段八：业务组件

### 8.1 对话组件
- [x] 创建 `components/chat/ChatPanel.tsx`
- [x] 创建 `components/chat/ChatMessage.tsx`
- [x] 创建 `components/chat/ChatInput.tsx`
- [x] 创建 `components/chat/ChatConfirm.tsx`
- [x] 创建 `components/chat/TypingIndicator.tsx`

### 8.2 题目组件
- [x] 创建 `components/question/QuestionCard.tsx`
- [x] 创建 `components/question/ChoiceQuestion.tsx`
- [x] 创建 `components/question/EssayQuestion.tsx`
- [x] 创建 `components/question/QuestionNav.tsx`
- [x] 创建 `components/question/QuestionProgress.tsx`
- [x] 创建 `components/question/AnswerFeedback.tsx`

### 8.3 题库组件
- [x] 创建 `components/library/LibraryList.tsx`
- [x] 创建 `components/library/LibraryCard.tsx`
- [x] 创建 `components/library/LibraryFilter.tsx`
- [x] 创建 `components/library/TagList.tsx`

### 8.4 测验组件
- [x] 创建 `components/quiz/QuizTimer.tsx`
- [x] 创建 `components/quiz/QuizResult.tsx`
- [x] 创建 `components/quiz/WrongAnswerReview.tsx`

---

## 阶段九：自定义 Hooks

- [x] 创建 `hooks/useAuth.ts`
- [x] 创建 `hooks/useChat.ts`
- [x] 创建 `hooks/useTheme.ts`
- [x] 创建 `hooks/useMediaQuery.ts`

---

## 阶段十：主题系统

- [x] 配置深色/浅色/自动主题
- [x] 创建主题切换逻辑
- [x] 配置 CSS 变量

---

## 阶段十一：响应式适配

- [x] 侧边栏移动端适配 (汉堡菜单 + 抽屉)
- [x] 对话面板移动端适配
- [x] 题目卡片移动端适配
- [x] 题库列表移动端适配
- [x] 测验页面移动端适配

---

## 阶段十二：测试

### 12.1 单元测试
- [x] 配置 Vitest
- [x] 编写 utils 函数测试
- [x] 编写 hooks 测试
- [x] 编写 store 测试

### 12.2 组件测试
- [x] 配置 @testing-library/react
- [x] 编写通用组件测试

---

## 阶段十三：部署配置

- [x] 创建 `Dockerfile`
- [x] 创建 `nginx.conf`
- [x] 创建 `.env.example`
- [x] 配置生产环境构建

---

## 优先级建议

```
P0 (核心流程):
  阶段一 → 阶段二 → 阶段四 → 阶段五 → 阶段六 → 阶段七.1-7.2 → 阶段八.1-8.2

P1 (完整功能):
  阶段三 → 阶段七.3 → 阶段八.3-8.4 → 阶段九 → 阶段十

P2 (优化完善):
  阶段十一 → 阶段十二 → 阶段十三
```

---

## 开发顺序建议

```
Week 1: 项目搭建 + 核心组件
├── 阶段一：项目初始化
├── 阶段二：基础架构
├── 阶段四：API 层
├── 阶段五：Mock 服务
├── 阶段六：布局组件
└── 阶段七.1-7.2：路由 + 公开页面

Week 2: 核心业务
├── 阶段三：状态管理
├── 阶段八.1：对话组件
├── 阶段八.2：题目组件
├── 阶段七.3：登录后页面
└── 阶段十：主题系统

Week 3: 完善功能
├── 阶段八.3-8.4：题库 + 测验组件
├── 阶段九：自定义 Hooks
├── 阶段十一：响应式适配
└── 阶段十二：测试

Week 4: 部署上线
├── 阶段十三：部署配置
└── 联调测试
```
