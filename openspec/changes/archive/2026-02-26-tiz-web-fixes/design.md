# 设计文档

## 1. 题库 API 响应修复

### 问题分析

```
当前问题:
- content.ts getLibraries() 返回类型: PaginatedResponse<KnowledgeSetSummary>
- 但 api.get() 会自动提取 response.data
- 导致实际返回的是数组，而不是 { data: [], pagination: {} }

Mock 返回:
{ data: [...], pagination: {...} }

api.get() 提取后:
[...]  // 只剩数组

LibraryPage 期望:
{ data: [...], pagination: {...} }
```

### 解决方案

修改 `services/content.ts`：

```typescript
// 方案 A: 修改返回类型，承认 api.get() 的行为
getLibraries(): Promise<{ data: KnowledgeSetSummary[]; pagination: {...} }> {
  // 需要修改 api.ts 让它不自动提取 data，或
  // 修改这里的处理逻辑
}

// 方案 B: 让 api.request 返回完整响应，由调用方提取
// 在 api.ts 中添加一个选项
```

**选择方案**: 修改 `api.ts` 添加 `raw` 选项，让 `getLibraries` 获取完整响应。

### 影响文件

- `src/services/api.ts` - 添加 raw 选项
- `src/services/content.ts` - 修改 getLibraries、getCategories、getTags 调用
- `src/app/(main)/library/LibraryPage.tsx` - 修复数据解构

## 2. 错误处理架构

### 设计

```
┌─────────────────────────────────────────────────────────────┐
│ Router                                                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ errorElement: <RootErrorBoundary />                     │ │
│ │ ┌─────────────────────────────────────────────────────┐ │ │
│ │ │ AppLayout                                           │ │ │
│ │ │ ┌─────────────────────────────────────────────────┐ │ │ │
│ │ │ │ LibraryPage                                     │ │ │ │
│ │ │ │ const [error, setError] = useState()            │ │ │ │
│ │ │ │ if (error) return <PageError onRetry={load} />  │ │ │ │
│ │ │ └─────────────────────────────────────────────────┘ │ │ │
│ │ └─────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 新增组件

1. **RootErrorBoundary** - 路由级错误边界，捕获懒加载失败等
2. **优化 ErrorBoundary** - 美化现有组件样式
3. **PageError 使用** - 在各页面数据加载失败时使用

### 影响文件

- `src/router.tsx` - 添加 errorElement
- `src/components/common/ErrorBoundary.tsx` - 优化样式
- `src/app/(main)/library/LibraryPage.tsx` - 添加错误状态
- 其他页面 - 添加错误状态处理

## 3. 主题切换统一

### 当前状态

| 页面 | 有 ThemeToggle |
|------|---------------|
| LandingPage | ❌ |
| LoginPage | ❌ |
| RegisterPage | ❌ |
| ChatPage | ❌ |
| HomePage (及登录后页面) | ✅ (在 Header 中) |

### 设计

在以下位置添加 ThemeToggle：

1. **LandingPage** - Header 右侧，登录按钮左边
2. **LoginPage/RegisterPage** - 已有 AuthLayout，在其中添加
3. **ChatPage** - Header 右侧

### 影响文件

- `src/app/landing/LandingPage.tsx`
- `src/components/layout/AuthLayout.tsx`
- `src/app/chat/ChatPage.tsx`

## 4. 导航结构优化

### 当前问题

```
侧边栏:
├── 首页 /home → HomePage (聊天界面)
├── 题库 /library → LibraryPage
├── 对话 /chat → ChatPage (聊天界面)  ← 重复
└── 设置 /settings → SettingsPage
```

### 方案选择

**方案 A**: 首页改为仪表盘，对话保留
- /home → 仪表盘（学习统计、最近题库、快速入口）
- /chat → 试用对话（未登录）/ 正式对话（已登录）

**方案 B**: 合并对话到首页，侧边栏去掉对话
- /home → 聊天界面
- 去掉侧边栏的"对话"入口

**选择方案**: 方案 B 更简单，符合当前产品定位

### 影响文件

- `src/components/layout/Sidebar.tsx` - 移除对话入口
- `src/router.tsx` - 调整路由（可选保留 /chat 作为重定向）

## 5. 设置页完善

### 新增功能

1. **Webhook 配置**
   - Webhook URL 输入
   - 事件选择（练习完成、测验完成等）
   - 测试 Webhook 按钮

2. **账户信息**
   - 头像（暂用默认）
   - 邮箱显示
   - 修改密码入口
   - 账户删除（危险操作）

### 影响文件

- `src/app/(main)/settings/SettingsPage.tsx`
- `src/types/user.ts` - 扩展用户类型（如需要）

## 6. 项目图标

### 需要生成

1. `favicon.ico` - 32x32
2. `favicon.svg` - 矢量图标
3. `apple-touch-icon.png` - 180x180
4. 可选: `og-image.png` - 社交分享

### 设计方向

- 使用 "T" 字母或书本图标
- 主色调: 项目的 primary 颜色
- 简洁、现代风格

### 影响文件

- `public/favicon.ico`
- `public/favicon.svg`
- `public/apple-touch-icon.png`
- `index.html` - 更新 link 标签

## 7. 版权年份

### 修改

`src/app/landing/LandingPage.tsx:86`
```diff
- <p>© 2024 Tiz. All rights reserved.</p>
+ <p>© 2026 Tiz. All rights reserved.</p>
```

## 8. 响应式动态适配

### 问题分析

当前代码中存在多处写死的尺寸：

```
写死的尺寸示例:
├── h-[50px] w-[50px]     → 按钮固定尺寸
├── min-h-[60px]          → 输入框固定最小高度
├── min-h-[60vh]          → 固定视口比例
├── min-h-[400px]         → 固定最小高度
└── max-w-[85%]           → 固定最大宽度
```

### 设计原则

1. **移动端优先** - 默认样式针对移动端，用断点扩展到桌面
2. **流式布局** - 使用 flex/grid 让内容自然流动
3. **相对单位** - 使用 Tailwind 的相对尺寸类
4. **断点响应** - 关键尺寸在不同断点有不同值

### 修复策略

```css
/* 错误示例 - 写死尺寸 */
.button { height: 50px; width: 50px; }

/* 正确示例 - 响应式尺寸 */
<button className="h-12 w-12 sm:h-auto sm:w-auto">
  /* 移动端固定 48px (h-12)，桌面端自适应 */
</button>

/* 输入框响应式 */
<textarea className="min-h-14 sm:min-h-16">
  /* 移动端 56px，桌面端 64px */
</textarea>

/* 容器高度响应式 */
<div className="min-h-[50vh] sm:min-h-[60vh]">
  /* 根据视口动态调整 */
</div>
```

### 影响文件

- `src/app/(main)/home/HomePage.tsx`
- `src/app/chat/ChatPage.tsx`
- `src/components/chat/ChatInput.tsx`
- `src/components/common/PageError.tsx`
- `src/components/common/EmptyState.tsx`
- `src/components/common/LoadingState.tsx`
