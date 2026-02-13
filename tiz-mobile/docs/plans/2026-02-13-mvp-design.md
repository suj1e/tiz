# Tiz Mobile MVP 设计文档

## 技术栈

| 类别 | 选择 | 说明 |
|------|------|------|
| 框架 | Flutter 3.x | 跨平台 (Android + iOS) |
| UI 组件 | Material 3 + 定制主题 | 基础组件 + 黑白灰主题 |
| 状态管理 | Riverpod | 类型安全、易测试 |
| 网络请求 | Dio + retrofit | 拦截器 + 类型安全 API |
| 路由 | go_router | 声明式路由，支持深链接 |
| 本地存储 | shared_preferences | key-value 偏好存储 |
| 后端对接 | REST + WebSocket | MVP 阶段用 Mock |

---

## 视觉设计

### 主题
- **双主题支持**：暗色 / 亮色
- **切换方式**：跟随系统 或 手动切换

### 配色
- **纯黑白灰**，无强调色
- **极简极客风格**，代码编辑器质感

### 暗色主题
- 背景：`#000000` / `#121212`
- 文字：`#FFFFFF` / `#B0B0B0`
- 边框/分割线：`#333333`

### 亮色主题
- 背景：`#FFFFFF` / `#F5F5F5`
- 文字：`#000000` / `#666666`
- 边框/分割线：`#E0E0E0`

---

## 功能模块

### 底部导航

```
[ 消息 ]   [ 发现 ]   [ 我的 ]
```

---

### 1. 发现页 - 翻译 Tab（核心 MVP）

#### 功能
- 文本输入区域
- AI 自动检测源语言
- 目标语言选择（英语、粤语、川语）
- 翻译结果展示
- 复制 / 分享按钮

#### 交互流程
1. 用户输入文本
2. 系统自动检测源语言（显示检测结果）
3. 用户选择目标语言
4. 点击翻译按钮
5. 显示翻译结果 + 操作按钮

#### Mock 数据
- 延迟 500-1000ms 模拟网络请求
- 返回预设翻译结果

---

### 2. 消息页

#### 功能
- 卡片式消息列表
- 显示：标题 + 摘要 + 时间
- 已读 / 未读状态
- 点击查看详情

#### 消息类型
- AI 提醒
- Webhook 推送

#### Mock 数据
- 预设 3-5 条示例消息
- 点击可标记已读

---

### 3. 我的页

#### 账号（Mock）
- 显示假用户名 / 邮箱
- 登出按钮（仅 UI，无实际功能）

#### 偏好设置
- 主题切换（跟随系统 / 亮色 / 暗色）
- 默认翻译语言

#### Webhook 配置
- URL 列表展示
- 添加 / 编辑 / 删除 URL
- 本地存储，界面完整

#### App 设置
- 清除缓存
- 版本信息

---

## 项目结构

```
lib/
├── main.dart                    # 入口
├── app.dart                     # App 配置
├── core/
│   ├── theme/
│   │   ├── app_theme.dart       # 主题定义
│   │   └── theme_provider.dart  # 主题状态
│   ├── router/
│   │   └── app_router.dart      # 路由配置
│   ├── network/
│   │   ├── dio_client.dart      # Dio 配置
│   │   └── api_interceptor.dart # 拦截器
│   └── storage/
│       └── preferences.dart     # SP 封装
└── features/
    ├── translation/
    │   ├── data/
    │   │   ├── translation_repository.dart
    │   │   └── mock_translation_service.dart
    │   ├── domain/
    │   │   └── translation_model.dart
    │   ├── presentation/
    │   │   ├── translation_page.dart
    │   │   └── translation_controller.dart
    │   └── translation_provider.dart
    ├── message/
    │   ├── data/
    │   │   ├── message_repository.dart
    │   │   └── mock_message_service.dart
    │   ├── domain/
    │   │   └── message_model.dart
    │   ├── presentation/
    │   │   ├── message_page.dart
    │   │   └── message_detail_page.dart
    │   └── message_provider.dart
    └── profile/
        ├── data/
        │   └── webhook_repository.dart
        ├── domain/
        │   └── webhook_model.dart
        ├── presentation/
        │   ├── profile_page.dart
        │   ├── theme_settings_page.dart
        │   └── webhook_settings_page.dart
        └── profile_provider.dart
```

---

## Mock 与真实后端切换

### 架构设计
采用 **Repository 接口 + 依赖注入** 模式：

```dart
// 1. 定义接口
abstract class TranslationRepository {
  Future<TranslationResult> translate(String text, String targetLang);
}

// 2. Mock 实现
class MockTranslationRepository implements TranslationRepository {
  @override
  Future<TranslationResult> translate(...) async {
    await Future.delayed(Duration(milliseconds: 800));
    return TranslationResult(text: "Mock 翻译结果...");
  }
}

// 3. 真实实现（后续添加）
class ApiTranslationRepository implements TranslationRepository {
  final DioClient _client;
  @override
  Future<TranslationResult> translate(...) async {
    return await _client.post('/translate', ...);
  }
}

// 4. 通过 Riverpod Provider 切换
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
  return useMock ? MockTranslationRepository() : ApiTranslationRepository();
});
```

### 切换方式
```bash
# 开发阶段（Mock）
flutter run --dart-define=USE_MOCK=true

# 生产阶段（真实后端）
flutter build --dart-define=USE_MOCK=false
```

### 后续迁移步骤
1. 实现 `ApiXxxRepository` 类
2. 在 `dio_client.dart` 配置真实 baseUrl
3. 切换 `USE_MOCK=false`
4. 删除或保留 Mock 类（可用于测试）

---

## 后端对接预留

### REST API
- 翻译：`POST /api/v1/translate`
- 消息列表：`GET /api/v1/messages`
- Webhook 配置：`CRUD /api/v1/webhooks`

### WebSocket
- 消息推送：`ws://gateway/ws/messages`
- 心跳保活机制

---

## MVP 原则

1. **极简极客** — 纯黑白灰主题
2. **界面完整** — 测验 Tab 占位保留
3. **工具感强** — 翻译快速访问
4. **后续可扩展** — 架构支持真实后端接入
