## Why

Tiz Web 当前使用纯黑白灰配色，缺乏品牌识别度和视觉吸引力。作为一款 AI 驱动的学习平台，需要建立独特的品牌形象，提升用户的学习体验和情感连接。同时，桌面端和移动端已分离构建，是进行深度 UI 优化的好时机。

## What Changes

### 色彩系统
- 引入品牌主色：深靛蓝 (oklch(0.40 0.16 265))
- 引入强调色：琥珀金 (oklch(0.78 0.14 70))
- 建立完整的亮色/暗色模式配色方案
- 定义功能色（成功/警告/错误）

### 字体系统
- 中文：Noto Sans SC (思源黑体)
- 英文/数字：Sora
- 从 Google Fonts 加载

### Logo
- 新的渐变方块 T Logo
- 圆角方块背景 + 白色 T 字

### 组件样式
- 卡片：悬停上浮效果 + 阴影扩散
- 按钮：优化 hover/active 状态
- 消息气泡：区分用户/AI 样式
- 选项：选中时左边框高亮

### 动效
- 消息入场：opacity + translateY 动画
- 卡片悬停：translateY(-4px) + 阴影
- 打字光标：闪烁动画
- 过渡时长：150-300ms

### 页面优化
- 聊天页：空状态设计、气泡样式、打字效果
- Landing Page：Hero 渐变背景、功能卡片
- 题库/做题页：卡片效果、选项样式、进度条渐变

## Capabilities

### New Capabilities

- `design-tokens`: 设计系统的基础变量（色彩、字体、间距、圆角、阴影、动效）
- `brand-identity`: 品牌视觉标识（Logo、配色方案、字体配置）

### Modified Capabilities

- `ui-components`: UI 组件的视觉样式升级（按钮、卡片、输入框、消息气泡等）

## Impact

### 修改文件
- `src/shared/index.css` - 色彩变量、设计 tokens
- `index.desktop.html` / `index.mobile.html` - 字体加载
- `src/shared/components/chat/ChatMessage.tsx` - 气泡样式
- `src/shared/components/chat/ChatPage.tsx` - 空状态
- `src/shared/components/library/LibraryCard.tsx` - 卡片效果
- `src/shared/components/question/ChoiceQuestion.tsx` - 选项样式
- `src/shared/components/question/QuestionProgress.tsx` - 进度条
- `src/shared/app/landing/LandingPage.tsx` - Hero + 功能卡片
- `src/desktop/components/Sidebar.tsx` - Logo 组件
- `src/mobile/components/BottomNav.tsx` - 底部导航样式

### 兼容性
- 无破坏性变更
- 纯 CSS 和样式修改，不影响功能逻辑
- 暗色模式保持向后兼容
