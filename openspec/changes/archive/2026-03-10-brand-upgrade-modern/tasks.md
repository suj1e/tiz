## 1. 基础设施 - 设计 Tokens

- [x] 1.1 更新 `src/shared/index.css` - 添加亮色模式色彩变量 (primary, accent, success, warning, destructive, background, foreground, muted, border)
- [x] 1.2 更新 `src/shared/index.css` - 添加暗色模式色彩变量 (.dark 选择器)
- [x] 1.3 更新 `src/shared/index.css` - 添加字体变量 (--font-sans, --font-display, --font-mono)
- [x] 1.4 更新 `src/shared/index.css` - 添加间距、圆角、阴影、动效 tokens
- [x] 1.5 更新 `index.desktop.html` - 添加 Google Fonts 预连接和字体加载链接
- [x] 1.6 更新 `index.mobile.html` - 添加 Google Fonts 预连接和字体加载链接

## 2. Logo 组件

- [x] 2.1 创建 `src/shared/components/common/Logo.tsx` - 渐变方块 T Logo 组件
- [x] 2.2 更新 `src/desktop/components/Sidebar.tsx` - 使用新 Logo 组件替换旧 Logo
- [x] 2.3 更新 `src/shared/components/layout/Header.tsx` - 使用新 Logo 组件
- [x] 2.4 更新 `src/shared/app/landing/LandingPage.tsx` - 使用新 Logo 组件
- [x] 2.5 更新 `src/shared/app/chat/ChatPage.tsx` - 使用新 Logo 组件

## 3. 聊天页优化

- [x] 3.1 更新 `src/shared/components/chat/ChatMessage.tsx` - 用户消息气泡样式 (primary 背景, 右对齐)
- [x] 3.2 更新 `src/shared/components/chat/ChatMessage.tsx` - AI 消息气泡样式 (muted 背景, 左对齐, AI 头像)
- [x] 3.3 更新 `src/shared/components/chat/ChatMessage.tsx` - 添加消息入场动画 (fade-in + slide-up)
- [x] 3.4 更新 `src/shared/components/chat/TypingIndicator.tsx` - 优化打字指示器样式
- [x] 3.5 更新 `src/shared/app/chat/ChatPage.tsx` - 重新设计空状态 (Logo 发光 + 欢迎语 + 快捷按钮)
- [x] 3.6 更新 `src/shared/app/chat/ChatPage.tsx` - 快捷按钮悬停效果
- [x] 3.7 更新 `src/shared/app/(main)/home/HomePage.tsx` - 同步聊天页样式更新

## 4. Landing Page 优化

- [x] 4.1 更新 `src/shared/app/landing/LandingPage.tsx` - Hero 区域渐变背景/光晕效果
- [x] 4.2 更新 `src/shared/app/landing/LandingPage.tsx` - 标题使用 display 字体
- [x] 4.3 更新 `src/shared/app/landing/LandingPage.tsx` - 功能卡片悬停效果 (上浮 + 阴影)
- [x] 4.4 更新 `src/shared/app/landing/LandingPage.tsx` - 功能图标悬停微旋转效果
- [x] 4.5 更新 `src/shared/app/landing/LandingPage.tsx` - CTA 按钮悬停效果

## 5. 题库页优化

- [x] 5.1 更新 `src/shared/components/library/LibraryCard.tsx` - 卡片悬停效果 (上浮 + 阴影)
- [x] 5.2 更新 `src/shared/components/library/LibraryCard.tsx` - 难度标签颜色 (绿/橙/红)
- [x] 5.3 更新 `src/shared/components/library/LibraryCard.tsx` - 按钮图标和悬停效果
- [x] 5.4 更新 `src/shared/components/library/LibraryFilter.tsx` - 筛选器样式优化
- [x] 5.5 更新 `src/shared/app/(main)/library/LibraryPage.tsx` - 页面标题样式

## 6. 做题页优化

- [x] 6.1 更新 `src/shared/components/question/QuestionCard.tsx` - 题目卡片样式
- [x] 6.2 更新 `src/shared/components/question/ChoiceQuestion.tsx` - 选项悬停效果
- [x] 6.3 更新 `src/shared/components/question/ChoiceQuestion.tsx` - 选项选中状态 (左边框 + 背景色)
- [x] 6.4 更新 `src/shared/components/question/QuestionProgress.tsx` - 进度条渐变色
- [x] 6.5 更新 `src/shared/components/quiz/QuizTimer.tsx` - 计时器样式优化
- [x] 6.6 更新 `src/shared/app/(main)/practice/PracticePage.tsx` - 导航按钮脉动提示
- [x] 6.7 更新 `src/shared/app/(main)/quiz/QuizPage.tsx` - 同步做题页样式

## 7. 导航组件优化

- [x] 7.1 更新 `src/desktop/components/Sidebar.tsx` - 导航项悬停和选中效果
- [x] 7.2 更新 `src/mobile/components/BottomNav.tsx` - 底部导航样式优化
- [x] 7.3 更新 `src/shared/components/layout/Header.tsx` - 头部样式优化

## 8. 通用组件优化

- [x] 8.1 更新 `src/shared/components/ui/button.tsx` - 优化 hover/active 状态 (如果需要)
- [x] 8.2 更新 `src/shared/components/ui/card.tsx` - 优化卡片基础样式 (如果需要)
- [x] 8.3 更新 `src/shared/components/common/EmptyState.tsx` - 空状态组件样式
- [x] 8.4 更新 `src/shared/components/common/LoadingState.tsx` - 加载状态组件样式

## 9. 验证和测试

- [x] 9.1 桌面端开发服务器验证 - `pnpm dev:desktop`
- [x] 9.2 移动端开发服务器验证 - `pnpm dev:mobile`
- [x] 9.3 亮色模式完整检查
- [x] 9.4 暗色模式完整检查
- [x] 9.5 字体加载验证
- [x] 9.6 动效流畅度检查
- [x] 9.7 构建验证 - `pnpm build:all`
