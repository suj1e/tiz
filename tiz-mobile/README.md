# Tiz

<div align="center">

![Tiz Logo](assets/logo.png)

**AI驱动的语言学习和翻译助手**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## 项目简介

Tiz 是一款基于 Flutter 开发的跨平台移动应用，采用**极简设计**原则。应用通过 AI 技术为用户提供智能翻译、对话助手和知识测验等功能。

### 核心功能

- **✨ AI 智能翻译** - 支持多种语言互译，AI 增强模式提升翻译准确性
- **💬 AI 对话助手** - 智能问答和学习支持，支持深度思考模式
- **🎯 知识测验** - 多种测验模式：选择题、对话、AI 语音通话
- **📚 智能推荐** - 根据使用习惯推荐个性化学习内容
- **🤖 指令自动化** - 自然语言指令执行，实时进度跟踪
- **🎨 极简主题** - 浅色/深色双主题，纯平设计，无阴影装饰

---

## 运行条件

### 环境要求

- **Flutter SDK**: 3.0.0 或更高版本
- **Dart SDK**: 3.0.0 或更高版本
- **开发平台**:
  - macOS 12+ (iOS 开发需要 Xcode 14+)
  - Windows 10+ / Linux (Android 开发需要 Android Studio)
- **目标平台**:
  - iOS 15+
  - Android 8.0+ (API Level 26+)

### 依赖包

主要依赖（详见 `pubspec.yaml`）：

```yaml
# 状态管理
provider: ^6.1.1

# 存储
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0
hive: ^2.2.3
hive_flutter: ^1.1.0
sqflite: ^2.3.0

# 网络
dio: ^5.4.0

# 语音识别
speech_to_text: ^6.6.0

# 工具库
intl: ^0.18.1
uuid: ^4.3.1
flutter_svg: ^2.0.9
```

---

## 运行说明

### 1. 克隆项目

```bash
git clone codeup.aliyun.com:638a07cb09a6ccfdd6a1f934/tiz/tiz-mobile.git
cd tiz-mobile
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行应用

```bash
# iOS 模拟器
flutter run -d ios

# Android 模拟器
flutter run -d android

# 或选择可用设备
flutter run
```

### 4. 构建发布版本

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

---

## 技术架构

### 项目结构

```
lib/
├── main.dart                      # 应用入口
├── core/                          # 核心模块
│   ├── constants.dart             # 应用常量
│   ├── routes.dart                # 路由配置
│   └── services/
│       └── speech_service.dart    # 语音识别服务
├── theme/                         # 主题系统
│   ├── app_colors.dart            # 色彩系统
│   ├── app_text_styles.dart       # 文字样式
│   ├── app_decorations.dart       # 装饰样式
│   ├── app_theme.dart             # 主题定义
│   └── theme_provider.dart        # 主题状态管理
├── ai/                            # AI 模块
│   ├── models/
│   │   ├── ai_model.dart          # AI 模型枚举
│   │   ├── ai_config.dart         # AI 配置
│   │   └── chat_message.dart      # 聊天消息
│   ├── providers/
│   │   └── ai_config_provider.dart # AI 配置状态
│   ├── services/
│   │   ├── ai_service.dart        # AI 服务接口
│   │   ├── openai_service.dart    # OpenAI 实现
│   │   ├── claude_service.dart    # Claude 实现
│   │   └── ai_service_factory.dart # 服务工厂
│   └── widgets/
│       └── chat_bubble.dart       # 聊天气泡
├── widgets/                       # 通用组件
│   ├── common/
│   │   ├── app_card.dart          # 卡片组件
│   │   ├── notification_panel.dart # 通知面板
│   │   └── toggle_switch.dart     # 开关组件
│   └── navigation/
│       └── main_navigation.dart   # 底部导航
├── features/                      # 功能页面
│   ├── home/                      # 首页
│   ├── discover/                  # 发现页（Tab切换：翻译/测验/对话/指令）
│   └── profile/                   # 个人页
└── models/
    └── notification.dart          # 通知模型
```

### 状态管理

使用 **Provider** 进行状态管理：

- `ThemeProvider` - 主题状态管理
- `AiConfigProvider` - AI 配置状态管理
- `NotificationProvider` - 通知状态管理

### 主题系统

支持 2 种极简主题，可通过个人页面切换：

| 主题 | 风格 | 主色调 |
|------|------|--------|
| 浅色 | 纯净极简 | `#111827` |
| 深色 | 纯黑极简 | `#fafafa` |

**设计特点：**
- 纯平设计，无阴影
- 统一 10-12px 圆角
- 1px 边框
- 快速 0.15-0.2s 过渡动画
- SVG 图标（无 emoji）

### AI 服务架构

```
AiService (接口)
    ├── OpenAiService
    ├── ClaudeService
    └── MockAiService (测试用)
```

支持的 AI 模型：
- GPT-4 / GPT-3.5 Turbo
- Claude 3 Opus
- Gemini Pro
- Local Model (离线)
- Custom API (自定义)

---

## 功能页面

### 🏠 首页

- AI 智能推荐卡片
- 快捷功能入口
- 学习动态信息流
- 通知面板入口

### 🔍 发现页

顶部 Tab 切换设计，包含四个功能模块：

**翻译工具**
- 多语言选择（中文/英语/日语）
- AI 增强翻译
- 简洁输入界面

**知识测验**
- 多语言分类（英语/日语/德语）
- 多种测验模式：选择题、对话、AI 语音通话
- 实时反馈

**AI 对话助手**
- 实时对话
- 深度思考模式
- 聊天气泡界面

**指令自动化**
- 自然语言指令输入
- 智能指令解析与执行
- 实时进度跟踪
- 执行历史记录

### 👤 个人页

- 用户信息展示
- AI 模型选择
- AI 功能开关
- 应用设置
- 主题选择器

---

## 测试说明

```bash
# 运行所有测试
flutter test

# 运行单元测试
flutter test test/unit/

# 运行 Widget 测试
flutter test test/widget/

# 生成测试覆盖率报告
flutter test --coverage
```

---

## 开发指南

### 代码规范

项目遵循 Flutter 官方代码规范，配置见 `analysis_options.yaml`。

### 提交规范

使用 Conventional Commits 规范：

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建/工具链相关
```

### 分支策略

- `master` - 主分支，保持稳定可发布状态
- `develop` - 开发分支
- `feature/*` - 功能分支
- `bugfix/*` - 修复分支

---

## HTML 原型

项目包含一个功能完整的 HTML 原型，用于设计预览和交互测试：

```bash
# 启动 HTTP 服务器
python3 -m http.server 42000 --directory /Users/sujie/workspace/dev/apps/tiz/tiz-mobile

# 访问 http://localhost:42000/prototype.html
```

**原型特性：**
- 完整的三页导航（首页/发现/我的）
- 极简设计，纯 SVG 图标
- 发现页 Tab 切换（翻译/测验/对话/指令）
- 主题切换（浅色/深色）
- 通知面板交互
- AI 语音通话界面
- 指令自动化执行界面

---

## 协作者

<!-- 将协作者信息记录在这里 -->

---

## 许可证

MIT License

---

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。
