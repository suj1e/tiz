# UI 优化计划 - Tiz Mobile App

## 概述

本文档列出了需要优化的 UI 问题，按照优先级排序。所有优化都遵循 Tiz 极简设计原则。

---

## 优先级 1：高影响问题

### 1. 统一边框圆角 (Border Radius)
**标准**: 10-12px (普通元素), 20px (芯片/小按钮)

| 文件 | 当前值 | 应改为 | 位置 |
|------|--------|--------|------|
| `widgets/common/app_card.dart` | 16px | 12px | line 46, 90 |
| `features/discover/widgets/translation_tab.dart` | 16px | 12px | line 266 (swap button) |
| `features/discover/widgets/commands_tab.dart` | 20px | 保持 (chip) | line 119 |
| `widgets/common/toggle_switch.dart` | 12px | 保持 | - |

### 2. 统一间距 (Spacing - 4px 网格)
**标准**: 基于 4px 的倍数 (4, 8, 12, 16, 20, 24...)

| 文件 | 问题 | 应改为 |
|------|------|--------|
| `widgets/common/app_card.dart` | 8px margins | 12px |
| `features/discover/widgets/quiz_tab.dart` | 10px padding | 12px |
| `features/settings/settings_page.dart` | 8px margin | 12px |
| `features/quiz/quiz_taking_page.dart` | 10px padding | 12px |

### 3. 添加交互动画
**标准**: 0.15-0.2s 过渡，点击时 0.96-0.98 缩放

| 文件 | 需要添加的动画 |
|------|----------------|
| `features/home/home_page.dart` | 快捷按钮点击缩放反馈 |
| `features/discover/widgets/quiz_tab.dart` | 选项选择动画 |
| `features/discover/widgets/translation_tab.dart` | 结果切换过渡动画 |
| `features/discover/widgets/commands_tab.dart` | 芯片点击反馈动画 |
| `features/discover/widgets/chat_tab.dart` | 发送按钮点击反馈 |

### 4. 移除违反极简原则的设计
| 文件 | 问题 | 修复方案 |
|------|------|----------|
| `widgets/common/app_card.dart` | GlassCard (玻璃态) | 移除或改为纯色 |
| `widgets/common/app_card.dart` | elevation 阴影 | 移除，使用边框 |
| `features/quiz/quiz_taking_page.dart` | withOpacity() | 使用纯色或移除 |

---

## 优先级 2：中等影响问题

### 5. 统一按钮尺寸
**标准**: 发送按钮 40x40px，小操作按钮 32x32px

| 文件 | 当前值 | 应改为 |
|------|--------|--------|
| `features/discover/widgets/commands_tab.dart` | 32x32px | 40x40px (send) |
| `features/discover/widgets/translation_tab.dart` | 24x24px | 32x32px (copy) |

### 6. 统一输入框内边距
**标准**: 14px (横向 14-16px, 纵向 12-14px)

| 文件 | 当前值 | 应改为 |
|------|--------|--------|
| `features/discover/widgets/commands_tab.dart` | 12px | 14px |
| `features/discover/widgets/chat_tab.dart` | 12-14px | 保持 14px |
| `features/auth/login_page.dart` | 14px | 保持 |

### 7. 统一图标尺寸
**标准**: 16px, 20px, 24px

| 文件 | 当前值 | 应改为 |
|------|--------|--------|
| `features/discover/widgets/commands_tab.dart` | 14px circle | 16px |
| `widgets/common/app_card.dart` | 48px (empty) | 56px |
| `features/settings/settings_page.dart` | 36x36px | 40x40px |
| `features/discover/widgets/messages_tab.dart` | 40x40px | 保持 (最新标准) |

### 8. 优化空状态
**标准**: 56px 图标，两行文案（标题+副标题）

| 文件 | 当前值 | 应改为 |
|------|--------|--------|
| `features/discover/widgets/quiz_tab.dart` | 48px | 56px |
| `widgets/common/notification_panel.dart` | 48px | 56px |

---

## 优先级 3：低影响问题

### 9. 移除硬编码颜色
| 文件 | 问题 | 修复方案 |
|------|------|----------|
| `features/settings/settings_page.dart` | 硬编码白色 | 使用 colors.bg |
| `widgets/common/app_card.dart` | 非标准颜色属性 | 使用 ThemeColors |

### 10. 添加页面过渡动画
| 文件 | 需要添加 |
|------|----------|
| `features/splash/splash_page.dart` | Logo 淡入动画 |
| `features/discover/widgets/quiz_tab.dart` | 模式选择过渡 |

---

## 任务分配

### 任务 1: 首页快捷按钮动画
**文件**: `lib/features/home/home_page.dart`
- 添加点击缩放反馈 (0.97 scale)
- 添加 150ms 过渡动画

### 任务 2: Quiz Tab 选项动画
**文件**: `lib/features/discover/widgets/quiz_tab.dart`
- 添加选项点击缩放反馈
- 添加选中状态过渡动画
- 修复 10px → 12px 间距

### 任务 3: Translation Tab 过渡动画
**文件**: `lib/features/discover/widgets/translation_tab.dart`
- 添加结果显示淡入动画
- 修复 swap button 圆角 16px → 12px
- 统一 copy 按钮尺寸 32x32px

### 任务 4: Commands Tab 交互优化
**文件**: `lib/features/discover/widgets/commands_tab.dart`
- 添加芯片点击反馈动画
- 修复发送按钮尺寸 32x32px → 40x40px
- 统一输入框内边距 12px → 14px

### 任务 5: Chat Tab 发送按钮优化
**文件**: `lib/features/discover/widgets/chat_tab.dart`
- 添加发送按钮点击反馈动画
- 确保尺寸一致 40x40px

### 任务 6: App Card 组件重构
**文件**: `lib/widgets/common/app_card.dart`
- 移除 GlassCard (玻璃态效果)
- 移除 elevation 阴影参数
- 统一圆角 16px → 12px
- 统一边距 8px → 12px

### 任务 7: Settings 页面样式统一
**文件**: `lib/features/settings/settings_page.dart`
- 修复间距 8px → 12px
- 移除硬编码颜色
- 统一图标容器尺寸 36px → 40px

### 任务 8: Quiz Taking 页面优化
**文件**: `lib/features/quiz/quiz_taking_page.dart`
- 移除 withOpacity() 颜色
- 修复间距 10px → 12px
- 添加选项选择动画

### 任务 9: 统一空状态图标
**文件**:
- `lib/features/discover/widgets/quiz_tab.dart`
- `lib/widgets/common/notification_panel.dart`

将空状态图标尺寸统一为 56px

### 任务 10: 编译和部署
- 运行 `flutter build web`
- 启动 HTTP 服务器在 42001 端口

---

## 设计标准速查

```dart
// 间距 (4px 网格)
const spacingXS = 4.0;
const spacingS = 8.0;
const spacingM = 12.0;
const spacingL = 16.0;
const spacingXL = 20.0;

// 圆角
const radiusS = 8.0;   // 小元素
const radiusM = 10.0;  // 按钮、输入框
const radiusL = 12.0;  // 卡片
const radiusChip = 20.0; // 芯片/标签

// 图标尺寸
const iconS = 16.0;
const iconM = 20.0;
const iconL = 24.0;

// 动画时长
const animShort = 150; // ms
const animMedium = 200; // ms

// 缩放反馈
const scalePress = 0.97; // 点击时
const scaleHover = 0.98; // 悬停时
```
