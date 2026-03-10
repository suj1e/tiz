## Context

Tiz Web 是一个 AI 驱动的知识练习平台，采用 React 19 + Tailwind CSS 4.x + shadcn/ui 技术栈。项目已将桌面端和移动端分离构建，共享组件位于 `src/shared/`。

当前状态：
- 色彩系统使用纯黑白灰 (oklch 色彩但 chroma = 0)
- 使用系统默认字体
- 基础的 shadcn/ui 组件样式
- 几乎没有动效
- 有暗色模式支持但配色单调

## Goals / Non-Goals

**Goals:**
- 建立现代简约的品牌视觉系统
- 实现完整的亮/暗双模式配色
- 优化核心页面（聊天、Landing、题库/做题）的视觉体验
- 添加微妙的动效提升交互体验
- 保持代码简洁，避免过度工程

**Non-Goals:**
- 不改变组件逻辑和功能行为
- 不引入新的动画库（使用 CSS 动画）
- 不修改后端 API
- 不改变页面结构和路由
- 不引入付费字体

## Decisions

### 1. 色彩系统：使用 oklch 色彩空间

**选择**: 继续使用 oklch，但引入有色彩的设计

**理由**:
- oklch 是感知均匀的色彩空间，便于创建和谐的配色
- 当前项目已使用 oklch，保持一致性
- 支持亮/暗模式时更容易调整明度

**配色方案**:
```
亮色模式:
- Primary: oklch(0.40 0.16 265) - 深靛蓝
- Accent: oklch(0.78 0.14 70) - 琥珀金
- Background: oklch(0.99 0.005 70) - 温暖白

暗色模式:
- Primary: oklch(0.65 0.16 265) - 亮靛蓝
- Accent: oklch(0.82 0.14 70) - 亮琥珀
- Background: oklch(0.15 0.01 265) - 冷深蓝
```

### 2. 字体：Google Fonts

**选择**: Noto Sans SC + Sora

**理由**:
- Noto Sans SC: 覆盖中日韩字符，开源免费，显示清晰
- Sora: 现代几何感，与思源黑体搭配和谐
- Google Fonts CDN 加载，无需本地托管

**备选方案**:
- 霞鹜文楷 + JetBrains Mono (手写感更强，但加载较慢)
- Noto Serif SC + Space Grotesk (更学术，但衬体不适合 UI)

### 3. Logo：渐变方块 T

**选择**: 圆角方块背景 + 白色 T 字

**实现**:
```tsx
<div className="w-8 h-8 rounded-lg flex items-center justify-center
                bg-gradient-to-br from-primary to-primary/80
                shadow-sm hover:shadow-glow transition-all">
  <span className="text-white font-bold text-sm font-display">T</span>
</div>
```

**理由**:
- 现代感强，有辨识度
- 适合作为 App 图标
- 实现简单，纯 CSS

### 4. 动效：CSS only

**选择**: 纯 CSS 动画，不引入 Framer Motion

**理由**:
- 项目动效需求简单（微妙点缀）
- CSS 动画性能更好
- 减少依赖

**动效规范**:
- 微交互: 150ms ease-out
- 状态变化: 200-300ms ease-out
- 消息入场: opacity + translateY
- 卡片悬停: translateY(-4px) + box-shadow

### 5. 组件样式策略

**选择**: 通过 Tailwind utility classes 实现，不创建新组件

**理由**:
- shadcn/ui 已有良好的组件基础
- 通过 classes 覆盖样式更灵活
- 便于后续维护

## Risks / Trade-offs

### 字体加载延迟
- **风险**: Google Fonts 加载可能导致 FOIT (Flash of Invisible Text)
- **缓解**: 使用 `font-display: swap`，并预加载关键字体

### 暗色模式一致性
- **风险**: 部分组件可能遗漏暗色模式样式
- **缓解**: 在 index.css 中统一定义 CSS 变量，组件通过变量引用

### 渐变在旧浏览器兼容性
- **风险**: oklch 在旧浏览器不支持
- **缓解**: 项目已使用 oklch，目标浏览器已支持

### 动效过度
- **风险**: 动效可能影响性能或分散注意力
- **缓解**: 保持"微妙点缀"原则，时长控制在 300ms 以内

## Migration Plan

### 阶段 1: 基础设施
1. 更新 index.css - 色彩变量和 tokens
2. 添加字体加载到 HTML
3. 创建 Logo 组件

### 阶段 2: 核心组件
1. 更新 Button 样式
2. 更新 Card 样式
3. 更新 ChatMessage 样式

### 阶段 3: 页面优化
1. 聊天页 - 空状态、气泡、动效
2. Landing Page - Hero、功能卡片
3. 题库页 - 卡片、筛选器
4. 做题页 - 选项、进度条

### 阶段 4: 导航组件
1. Sidebar (桌面端)
2. BottomNav (移动端)
3. Header

### 回滚策略
- 所有改动在 CSS 和组件样式层面
- 可通过 Git revert 回滚
- 无数据迁移，无破坏性变更
