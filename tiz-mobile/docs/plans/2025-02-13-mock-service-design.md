# Mock Service 设计文档

> 创建日期：2025-02-13

## 概述

为 tiz-mobile Flutter 应用实现 Mock 数据服务，支持在不启动后端的情况下独立开发和预览应用。

## 需求

| 项目 | 选择 |
|------|------|
| Mock 类型 | 内存 Mock Service |
| 切换方式 | 开发者菜单（隐藏入口） |
| 数据管理 | 代码内定义（Dart 文件） |
| Mock 范围 | 全量功能 |
| 响应模拟 | 即时返回，无延迟 |

## 架构设计

### 整体结构

```
lib/
├── core/
│   ├── config/
│   │   └── mock_config.dart              # Mock 模式状态（ChangeNotifier）
│   │
│   └── di/
│       └── service_locator.dart          # DI 注入
│
└── features/
    ├── auth/
    │   ├── repository/
    │   │   ├── auth_repository.dart      # 抽象接口
    │   │   ├── real_auth_repository.dart # 真实 API
    │   │   └── mock_auth_repository.dart # Mock 实现
    │   └── mock_data/
    │       └── auth_mock_data.dart       # 该 feature 的 Mock 数据
    │
    ├── explore/
    │   ├── repository/
    │   │   ├── explore_repository.dart
    │   │   ├── real_explore_repository.dart
    │   │   └── mock_explore_repository.dart
    │   └── mock_data/
    │       └── explore_mock_data.dart
    │
    ├── chat/
    │   ├── repository/
    │   │   └── ...
    │   └── mock_data/
    │       └── ...
    │
    ├── profile/
    │   ├── repository/
    │   │   └── ...
    │   └── widgets/
    │       └── dev_mode_toggle.dart      # 开发者菜单
    │
    └── home/
        └── ...
```

### 核心组件

#### 1. MockConfig（状态管理）

```dart
// lib/core/config/mock_config.dart

class MockConfig extends ChangeNotifier {
  static final MockConfig _instance = MockConfig._internal();
  factory MockConfig() => _instance;
  MockConfig._internal();

  bool _isMockMode = false;

  bool get isMockMode => _isMockMode;

  void toggle() {
    _isMockMode = !_isMockMode;
    notifyListeners();
  }

  void setMockMode(bool enabled) {
    if (_isMockMode != enabled) {
      _isMockMode = enabled;
      notifyListeners();
    }
  }
}
```

#### 2. DI 注入逻辑

```dart
// lib/core/di/service_locator.dart

final getIt = GetIt.instance;

void setupDependencies({bool mockMode = false}) {
  // Auth
  if (mockMode) {
    getIt.registerSingleton<AuthRepository>(MockAuthRepository());
  } else {
    getIt.registerSingleton<AuthRepository>(RealAuthRepository(
      apiClient: getIt<ApiClient>(),
    ));
  }

  // 其他 Repository 同理...
}
```

#### 3. Repository 接口与实现

**接口定义：**

```dart
// lib/features/auth/repository/auth_repository.dart

abstract class AuthRepository {
  Future<Result<LoginResponse>> login(String email, String password);
  Future<Result<RegisterResponse>> register(String email, String password, String name);
  Future<Result<TokenResponse>> refreshToken(String refreshToken);
  Future<Result<void>> logout();
  Future<Result<User>> getCurrentUser();
}
```

**真实实现：**

```dart
// lib/features/auth/repository/real_auth_repository.dart

class RealAuthRepository implements AuthRepository {
  final ApiClient _apiClient;

  RealAuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<LoginResponse>> login(String email, String password) async {
    final response = await _apiClient.post('/auth/v1/login', data: {
      'email': email,
      'password': password,
    });
    return Result.success(LoginResponse.fromJson(response.data));
  }

  // ... 其他方法
}
```

**Mock 实现：**

```dart
// lib/features/auth/repository/mock_auth_repository.dart

class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<LoginResponse>> login(String email, String password) async {
    if (email == 'test@test.com' && password == 'password') {
      return Result.success(AuthMockData.loginResponse);
    }
    return Result.failure(AuthException.invalidCredentials());
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    return Result.success(AuthMockData.currentUser);
  }

  // ... 其他方法
}
```

#### 4. Mock 数据定义

```dart
// lib/features/auth/mock_data/auth_mock_data.dart

class AuthMockData {
  static final loginResponse = LoginResponse(
    accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
    refreshToken: 'mock_refresh_token',
    expiresIn: 3600,
  );

  static final currentUser = User(
    id: '1',
    email: 'test@test.com',
    name: 'Test User',
    avatar: 'https://i.pravatar.cc/150?img=1',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );
}
```

### 开发者菜单入口

**解锁机制：** Profile 页面连续点击版本号 5 次解锁

```dart
// lib/features/profile/profile_page.dart

class _ProfilePageState extends State<ProfilePage> {
  int _versionTapCount = 0;
  DateTime? _lastTapTime;
  bool _devMenuUnlocked = false;

  void _onVersionTap() {
    final now = DateTime.now();

    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds > 500) {
      _versionTapCount = 0;
    }

    _lastTapTime = now;
    _versionTapCount++;

    if (_versionTapCount >= 5 && !_devMenuUnlocked) {
      setState(() => _devMenuUnlocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开发者模式已解锁')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ... 现有内容

        GestureDetector(
          onTap: _onVersionTap,
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('版本'),
            subtitle: const Text('1.0.0+1'),
          ),
        ),

        if (_devMenuUnlocked) ...[
          const Divider(),
          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text('开发者选项'),
            enabled: false,
          ),
          DevModeToggle(),
        ],
      ],
    );
  }
}
```

## 全量 Mock 数据规划

| Feature | Repository | Mock 数据 |
|---------|------------|-----------|
| **Auth** | `AuthRepository` | 登录/注册响应、Token、当前用户 |
| **Profile** | `UserRepository` | 用户详情、设置、统计数据 |
| **Explore** | `ExploreRepository` | 语言列表、课程、Quiz 题库、翻译结果 |
| **Chat** | `ChatRepository` | 会话列表、消息记录、群组 |

### 各 Feature Mock 数据明细

**Auth (`auth_mock_data.dart`)**
- `loginResponse` - 登录成功响应
- `registerResponse` - 注册成功响应
- `tokenResponse` - Token 刷新响应
- `currentUser` - 当前登录用户

**Profile (`profile_mock_data.dart`)**
- `userProfile` - 用户详细资料
- `userSettings` - 用户设置项
- `activityStats` - 学习/活动统计
- `achievements` - 成就列表

**Explore (`explore_mock_data.dart`)**
- `languages` - 支持的语言列表
- `courses` - 课程列表
- `lessons` - 课时内容
- `quizCategories` - Quiz 分类
- `quizList` - Quiz 列表
- `quizQuestions` - Quiz 题目（含选项）
- `translations` - 翻译结果缓存

**Chat (`chat_mock_data.dart`)**
- `conversations` - 会话列表
- `messages` - 消息记录（按会话）
- `groups` - 群组列表
- `members` - 群成员

## 迁移步骤

### Step 1：搭建基础框架
- 创建 `MockConfig`
- 更新 `service_locator.dart` 支持条件注入

### Step 2：迁移 Auth（先跑通）
- 抽取 `AuthRepository` 接口
- 将现有 `AuthRepository` 重命名为 `RealAuthRepository`
- 创建 `MockAuthRepository` + `AuthMockData`
- 更新 `AuthBloc` 使用接口类型

### Step 3：迁移其他 Feature
- Profile → Explore → Chat（按优先级逐个迁移）
- 每个 Feature 遵循相同模式

### Step 4：开发者菜单
- 在 Profile 页面添加隐藏入口
- 实现 `DevModeToggle`

### Step 5：测试验证
- Mock 模式下启动应用，验证各页面数据正常
- 切换到真实模式，验证 API 调用正常

## 注意事项

1. **现有代码兼容**：逐步迁移，不影响未迁移的功能
2. **Result 类型统一**：Mock 和 Real 返回类型必须一致
3. **错误场景覆盖**：Mock 也要模拟失败情况（网络错误、业务错误）
4. **调试友好**：Mock 模式下控制台打印日志，方便追踪

## 后续扩展

- Mock 数据支持自定义（如测试不同用户角色）
- Mock 场景切换（成功/失败/超时等场景）
