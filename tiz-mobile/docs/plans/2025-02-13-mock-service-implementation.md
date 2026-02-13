# Mock Service Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 为 tiz-mobile 实现 Mock 数据服务，支持运行时动态切换，无需后端即可预览应用。

**Architecture:** Repository 接口 + Real/Mock 双实现，通过 `MockConfig` + `ServiceLocator` 条件注入。开发者菜单隐藏在 Profile 页面版本号后。

**Tech Stack:** Flutter, Provider, flutter_bloc, existing Repository pattern

---

## Task 1: 创建 MockConfig 核心状态

**Files:**
- Create: `lib/core/config/mock_config.dart`

**Step 1: 创建 MockConfig 类**

```dart
// lib/core/config/mock_config.dart

import 'package:flutter/foundation.dart';

/// Mock 模式配置
/// 用于控制应用是否使用 Mock 数据
class MockConfig extends ChangeNotifier {
  static final MockConfig _instance = MockConfig._internal();
  factory MockConfig() => _instance;
  MockConfig._internal();

  bool _isMockMode = false;

  /// 当前是否为 Mock 模式
  bool get isMockMode => _isMockMode;

  /// 切换 Mock 模式
  void toggle() {
    _isMockMode = !_isMockMode;
    debugPrint('[MockConfig] Mock mode: ${_isMockMode ? "ON" : "OFF"}');
    notifyListeners();
  }

  /// 设置 Mock 模式
  void setMockMode(bool enabled) {
    if (_isMockMode != enabled) {
      _isMockMode = enabled;
      debugPrint('[MockConfig] Mock mode: ${_isMockMode ? "ON" : "OFF"}');
      notifyListeners();
    }
  }
}
```

**Step 2: 验证文件创建**

Run: `head -20 lib/core/config/mock_config.dart`
Expected: 文件内容显示正确

**Step 3: Commit**

```bash
git add lib/core/config/mock_config.dart
git commit -m "feat: add MockConfig for mock mode state management"
```

---

## Task 2: 重构 AuthRepository - 分离接口与实现

**Files:**
- Modify: `lib/features/auth/repository/auth_repository.dart` (只保留接口和异常类)
- Create: `lib/features/auth/repository/real_auth_repository.dart`
- Modify: `lib/core/services/service_locator.dart`

**Step 1: 提取接口到单独位置（保留在原文件顶部）**

修改 `lib/features/auth/repository/auth_repository.dart`，只保留抽象类和异常类：

```dart
// lib/features/auth/repository/auth_repository.dart

import '../models/auth_models.dart';

/// Repository for authentication operations
abstract class AuthRepository {
  Future<bool> isAuthenticated();
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
  });
  Future<void> logout();
  Future<bool> refreshToken();
}

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, [this.statusCode]);

  @override
  String toString() => 'AuthException: $message';
}
```

**Step 2: 创建 RealAuthRepository**

```dart
// lib/features/auth/repository/real_auth_repository.dart

import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/storage_service.dart';
import 'auth_repository.dart';

/// Real implementation of AuthRepository using API
class RealAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  RealAuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  @override
  Future<bool> isAuthenticated() async {
    return await _storageService.isAuthenticated();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        await _storageService.saveAccessToken(authResponse.accessToken);
        await _storageService.saveRefreshToken(authResponse.refreshToken);
        await _storageService.saveUserData(authResponse.user.toJson());

        return authResponse.user;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Login failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Invalid email or password', 401);
      } else if (e.response?.statusCode == 429) {
        throw const AuthException('Too many login attempts. Try again later.', 429);
      }
      throw AuthException(
        e.response?.data['message'] ?? 'Login failed',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          if (fullName != null) 'fullName': fullName,
        },
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        await _storageService.saveAccessToken(authResponse.accessToken);
        await _storageService.saveRefreshToken(authResponse.refreshToken);
        await _storageService.saveUserData(authResponse.user.toJson());

        return authResponse.user;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Registration failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const AuthException('Email or username already exists', 409);
      }
      throw AuthException(
        e.response?.data['message'] ?? 'Registration failed',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.clearAuthData();
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (accessToken != null) {
          await _storageService.saveAccessToken(accessToken);
          if (newRefreshToken != null) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
```

**Step 3: 更新 ServiceLocator 导入**

修改 `lib/core/services/service_locator.dart` 第 13 行的导入：

```dart
// 将
import '../../features/auth/repository/auth_repository.dart';
// 改为
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository/real_auth_repository.dart';
import '../../core/config/mock_config.dart';
```

修改第 39 行的实例化：

```dart
// 将
    _authRepository = AuthRepositoryImpl(
      apiClient: _apiClient,
      storageService: _storageService,
    );
// 改为
    _authRepository = RealAuthRepository(
      apiClient: _apiClient,
      storageService: _storageService,
    );
```

**Step 4: 验证编译通过**

Run: `flutter analyze lib/features/auth/repository/ lib/core/services/service_locator.dart`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/auth/repository/auth_repository.dart
git add lib/features/auth/repository/real_auth_repository.dart
git add lib/core/services/service_locator.dart
git commit -m "refactor: separate AuthRepository interface from implementation"
```

---

## Task 3: 创建 Auth Mock 数据

**Files:**
- Create: `lib/features/auth/mock_data/auth_mock_data.dart`

**Step 1: 创建 Mock 数据文件**

```dart
// lib/features/auth/mock_data/auth_mock_data.dart

import '../models/auth_models.dart';

/// Mock 数据定义
class AuthMockData {
  AuthMockData._();

  /// 测试用户凭据
  static const String testEmail = 'test@test.com';
  static const String testPassword = 'password123';

  /// Mock 登录响应
  static AuthResponse get loginResponse => AuthResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: currentUser,
      );

  /// Mock 注册响应
  static AuthResponse registerResponse({
    required String email,
    required String username,
    String? fullName,
  }) =>
      AuthResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: User(
          id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          username: username,
          fullName: fullName,
          createdAt: DateTime.now(),
        ),
      );

  /// Mock 当前用户
  static final User currentUser = User(
    id: 'mock_user_001',
    email: 'test@test.com',
    username: 'testuser',
    fullName: 'Test User',
    avatar: 'https://i.pravatar.cc/150?img=1',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  /// Mock Token 刷新响应
  static Map<String, dynamic> get tokenRefreshResponse => {
        'accessToken': 'mock_new_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_new_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      };
}
```

**Step 2: 验证文件创建**

Run: `head -30 lib/features/auth/mock_data/auth_mock_data.dart`
Expected: 文件内容显示正确

**Step 3: Commit**

```bash
git add lib/features/auth/mock_data/auth_mock_data.dart
git commit -m "feat: add AuthMockData for mock authentication data"
```

---

## Task 4: 创建 MockAuthRepository

**Files:**
- Create: `lib/features/auth/repository/mock_auth_repository.dart`

**Step 1: 创建 Mock 实现**

```dart
// lib/features/auth/repository/mock_auth_repository.dart

import 'package:flutter/foundation.dart';

import '../models/auth_models.dart';
import '../mock_data/auth_mock_data.dart';
import 'auth_repository.dart';

/// Mock implementation of AuthRepository for development
class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<bool> isAuthenticated() async {
    debugPrint('[MockAuthRepository] isAuthenticated: ${_currentUser != null}');
    return _currentUser != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    debugPrint('[MockAuthRepository] getCurrentUser');
    return _currentUser;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[MockAuthRepository] login: $email');

    // 模拟验证
    if (email == AuthMockData.testEmail && password == AuthMockData.testPassword) {
      _currentUser = AuthMockData.currentUser;
      return _currentUser!;
    }

    throw const AuthException('Invalid email or password', 401);
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    debugPrint('[MockAuthRepository] register: $email / $username');

    // 模拟邮箱已存在
    if (email == AuthMockData.testEmail) {
      throw const AuthException('Email already exists', 409);
    }

    _currentUser = User(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      username: username,
      fullName: fullName,
      createdAt: DateTime.now(),
    );

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    debugPrint('[MockAuthRepository] logout');
    _currentUser = null;
  }

  @override
  Future<bool> refreshToken() async {
    debugPrint('[MockAuthRepository] refreshToken');
    return _currentUser != null;
  }
}
```

**Step 2: 验证编译通过**

Run: `flutter analyze lib/features/auth/repository/mock_auth_repository.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/auth/repository/mock_auth_repository.dart
git commit -m "feat: add MockAuthRepository for mock authentication"
```

---

## Task 5: 更新 ServiceLocator 支持 Mock 模式

**Files:**
- Modify: `lib/core/services/service_locator.dart`

**Step 1: 添加 Mock 导入和条件注入**

完整更新文件：

```dart
// lib/core/services/service_locator.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/single_child_widget.dart';

import '../api/api_client.dart';
import '../storage/storage_service.dart';
import '../config/mock_config.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository/real_auth_repository.dart';
import '../../features/auth/repository/mock_auth_repository.dart';

class ServiceLocator {
  static const String _baseUrl = 'http://localhost:40004/api/v1';

  static late SharedPreferences _sharedPrefs;
  static late StorageService _storageService;
  static late ApiClient _apiClient;
  static late MockConfig _mockConfig;
  static late AuthRepository _authRepository;
  static late AuthBloc _authBloc;

  static Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    _storageService = StorageServiceImpl(
      secureStorage: const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ),
      sharedPrefs: _sharedPrefs,
    );

    _apiClient = ApiClient(
      dio: _createDio(),
    );

    _mockConfig = MockConfig();

    // 根据 Mock 模式注入不同实现
    _authRepository = _createAuthRepository();

    _authBloc = AuthBloc(authRepository: _authRepository);
  }

  /// 创建 AuthRepository 实现
  static AuthRepository _createAuthRepository() {
    if (_mockConfig.isMockMode) {
      debugPrint('[ServiceLocator] Using MockAuthRepository');
      return MockAuthRepository();
    } else {
      debugPrint('[ServiceLocator] Using RealAuthRepository');
      return RealAuthRepository(
        apiClient: _apiClient,
        storageService: _storageService,
      );
    }
  }

  /// 重新初始化 Repository（切换 Mock 模式后调用）
  static Future<void> reinitializeRepositories() async {
    _authRepository = _createAuthRepository();
    // 重新创建 BLoC
    _authBloc = AuthBloc(authRepository: _authRepository);
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }

  static List<SingleChildWidget> get providers => [
    Provider.value(value: _sharedPrefs),
    Provider.value(value: _storageService),
    Provider.value(value: _apiClient),
    Provider.value(value: _mockConfig),
    Provider.value(value: _authRepository),
    BlocProvider<AuthBloc>.value(value: _authBloc),
  ];

  static StorageService get storage => _storageService;
  static ApiClient get api => _apiClient;
  static MockConfig get mockConfig => _mockConfig;
  static AuthBloc get authBloc => _authBloc;
}
```

**Step 2: 验证编译通过**

Run: `flutter analyze lib/core/services/service_locator.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/services/service_locator.dart
git commit -m "feat: integrate MockConfig into ServiceLocator"
```

---

## Task 6: 创建开发者菜单组件

**Files:**
- Create: `lib/features/profile/widgets/dev_mode_toggle.dart`

**Step 1: 创建 DevModeToggle 组件**

```dart
// lib/features/profile/widgets/dev_mode_toggle.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/mock_config.dart';
import '../../../core/services/service_locator.dart';

/// 开发者模式切换组件
class DevModeToggle extends StatelessWidget {
  const DevModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockConfig>(
      builder: (context, mockConfig, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.science_outlined),
              title: const Text('Mock 模式'),
              subtitle: Text(
                mockConfig.isMockMode
                    ? '使用本地 Mock 数据'
                    : '使用真实 API',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: mockConfig.isMockMode,
              onChanged: (value) => _showConfirmDialog(context, mockConfig),
            ),
            if (mockConfig.isMockMode)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Text(
                  'Mock 登录: ${_getMockCredentials()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getMockCredentials() {
    return 'test@test.com / password123';
  }

  void _showConfirmDialog(BuildContext context, MockConfig mockConfig) {
    final newValue = !mockConfig.isMockMode;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(newValue ? '开启 Mock 模式？' : '关闭 Mock 模式？'),
        content: Text(
          newValue
              ? '将使用本地 Mock 数据，无需后端服务。需要重启应用以完全生效。'
              : '将切换到真实 API 请求。需要重启应用以完全生效。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              mockConfig.setMockMode(newValue);
              Navigator.pop(dialogContext);

              // 重新初始化 Repository
              await ServiceLocator.reinitializeRepositories();

              // 显示提示
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock 模式已切换，请重启应用'),
                    action: SnackBarAction(
                      label: '知道了',
                      onPressed: null,
                    ),
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: 验证编译通过**

Run: `flutter analyze lib/features/profile/widgets/dev_mode_toggle.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/profile/widgets/dev_mode_toggle.dart
git commit -m "feat: add DevModeToggle widget for developer menu"
```

---

## Task 7: 集成开发者菜单到 Profile 页面

**Files:**
- Modify: `lib/features/profile/profile_page.dart`

**Step 1: 添加隐藏入口和开发者菜单**

修改 `ProfilePage` 为 `StatefulWidget` 并添加版本号点击解锁：

```dart
// lib/features/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../routes/app_routes.dart';
import 'widgets/dev_mode_toggle.dart';

/// Profile page
/// Shows user profile, settings, and options
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _versionTapCount = 0;
  DateTime? _lastTapTime;
  bool _devMenuUnlocked = false;

  void _onVersionTap() {
    final now = DateTime.now();

    // 500ms 内连续点击有效
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds > 500) {
      _versionTapCount = 0;
    }

    _lastTapTime = now;
    _versionTapCount++;

    if (_versionTapCount >= 5 && !_devMenuUnlocked) {
      setState(() => _devMenuUnlocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开发者模式已解锁')),
      );
      _versionTapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Profile'),
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  context.push(AppRoutes.settings);
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Header
                  _ProfileHeader(
                    userName: authState is Authenticated
                        ? (authState.email.split('@')[0])
                        : 'Guest',
                    email: authState is Authenticated ? authState.email : '',
                  ),
                  const SizedBox(height: 24),

                  // Stats Section
                  const _StatsSection(),
                  const SizedBox(height: 24),

                  // Menu Options
                  const _MenuSection(),
                  const SizedBox(height: 24),

                  // Developer Menu (if unlocked)
                  if (_devMenuUnlocked) ...[
                    _DevMenuSection(),
                    const SizedBox(height: 24),
                  ],

                  // Version Info (hidden entry for dev menu)
                  GestureDetector(
                    onTap: _onVersionTap,
                    child: Text(
                      'Version 1.0.0+1',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  if (authState is Authenticated)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              dialogContext.pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

/// Developer Menu Section
class _DevMenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.developer_mode,
              color: Colors.orange,
            ),
            title: const Text(
              'Developer Options',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            enabled: false,
          ),
          const Divider(height: 1),
          const DevModeToggle(),
        ],
      ),
    );
  }
}

/// Profile Header Widget (unchanged)
class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String email;

  const _ProfileHeader({
    required this.userName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                userName[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats Section Widget (unchanged)
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              value: '12',
              label: 'Days Streak',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            _StatItem(
              value: '48',
              label: 'Lessons',
              icon: Icons.school,
              color: Colors.blue,
            ),
            _StatItem(
              value: '850',
              label: 'XP Points',
              icon: Icons.stars,
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}

/// Menu Section Widget (unchanged)
class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.book_outlined,
            title: 'My Courses',
            trailing: '3 Active',
            onTap: () {},
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            trailing: '12 Earned',
            onTap: () {},
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.history,
            title: 'Activity History',
            onTap: () {},
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Menu Item Widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: 验证编译通过**

Run: `flutter analyze lib/features/profile/profile_page.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/profile/profile_page.dart
git commit -m "feat: integrate developer menu into Profile page"
```

---

## Task 8: 验证 Mock 模式工作

**Step 1: 运行 Flutter 应用**

Run: `flutter run -d chrome --web-port=42001`

Expected: 应用启动成功

**Step 2: 测试开发者菜单解锁**

1. 导航到 Profile 页面
2. 连续点击版本号 "Version 1.0.0+1" 5 次
3. 应该看到 "开发者模式已解锁" 提示
4. 应该看到 Developer Options 卡片

**Step 3: 测试 Mock 模式切换**

1. 打开 Mock 模式开关
2. 确认对话框后，应该看到 "Mock 模式已切换" 提示
3. 重启应用
4. 使用 test@test.com / password123 登录
5. 应该登录成功

**Step 4: Commit 验证通过**

```bash
git add -A
git commit -m "test: verify mock mode works correctly"
```

---

## Task 9: 创建 Explore Mock 数据和 Repository

**Files:**
- Create: `lib/features/explore/repository/explore_repository.dart`
- Create: `lib/features/explore/repository/real_explore_repository.dart`
- Create: `lib/features/explore/repository/mock_explore_repository.dart`
- Create: `lib/features/explore/mock_data/explore_mock_data.dart`

**Step 1: 创建 ExploreRepository 接口**

```dart
// lib/features/explore/repository/explore_repository.dart

/// Explore 页面数据仓库
abstract class ExploreRepository {
  /// 获取学习进度列表
  Future<List<LearningProgress>> getLearningProgress();

  /// 获取热门 Quiz 列表
  Future<List<QuizItem>> getPopularQuizzes();

  /// 获取支持的语言列表
  Future<List<Language>> getLanguages();
}

/// 学习进度模型
class LearningProgress {
  final String language;
  final String level;
  final double progress;
  final int lessonsLeft;

  const LearningProgress({
    required this.language,
    required this.level,
    required this.progress,
    required this.lessonsLeft,
  });
}

/// Quiz 项目模型
class QuizItem {
  final String id;
  final String title;
  final int questions;
  final String difficulty;
  final String color;

  const QuizItem({
    required this.id,
    required this.title,
    required this.questions,
    required this.difficulty,
    required this.color,
  });
}

/// 语言模型
class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}
```

**Step 2: 创建 Mock 数据**

```dart
// lib/features/explore/mock_data/explore_mock_data.dart

import '../repository/explore_repository.dart';

class ExploreMockData {
  ExploreMockData._();

  static final List<LearningProgress> learningProgress = [
    const LearningProgress(
      language: 'Spanish',
      level: 'Intermediate',
      progress: 0.65,
      lessonsLeft: 12,
    ),
    const LearningProgress(
      language: 'French',
      level: 'Beginner',
      progress: 0.30,
      lessonsLeft: 28,
    ),
    const LearningProgress(
      language: 'German',
      level: 'Advanced',
      progress: 0.85,
      lessonsLeft: 5,
    ),
  ];

  static final List<QuizItem> popularQuizzes = [
    const QuizItem(
      id: 'quiz_001',
      title: 'Spanish Vocabulary',
      questions: 20,
      difficulty: 'Easy',
      color: 'orange',
    ),
    const QuizItem(
      id: 'quiz_002',
      title: 'French Grammar',
      questions: 15,
      difficulty: 'Medium',
      color: 'blue',
    ),
    const QuizItem(
      id: 'quiz_003',
      title: 'German Basics',
      questions: 25,
      difficulty: 'Hard',
      color: 'red',
    ),
    const QuizItem(
      id: 'quiz_004',
      title: 'Italian Phrases',
      questions: 18,
      difficulty: 'Easy',
      color: 'green',
    ),
  ];

  static final List<Language> languages = [
    const Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    const Language(code: 'fr', name: 'French', flag: '🇫🇷'),
    const Language(code: 'de', name: 'German', flag: '🇩🇪'),
    const Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
    const Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    const Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    const Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    const Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
  ];
}
```

**Step 3: 创建 RealExploreRepository（占位）**

```dart
// lib/features/explore/repository/real_explore_repository.dart

import 'package:flutter/foundation.dart';

import 'explore_repository.dart';

/// Real implementation of ExploreRepository using API
class RealExploreRepository implements ExploreRepository {
  @override
  Future<List<LearningProgress>> getLearningProgress() async {
    debugPrint('[RealExploreRepository] getLearningProgress - not implemented');
    // TODO: Implement API call
    return [];
  }

  @override
  Future<List<QuizItem>> getPopularQuizzes() async {
    debugPrint('[RealExploreRepository] getPopularQuizzes - not implemented');
    // TODO: Implement API call
    return [];
  }

  @override
  Future<List<Language>> getLanguages() async {
    debugPrint('[RealExploreRepository] getLanguages - not implemented');
    // TODO: Implement API call
    return [];
  }
}
```

**Step 4: 创建 MockExploreRepository**

```dart
// lib/features/explore/repository/mock_explore_repository.dart

import 'package:flutter/foundation.dart';

import '../mock_data/explore_mock_data.dart';
import 'explore_repository.dart';

/// Mock implementation of ExploreRepository for development
class MockExploreRepository implements ExploreRepository {
  @override
  Future<List<LearningProgress>> getLearningProgress() async {
    debugPrint('[MockExploreRepository] getLearningProgress');
    return ExploreMockData.learningProgress;
  }

  @override
  Future<List<QuizItem>> getPopularQuizzes() async {
    debugPrint('[MockExploreRepository] getPopularQuizzes');
    return ExploreMockData.popularQuizzes;
  }

  @override
  Future<List<Language>> getLanguages() async {
    debugPrint('[MockExploreRepository] getLanguages');
    return ExploreMockData.languages;
  }
}
```

**Step 5: 验证编译通过**

Run: `flutter analyze lib/features/explore/`
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/explore/repository/
git add lib/features/explore/mock_data/
git commit -m "feat: add ExploreRepository with mock implementation"
```

---

## Task 10: 创建 Profile Mock 数据和 Repository

**Files:**
- Create: `lib/features/profile/repository/profile_repository.dart`
- Create: `lib/features/profile/repository/real_profile_repository.dart`
- Create: `lib/features/profile/repository/mock_profile_repository.dart`
- Create: `lib/features/profile/mock_data/profile_mock_data.dart`

**Step 1: 创建 ProfileRepository 接口**

```dart
// lib/features/profile/repository/profile_repository.dart

/// Profile 页面数据仓库
abstract class ProfileRepository {
  /// 获取用户统计数据
  Future<UserStats> getUserStats();

  /// 获取用户成就
  Future<List<Achievement>> getAchievements();
}

/// 用户统计数据
class UserStats {
  final int daysStreak;
  final int lessonsCompleted;
  final int xpPoints;

  const UserStats({
    required this.daysStreak,
    required this.lessonsCompleted,
    required this.xpPoints,
  });
}

/// 成就模型
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool earned;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
  });
}
```

**Step 2: 创建 Mock 数据**

```dart
// lib/features/profile/mock_data/profile_mock_data.dart

import '../repository/profile_repository.dart';

class ProfileMockData {
  ProfileMockData._();

  static const UserStats userStats = UserStats(
    daysStreak: 12,
    lessonsCompleted: 48,
    xpPoints: 850,
  );

  static final List<Achievement> achievements = [
    const Achievement(
      id: 'ach_001',
      title: 'First Steps',
      description: 'Complete your first lesson',
      icon: '🎯',
      earned: true,
    ),
    const Achievement(
      id: 'ach_002',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      earned: true,
    ),
    const Achievement(
      id: 'ach_003',
      title: 'Quiz Master',
      description: 'Complete 10 quizzes',
      icon: '🏆',
      earned: false,
    ),
    const Achievement(
      id: 'ach_004',
      title: 'Polyglot',
      description: 'Start learning 3 languages',
      icon: '🌍',
      earned: false,
    ),
  ];
}
```

**Step 3: 创建 RealProfileRepository（占位）**

```dart
// lib/features/profile/repository/real_profile_repository.dart

import 'package:flutter/foundation.dart';

import 'profile_repository.dart';

class RealProfileRepository implements ProfileRepository {
  @override
  Future<UserStats> getUserStats() async {
    debugPrint('[RealProfileRepository] getUserStats - not implemented');
    return const UserStats(daysStreak: 0, lessonsCompleted: 0, xpPoints: 0);
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    debugPrint('[RealProfileRepository] getAchievements - not implemented');
    return [];
  }
}
```

**Step 4: 创建 MockProfileRepository**

```dart
// lib/features/profile/repository/mock_profile_repository.dart

import 'package:flutter/foundation.dart';

import '../mock_data/profile_mock_data.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserStats> getUserStats() async {
    debugPrint('[MockProfileRepository] getUserStats');
    return ProfileMockData.userStats;
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    debugPrint('[MockProfileRepository] getAchievements');
    return ProfileMockData.achievements;
  }
}
```

**Step 5: 验证编译通过**

Run: `flutter analyze lib/features/profile/`
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/profile/repository/
git add lib/features/profile/mock_data/
git commit -m "feat: add ProfileRepository with mock implementation"
```

---

## Task 11: 创建 Chat Mock 数据和 Repository

**Files:**
- Create: `lib/features/chat/repository/chat_repository.dart`
- Create: `lib/features/chat/repository/real_chat_repository.dart`
- Create: `lib/features/chat/repository/mock_chat_repository.dart`
- Create: `lib/features/chat/mock_data/chat_mock_data.dart`

**Step 1: 创建 ChatRepository 接口**

```dart
// lib/features/chat/repository/chat_repository.dart

/// Chat 页面数据仓库
abstract class ChatRepository {
  /// 获取会话列表
  Future<List<Conversation>> getConversations();

  /// 获取会话消息
  Future<List<Message>> getMessages(String conversationId);
}

/// 会话模型
class Conversation {
  final String id;
  final String name;
  final String? avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.name,
    this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

/// 消息模型
class Message {
  final String id;
  final String conversationId;
  final String content;
  final bool isMe;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.isMe,
    required this.timestamp,
  });
}
```

**Step 2: 创建 Mock 数据**

```dart
// lib/features/chat/mock_data/chat_mock_data.dart

import '../repository/chat_repository.dart';

class ChatMockData {
  ChatMockData._();

  static final List<Conversation> conversations = [
    Conversation(
      id: 'conv_001',
      name: 'Spanish Study Group',
      avatar: null,
      lastMessage: 'Anyone want to practice Spanish?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 3,
    ),
    Conversation(
      id: 'conv_002',
      name: 'French Learning Circle',
      avatar: null,
      lastMessage: 'Great session today!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
    ),
    Conversation(
      id: 'conv_003',
      name: 'Language Exchange',
      avatar: null,
      lastMessage: 'See you tomorrow!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
  ];

  static final Map<String, List<Message>> messages = {
    'conv_001': [
      Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        content: 'Hola! How is everyone doing?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: 'msg_002',
        conversationId: 'conv_001',
        content: 'Doing great! Learning a lot.',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Message(
        id: 'msg_003',
        conversationId: 'conv_001',
        content: 'Anyone want to practice Spanish?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
    'conv_002': [
      Message(
        id: 'msg_004',
        conversationId: 'conv_002',
        content: 'Bonjour!',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'msg_005',
        conversationId: 'conv_002',
        content: 'Great session today!',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  };
}
```

**Step 3: 创建 RealChatRepository（占位）**

```dart
// lib/features/chat/repository/real_chat_repository.dart

import 'package:flutter/foundation.dart';

import 'chat_repository.dart';

class RealChatRepository implements ChatRepository {
  @override
  Future<List<Conversation>> getConversations() async {
    debugPrint('[RealChatRepository] getConversations - not implemented');
    return [];
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    debugPrint('[RealChatRepository] getMessages - not implemented');
    return [];
  }
}
```

**Step 4: 创建 MockChatRepository**

```dart
// lib/features/chat/repository/mock_chat_repository.dart

import 'package:flutter/foundation.dart';

import '../mock_data/chat_mock_data.dart';
import 'chat_repository.dart';

class MockChatRepository implements ChatRepository {
  @override
  Future<List<Conversation>> getConversations() async {
    debugPrint('[MockChatRepository] getConversations');
    return ChatMockData.conversations;
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    debugPrint('[MockChatRepository] getMessages: $conversationId');
    return ChatMockData.messages[conversationId] ?? [];
  }
}
```

**Step 5: 验证编译通过**

Run: `flutter analyze lib/features/chat/`
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/chat/repository/
git add lib/features/chat/mock_data/
git commit -m "feat: add ChatRepository with mock implementation"
```

---

## Task 12: 最终验证

**Step 1: 全量编译检查**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 运行应用**

Run: `flutter run -d chrome --web-port=42001`

**Step 3: 完整测试流程**

1. 启动应用
2. 进入 Profile 页面
3. 连续点击版本号 5 次解锁开发者菜单
4. 开启 Mock 模式
5. 重启应用
6. 使用 test@test.com / password123 登录
7. 验证各页面数据显示正常

**Step 4: 最终 Commit**

```bash
git add -A
git commit -m "feat: complete mock service implementation for all features"
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | 创建 MockConfig 核心状态 |
| 2 | 重构 AuthRepository 分离接口与实现 |
| 3 | 创建 Auth Mock 数据 |
| 4 | 创建 MockAuthRepository |
| 5 | 更新 ServiceLocator 支持 Mock 模式 |
| 6 | 创建开发者菜单组件 |
| 7 | 集成开发者菜单到 Profile 页面 |
| 8 | 验证 Mock 模式工作 |
| 9 | 创建 Explore Mock 数据和 Repository |
| 10 | 创建 Profile Mock 数据和 Repository |
| 11 | 创建 Chat Mock 数据和 Repository |
| 12 | 最终验证 |
