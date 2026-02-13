# Tiz Mobile MVP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a complete Flutter MVP app with translation, messaging, and profile features using Mock data.

**Architecture:** Feature-based structure with Repository pattern for Mock/Real backend switching. Riverpod for state management, go_router for navigation, Material 3 with pure black/white theme.

**Tech Stack:** Flutter 3.x, Riverpod, Dio, go_router, shared_preferences, Material 3

---

## Task 1: Project Initialization

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `analysis_options.yaml`

**Step 1: Create Flutter project**

```bash
cd /opt/dev/apps/tiz/tiz-mobile
flutter create . --org com.tiz --project-name tiz_mobile
```

**Step 2: Update pubspec.yaml with dependencies**

```yaml
name: tiz_mobile
description: Tiz Mobile MVP
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Networking
  dio: ^5.4.0
  retrofit: ^4.1.0
  json_annotation: ^4.8.1

  # Routing
  go_router: ^13.1.0

  # Storage
  shared_preferences: ^2.2.2

  # Utils
  uuid: ^4.3.1
  share_plus: ^7.2.1
  flutter_clipboard: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  retrofit_generator: ^8.1.0
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
```

**Step 3: Install dependencies**

```bash
flutter pub get
```

**Step 4: Create analysis_options.yaml**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
```

**Step 5: Update lib/main.dart with minimal app**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const TizApp());
}

class TizApp extends StatelessWidget {
  const TizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Tiz MVP'),
        ),
      ),
    );
  }
}
```

**Step 6: Verify app runs**

```bash
flutter run -d chrome
```
Expected: App shows "Tiz MVP" centered

**Step 7: Commit**

```bash
git add .
git commit -m "chore: initialize Flutter project with dependencies"
```

---

## Task 2: Core Theme System

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/theme_provider.dart`

**Step 1: Create AppColors with pure black/white palette**

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark theme colors
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkOnBackground = Color(0xFFFFFFFF);
  static const darkOnSurface = Color(0xFFB0B0B0);
  static const darkBorder = Color(0xFF333333);

  // Light theme colors
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightOnBackground = Color(0xFF000000);
  static const lightOnSurface = Color(0xFF666666);
  static const lightBorder = Color(0xFFE0E0E0);
}
```

**Step 2: Create AppTheme with dark/light themes**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnBackground,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkOnBackground),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkOnBackground,
          foregroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkOnSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.darkOnBackground,
        unselectedItemColor: AppColors.darkOnSurface,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnBackground,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightOnBackground),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightOnBackground,
          foregroundColor: AppColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightOnSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedItemColor: AppColors.lightOnBackground,
        unselectedItemColor: AppColors.lightOnSurface,
      ),
    );
  }
}
```

**Step 3: Create ThemeMode provider**

```dart
// lib/core/theme/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../storage/preferences.dart';

enum AppThemeMode { system, light, dark }

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(preferencesProvider));
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final Preferences _preferences;

  ThemeModeNotifier(this._preferences) : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeIndex = _preferences.getThemeMode();
    state = AppThemeMode.values[themeIndex];
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _preferences.setThemeMode(mode.index);
  }

  ThemeMode toMaterialThemeMode() {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
```

**Step 4: Verify theme files compile**

```bash
flutter analyze lib/core/theme/
```
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add pure black/white theme system with Material 3"
```

---

## Task 3: Storage Layer

**Files:**
- Create: `lib/core/storage/preferences.dart`

**Step 1: Create Preferences wrapper**

```dart
// lib/core/storage/preferences.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences _prefs;

  Preferences(this._prefs);

  // Theme
  static const _themeModeKey = 'theme_mode';
  int getThemeMode() => _prefs.getInt(_themeModeKey) ?? 0;
  Future<void> setThemeMode(int mode) => _prefs.setInt(_themeModeKey, mode);

  // Default target language
  static const _targetLangKey = 'target_language';
  String getTargetLanguage() => _prefs.getString(_targetLangKey) ?? 'en';
  Future<void> setTargetLanguage(String lang) => _prefs.setString(_targetLangKey, lang);

  // Webhooks
  static const _webhooksKey = 'webhooks';
  List<String> getWebhooks() => _prefs.getStringList(_webhooksKey) ?? [];
  Future<void> setWebhooks(List<String> urls) => _prefs.setStringList(_webhooksKey, urls);

  // Message read status
  static const _readMessagesKey = 'read_messages';
  Set<String> getReadMessageIds() =>
      (_prefs.getStringList(_readMessagesKey) ?? []).toSet();
  Future<void> setReadMessageIds(Set<String> ids) =>
      _prefs.setStringList(_readMessagesKey, ids.toList());
}

final preferencesProvider = FutureProvider<Preferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return Preferences(prefs);
});
```

**Step 2: Verify storage compiles**

```bash
flutter analyze lib/core/storage/
```
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/storage/
git commit -m "feat: add shared_preferences wrapper for local storage"
```

---

## Task 4: Router Setup

**Files:**
- Create: `lib/core/router/app_router.dart`
- Create: `lib/features/discovery/presentation/discovery_page.dart`
- Create: `lib/features/message/presentation/message_page.dart`
- Create: `lib/features/profile/presentation/profile_page.dart`
- Create: `lib/features/discovery/presentation/quiz_placeholder_page.dart`
- Create: `lib/shared/widgets/main_shell.dart`

**Step 1: Create placeholder pages**

```dart
// lib/features/discovery/presentation/discovery_page.dart
import 'package:flutter/material.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('发现')),
    );
  }
}
```

```dart
// lib/features/discovery/presentation/quiz_placeholder_page.dart
import 'package:flutter/material.dart';

class QuizPlaceholderPage extends StatelessWidget {
  const QuizPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('测验')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64),
            SizedBox(height: 16),
            Text('敬请期待', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
```

```dart
// lib/features/message/presentation/message_page.dart
import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('消息')),
    );
  }
}
```

```dart
// lib/features/profile/presentation/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('我的')),
    );
  }
}
```

**Step 2: Create MainShell with bottom navigation**

```dart
// lib/shared/widgets/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.message_outlined), label: '消息'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: '发现'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}
```

**Step 3: Create router configuration**

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/discovery/presentation/discovery_page.dart';
import '../../features/discovery/presentation/quiz_placeholder_page.dart';
import '../../features/message/presentation/message_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../theme/theme_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  return GoRouter(
    initialLocation: '/discover',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessagePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoveryPage(),
                routes: [
                  GoRoute(
                    path: 'quiz',
                    builder: (context, state) => const QuizPlaceholderPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
```

**Step 4: Verify router compiles**

```bash
flutter analyze lib/core/router/ lib/shared/ lib/features/*/presentation/
```
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/core/router/ lib/shared/ lib/features/
git commit -m "feat: add go_router with bottom navigation shell"
```

---

## Task 5: App Entry Point with Riverpod

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`

**Step 1: Create app.dart with theme integration**

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class TizApp extends ConsumerWidget {
  const TizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Tiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode.toMaterialThemeMode(),
      routerConfig: router,
    );
  }
}
```

**Step 2: Update main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TizApp(),
    ),
  );
}
```

**Step 3: Verify app runs with navigation**

```bash
flutter run -d chrome
```
Expected: App shows bottom navigation, can switch tabs

**Step 4: Commit**

```bash
git add lib/main.dart lib/app.dart
git commit -m "feat: integrate Riverpod and router into app entry"
```

---

## Task 6: Translation Domain Models

**Files:**
- Create: `lib/features/translation/domain/language.dart`
- Create: `lib/features/translation/domain/translation_result.dart`

**Step 1: Create Language enum**

```dart
// lib/features/translation/domain/language.dart
enum Language {
  en('English', 'en'),
  yue('粤语', 'yue'),
  szc('川语', 'szc'),
  zh('中文', 'zh');

  final String label;
  final String code;

  const Language(this.label, this.code);

  static Language? fromCode(String code) {
    for (final lang in values) {
      if (lang.code == code) return lang;
    }
    return null;
  }
}
```

**Step 2: Create TranslationResult model**

```dart
// lib/features/translation/domain/translation_result.dart
class TranslationResult {
  final String originalText;
  final Language detectedSourceLanguage;
  final Language targetLanguage;
  final String translatedText;

  const TranslationResult({
    required this.originalText,
    required this.detectedSourceLanguage,
    required this.targetLanguage,
    required this.translatedText,
  });
}
```

**Step 3: Verify models compile**

```bash
flutter analyze lib/features/translation/domain/
```
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/translation/domain/
git commit -m "feat: add translation domain models"
```

---

## Task 7: Translation Repository with Mock

**Files:**
- Create: `lib/features/translation/data/translation_repository.dart`
- Create: `lib/features/translation/data/mock_translation_repository.dart`
- Create: `lib/features/translation/data/api_translation_repository.dart`
- Create: `lib/features/translation/translation_provider.dart`

**Step 1: Create repository interface**

```dart
// lib/features/translation/data/translation_repository.dart
import '../domain/language.dart';
import '../domain/translation_result.dart';

abstract class TranslationRepository {
  Future<TranslationResult> translate({
    required String text,
    required Language targetLanguage,
  });

  Future<Language> detectLanguage(String text);
}
```

**Step 2: Create Mock implementation**

```dart
// lib/features/translation/data/mock_translation_repository.dart
import 'dart:math';
import '../domain/language.dart';
import '../domain/translation_result.dart';
import 'translation_repository.dart';

class MockTranslationRepository implements TranslationRepository {
  final Random _random = Random();

  @override
  Future<TranslationResult> translate({
    required String text,
    required Language targetLanguage,
  }) async {
    // Simulate network delay
    await Future.delayed(
      Duration(milliseconds: 500 + _random.nextInt(500)),
    );

    // Detect source language (mock)
    final sourceLanguage = await detectLanguage(text);

    // Generate mock translation
    final translatedText = _generateMockTranslation(text, targetLanguage);

    return TranslationResult(
      originalText: text,
      detectedSourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      translatedText: translatedText,
    );
  }

  @override
  Future<Language> detectLanguage(String text) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Simple mock detection based on character patterns
    if (text.contains(RegExp(r'[\u4e00-\u9fff]'))) {
      // Check for Cantonese patterns
      if (text.contains(RegExp(r'嘅|喺|唔|佢|咁'))) {
        return Language.yue;
      }
      // Check for Sichuanese patterns
      if (text.contains(RegExp(r'撒|嘛|哈|喔|噻'))) {
        return Language.szc;
      }
      return Language.zh;
    }
    return Language.en;
  }

  String _generateMockTranslation(String text, Language targetLanguage) {
    // Mock translations for demo
    final mockTranslations = <Language, String>{
      Language.en: '[Mock EN] $text',
      Language.yue: '[Mock 粤语] $text',
      Language.szc: '[Mock 川语] $text',
      Language.zh: '[Mock 中文] $text',
    };
    return mockTranslations[targetLanguage] ?? text;
  }
}
```

**Step 3: Create API implementation (ready for backend)**

```dart
// lib/features/translation/data/api_translation_repository.dart
import 'package:dio/dio.dart';
import '../domain/language.dart';
import '../domain/translation_result.dart';
import 'translation_repository.dart';

class ApiTranslationRepository implements TranslationRepository {
  final Dio _dio;

  ApiTranslationRepository(this._dio);

  @override
  Future<TranslationResult> translate({
    required String text,
    required Language targetLanguage,
  }) async {
    final response = await _dio.post(
      '/api/v1/translate',
      data: {
        'text': text,
        'targetLanguage': targetLanguage.code,
      },
    );

    return TranslationResult(
      originalText: text,
      detectedSourceLanguage: Language.fromCode(response.data['detectedLanguage']) ?? Language.zh,
      targetLanguage: targetLanguage,
      translatedText: response.data['translatedText'],
    );
  }

  @override
  Future<Language> detectLanguage(String text) async {
    final response = await _dio.post(
      '/api/v1/detect-language',
      data: {'text': text},
    );

    return Language.fromCode(response.data['language']) ?? Language.zh;
  }
}
```

**Step 4: Create provider with Mock/Real switch**

```dart
// lib/features/translation/translation_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/api_translation_repository.dart';
import 'data/mock_translation_repository.dart';
import 'data/translation_repository.dart';

const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:40004'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  if (useMock) {
    return MockTranslationRepository();
  }
  return ApiTranslationRepository(ref.watch(dioProvider));
});
```

**Step 5: Verify repository compiles**

```bash
flutter analyze lib/features/translation/
```
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/translation/
git commit -m "feat: add translation repository with mock and API implementations"
```

---

## Task 8: Translation Page UI

**Files:**
- Create: `lib/features/translation/presentation/translation_page.dart`
- Create: `lib/features/translation/presentation/translation_controller.dart`
- Modify: `lib/features/discovery/presentation/discovery_page.dart`

**Step 1: Create translation controller**

```dart
// lib/features/translation/presentation/translation_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/language.dart';
import '../domain/translation_result.dart';
import '../translation_provider.dart';

enum TranslationState { idle, detecting, translating, success, error }

class TranslationController extends StateNotifier<TranslationState> {
  final TranslationRepository _repository;

  TranslationController(this._repository) : super(TranslationState.idle);

  TranslationResult? result;
  Language? detectedLanguage;
  String? errorMessage;

  Future<void> detectAndTranslate(String text, Language targetLanguage) async {
    if (text.trim().isEmpty) {
      errorMessage = '请输入文本';
      state = TranslationState.error;
      return;
    }

    state = TranslationState.detecting;

    try {
      detectedLanguage = await _repository.detectLanguage(text);
      state = TranslationState.translating;

      result = await _repository.translate(
        text: text,
        targetLanguage: targetLanguage,
      );
      state = TranslationState.success;
    } catch (e) {
      errorMessage = e.toString();
      state = TranslationState.error;
    }
  }

  void reset() {
    state = TranslationState.idle;
    result = null;
    detectedLanguage = null;
    errorMessage = null;
  }
}

final translationControllerProvider =
    StateNotifierProvider<TranslationController, TranslationState>((ref) {
  return TranslationController(ref.watch(translationRepositoryProvider));
});
```

**Step 2: Create translation page**

```dart
// lib/features/translation/presentation/translation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/storage/preferences.dart';
import '../domain/language.dart';
import 'translation_controller.dart';

class TranslationPage extends ConsumerStatefulWidget {
  const TranslationPage({super.key});

  @override
  ConsumerState<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends ConsumerState<TranslationPage> {
  final _textController = TextEditingController();
  Language _targetLanguage = Language.en;

  @override
  void initState() {
    super.initState();
    _loadDefaultLanguage();
  }

  Future<void> _loadDefaultLanguage() async {
    final prefs = await ref.read(preferencesProvider.future);
    final savedLang = prefs.getTargetLanguage();
    setState(() {
      _targetLanguage = Language.fromCode(savedLang) ?? Language.en;
    });
  }

  Future<void> _saveDefaultLanguage(Language lang) async {
    final prefs = await ref.read(preferencesProvider.future);
    await prefs.setTargetLanguage(lang.code);
  }

  void _onTranslate() {
    final controller = ref.read(translationControllerProvider.notifier);
    controller.detectAndTranslate(_textController.text, _targetLanguage);
  }

  void _onCopy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制'), duration: Duration(seconds: 1)),
    );
  }

  void _onShare(String text) {
    Share.share(text);
  }

  void _onClear() {
    _textController.clear();
    ref.read(translationControllerProvider.notifier).reset();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translationControllerProvider);
    final controller = ref.read(translationControllerProvider.notifier);

    return Column(
      children: [
        // Target language selector
        _buildLanguageSelector(),

        // Input area
        Expanded(
          flex: 1,
          child: _buildInputArea(),
        ),

        // Divider
        const Divider(height: 1),

        // Output area
        Expanded(
          flex: 1,
          child: _buildOutputArea(state, controller),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('目标语言: '),
          const SizedBox(width: 8),
          DropdownButton<Language>(
            value: _targetLanguage,
            underline: const SizedBox(),
            items: [Language.en, Language.yue, Language.szc].map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang.label),
              );
            }).toList(),
            onChanged: (lang) {
              if (lang != null) {
                setState(() => _targetLanguage = lang);
                _saveDefaultLanguage(lang);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: '输入要翻译的文本...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _onClear,
                child: const Text('清空'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _textController.text.isEmpty ? null : _onTranslate,
                child: const Text('翻译'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputArea(TranslationState state, TranslationController controller) {
    if (state == TranslationState.idle) {
      return const Center(
        child: Text('翻译结果将显示在这里'),
      );
    }

    if (state == TranslationState.detecting || state == TranslationState.translating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(state == TranslationState.detecting ? '检测语言中...' : '翻译中...'),
          ],
        ),
      );
    }

    if (state == TranslationState.error) {
      return Center(
        child: Text(controller.errorMessage ?? '翻译失败'),
      );
    }

    final result = controller.result;
    if (result == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detected language
          Text(
            '检测到: ${result.detectedSourceLanguage.label} → ${result.targetLanguage.label}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),

          // Translation result
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                result.translatedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _onCopy(result.translatedText),
                icon: const Icon(Icons.copy),
                label: const Text('复制'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _onShare(result.translatedText),
                icon: const Icon(Icons.share),
                label: const Text('分享'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Update discovery page with tabs**

```dart
// lib/features/discovery/presentation/discovery_page.dart
import 'package:flutter/material.dart';
import '../../translation/presentation/translation_page.dart';
import 'quiz_placeholder_page.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '翻译'),
          Tab(text: '测验'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TranslationPage(),
          QuizPlaceholderPage(),
        ],
      ),
    );
  }
}
```

**Step 4: Verify translation page compiles**

```bash
flutter analyze lib/features/translation/presentation/ lib/features/discovery/presentation/
```
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/translation/presentation/ lib/features/discovery/presentation/
git commit -m "feat: add translation page with language detection and copy/share"
```

---

## Task 9: Message Domain Models

**Files:**
- Create: `lib/features/message/domain/message.dart`
- Create: `lib/features/message/domain/message_type.dart`

**Step 1: Create MessageType enum**

```dart
// lib/features/message/domain/message_type.dart
enum MessageType {
  aiReminder('AI 提醒'),
  webhook('Webhook 推送');

  final String label;
  const MessageType(this.label);
}
```

**Step 2: Create Message model**

```dart
// lib/features/message/domain/message.dart'
import 'message_type.dart';

class Message {
  final String id;
  final MessageType type;
  final String title;
  final String summary;
  final DateTime createdAt;
  final String? actionUrl;

  const Message({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.createdAt,
    this.actionUrl,
  });
}
```

**Step 3: Verify models compile**

```bash
flutter analyze lib/features/message/domain/
```
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/message/domain/
git commit -m "feat: add message domain models"
```

---

## Task 10: Message Repository with Mock

**Files:**
- Create: `lib/features/message/data/message_repository.dart`
- Create: `lib/features/message/data/mock_message_repository.dart`
- Create: `lib/features/message/message_provider.dart`

**Step 1: Create repository interface**

```dart
// lib/features/message/data/message_repository.dart
import '../domain/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages();
  Future<void> markAsRead(String messageId);
  Future<bool> isRead(String messageId);
}
```

**Step 2: Create Mock implementation**

```dart
// lib/features/message/data/mock_message_repository.dart
import '../domain/message.dart';
import '../domain/message_type.dart';
import 'message_repository.dart';

class MockMessageRepository implements MessageRepository {
  final List<Message> _mockMessages = [
    Message(
      id: '1',
      type: MessageType.aiReminder,
      title: '今日翻译任务完成',
      summary: '您已完成今天的翻译练习目标，继续保持！',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Message(
      id: '2',
      type: MessageType.webhook,
      title: '系统通知',
      summary: '您的 Webhook 配置已更新成功。',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Message(
      id: '3',
      type: MessageType.aiReminder,
      title: '学习提醒',
      summary: '您有一段时间没有使用翻译功能了，快来练习吧！',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Message(
      id: '4',
      type: MessageType.webhook,
      title: '外部事件触发',
      summary: '收到来自 GitHub 的 Push 事件通知。',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      actionUrl: 'https://github.com',
    ),
    Message(
      id: '5',
      type: MessageType.aiReminder,
      title: '川语学习进度',
      summary: '您已学习川语词汇 50 个，达到入门水平！',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<Message>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMessages;
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, this would update backend
  }

  @override
  Future<bool> isRead(String messageId) async {
    // Will be handled by local storage
    return false;
  }
}
```

**Step 3: Create provider**

```dart
// lib/features/message/message_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/preferences.dart';
import 'data/message_repository.dart';
import 'data/mock_message_repository.dart';

const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MockMessageRepository();
});

final readMessageIdsProvider = FutureProvider<Set<String>>((ref) async {
  final prefs = await ref.watch(preferencesProvider.future);
  return prefs.getReadMessageIds();
});
```

**Step 4: Verify repository compiles**

```bash
flutter analyze lib/features/message/
```
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/message/data/ lib/features/message/message_provider.dart
git commit -m "feat: add message repository with mock data"
```

---

## Task 11: Message Page UI

**Files:**
- Create: `lib/features/message/presentation/message_list_item.dart`
- Modify: `lib/features/message/presentation/message_page.dart`
- Create: `lib/features/message/presentation/message_detail_page.dart`

**Step 1: Create message list item widget**

```dart
// lib/features/message/presentation/message_list_item.dart
import 'package:flutter/material.dart';
import '../domain/message.dart';

class MessageListItem extends StatelessWidget {
  final Message message;
  final bool isRead;
  final VoidCallback onTap;

  const MessageListItem({
    super.key,
    required this.message,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRead ? Colors.transparent : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.type.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                message.summary,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inHours < 1) {
      return '刚刚';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
```

**Step 2: Create message detail page**

```dart
// lib/features/message/presentation/message_detail_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/message.dart';

class MessageDetailPage extends StatelessWidget {
  final Message message;

  const MessageDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message.type.label),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _formatFullTime(message.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              message.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (message.actionUrl != null) ...[
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openUrl(message.actionUrl!),
                  child: const Text('查看详情'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFullTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
```

**Step 3: Update message page with full implementation**

```dart
// lib/features/message/presentation/message_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/preferences.dart';
import '../data/message_repository.dart';
import '../domain/message.dart';
import '../message_provider.dart';
import 'message_list_item.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  List<Message>? _messages;
  Set<String> _readIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final repository = ref.read(messageRepositoryProvider);
    final readIdsAsync = ref.read(readMessageIdsProvider);

    final messages = await repository.getMessages();
    final readIds = await readIdsAsync.maybeWhen(
      data: (ids) => ids,
      orElse: () => <String>{},
    );

    setState(() {
      _messages = messages;
      _readIds = readIds;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(Message message) async {
    final prefs = await ref.read(preferencesProvider.future);
    final newReadIds = {..._readIds, message.id};
    await prefs.setReadMessageIds(newReadIds);

    setState(() {
      _readIds = newReadIds;
    });
  }

  void _onMessageTap(Message message) {
    _markAsRead(message);
    context.push('/messages/${message.id}', extra: message);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages == null || _messages!.isEmpty) {
      return const Center(child: Text('暂无消息'));
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        itemCount: _messages!.length,
        itemBuilder: (context, index) {
          final message = _messages![index];
          return MessageListItem(
            message: message,
            isRead: _readIds.contains(message.id),
            onTap: () => _onMessageTap(message),
          );
        },
      ),
    );
  }
}
```

**Step 4: Add url_launcher dependency**

Update pubspec.yaml to add:
```yaml
  url_launcher: ^6.2.2
```

```bash
flutter pub get
```

**Step 5: Update router with message detail route**

```dart
// Update lib/core/router/app_router.dart
// Add import:
import '../../features/message/presentation/message_detail_page.dart';
import '../../features/message/domain/message.dart';

// Update the messages route to:
GoRoute(
  path: '/messages',
  builder: (context, state) => const MessagePage(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final message = state.extra as Message;
        return MessageDetailPage(message: message);
      },
    ),
  ],
),
```

**Step 6: Verify message feature compiles**

```bash
flutter analyze lib/features/message/
```
Expected: No issues found

**Step 7: Commit**

```bash
git add lib/features/message/ pubspec.yaml
git commit -m "feat: add message page with card list and read/unread status"
```

---

## Task 12: Profile Feature - Domain & Data

**Files:**
- Create: `lib/features/profile/domain/user_profile.dart`
- Create: `lib/features/profile/domain/webhook.dart`
- Create: `lib/features/profile/data/webhook_repository.dart`
- Create: `lib/features/profile/profile_provider.dart`

**Step 1: Create UserProfile model**

```dart
// lib/features/profile/domain/user_profile.dart
class UserProfile {
  final String id;
  final String email;
  final String nickname;

  const UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
  });

  static UserProfile mock() {
    return const UserProfile(
      id: 'mock-user-1',
      email: 'user@tiz.dev',
      nickname: 'Tiz User',
    );
  }
}
```

**Step 2: Create Webhook model**

```dart
// lib/features/profile/domain/webhook.dart
class Webhook {
  final String id;
  final String url;
  final String name;
  final DateTime createdAt;

  const Webhook({
    required this.id,
    required this.url,
    required this.name,
    required this.createdAt,
  });
}
```

**Step 3: Create Webhook repository**

```dart
// lib/features/profile/data/webhook_repository.dart
import 'package:uuid/uuid.dart';
import '../domain/webhook.dart';
import '../../../core/storage/preferences.dart';

class WebhookRepository {
  final Preferences _preferences;
  final _uuid = const Uuid();

  WebhookRepository(this._preferences);

  Future<List<Webhook>> getWebhooks() async {
    final urls = _preferences.getWebhooks();
    return urls.asMap().entries.map((entry) {
      return Webhook(
        id: 'wh-${entry.key}',
        url: entry.value,
        name: _extractName(entry.value),
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  Future<void> addWebhook(String url) async {
    final urls = _preferences.getWebhooks();
    urls.add(url);
    await _preferences.setWebhooks(urls);
  }

  Future<void> updateWebhook(int index, String url) async {
    final urls = _preferences.getWebhooks();
    if (index >= 0 && index < urls.length) {
      urls[index] = url;
      await _preferences.setWebhooks(urls);
    }
  }

  Future<void> deleteWebhook(int index) async {
    final urls = _preferences.getWebhooks();
    if (index >= 0 && index < urls.length) {
      urls.removeAt(index);
      await _preferences.setWebhooks(urls);
    }
  }

  String _extractName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }
}
```

**Step 4: Create providers**

```dart
// lib/features/profile/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/preferences.dart';
import 'data/webhook_repository.dart';
import 'domain/user_profile.dart';

final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile.mock();
});

final webhookRepositoryProvider = FutureProvider<WebhookRepository>((ref) async {
  final prefs = await ref.watch(preferencesProvider.future);
  return WebhookRepository(prefs);
});

final webhooksProvider = FutureProvider<List<Webhook>>((ref) async {
  final repo = await ref.watch(webhookRepositoryProvider.future);
  return repo.getWebhooks();
});
```

**Step 5: Verify profile data layer compiles**

```bash
flutter analyze lib/features/profile/
```
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/profile/domain/ lib/features/profile/data/ lib/features/profile/profile_provider.dart
git commit -m "feat: add profile domain models and webhook repository"
```

---

## Task 13: Profile Page UI

**Files:**
- Modify: `lib/features/profile/presentation/profile_page.dart`
- Create: `lib/features/profile/presentation/theme_settings_page.dart`
- Create: `lib/features/profile/presentation/webhook_settings_page.dart`
- Create: `lib/features/profile/presentation/widgets/profile_menu_item.dart`

**Step 1: Create reusable menu item widget**

```dart
// lib/features/profile/presentation/widgets/profile_menu_item.dart
import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
```

**Step 2: Create theme settings page**

```dart
// lib/features/profile/presentation/theme_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: ListView(
        children: [
          RadioListTile<AppThemeMode>(
            title: const Text('跟随系统'),
            value: AppThemeMode.system,
            groupValue: currentTheme,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setTheme(mode);
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('亮色'),
            value: AppThemeMode.light,
            groupValue: currentTheme,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setTheme(mode);
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('暗色'),
            value: AppThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setTheme(mode);
              }
            },
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Create webhook settings page**

```dart
// lib/features/profile/presentation/webhook_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile_provider.dart';

class WebhookSettingsPage extends ConsumerStatefulWidget {
  const WebhookSettingsPage({super.key});

  @override
  ConsumerState<WebhookSettingsPage> createState() => _WebhookSettingsPageState();
}

class _WebhookSettingsPageState extends ConsumerState<WebhookSettingsPage> {
  final _urlController = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditWebhook() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final repo = await ref.read(webhookRepositoryProvider.future);

    if (_editingIndex != null) {
      await repo.updateWebhook(_editingIndex!, url);
    } else {
      await repo.addWebhook(url);
    }

    _urlController.clear();
    setState(() => _editingIndex = null);
    ref.invalidate(webhooksProvider);
  }

  Future<void> _deleteWebhook(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个 Webhook 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = await ref.read(webhookRepositoryProvider.future);
      await repo.deleteWebhook(index);
      ref.invalidate(webhooksProvider);
    }
  }

  void _editWebhook(int index, String url) {
    _urlController.text = url;
    setState(() => _editingIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final webhooksAsync = ref.watch(webhooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Webhook 配置'),
      ),
      body: Column(
        children: [
          // Input area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: '输入 Webhook URL',
                      suffixIcon: _editingIndex != null
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _urlController.clear();
                                setState(() => _editingIndex = null);
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addOrEditWebhook,
                  icon: Icon(_editingIndex != null ? Icons.check : Icons.add),
                ),
              ],
            ),
          ),
          const Divider(),

          // List
          Expanded(
            child: webhooksAsync.when(
              data: (webhooks) {
                if (webhooks.isEmpty) {
                  return const Center(child: Text('暂无 Webhook'));
                }
                return ListView.builder(
                  itemCount: webhooks.length,
                  itemBuilder: (context, index) {
                    final webhook = webhooks[index];
                    return ListTile(
                      title: Text(webhook.name),
                      subtitle: Text(
                        webhook.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editWebhook(index, webhook.url),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteWebhook(index),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('错误: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 4: Update profile page**

```dart
// lib/features/profile/presentation/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../profile_provider.dart';
import 'theme_settings_page.dart';
import 'webhook_settings_page.dart';
import 'widgets/profile_menu_item.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: ListView(
        children: [
          // User info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // Settings section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '偏好设置',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          ProfileMenuItem(
            icon: Icons.palette_outlined,
            title: '主题',
            subtitle: _getThemeLabel(themeMode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
              );
            },
          ),

          const Divider(),

          // Webhook section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '集成',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          ProfileMenuItem(
            icon: Icons.webhook_outlined,
            title: 'Webhook 配置',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WebhookSettingsPage()),
              );
            },
          ),

          const Divider(),

          // App settings section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '应用',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          ProfileMenuItem(
            icon: Icons.cleaning_services_outlined,
            title: '清除缓存',
            onTap: () => _showClearCacheDialog(context),
          ),

          ProfileMenuItem(
            icon: Icons.info_outline,
            title: '版本信息',
            subtitle: '1.0.0',
            onTap: () => _showAboutDialog(context),
          ),

          const Divider(),

          // Logout
          ProfileMenuItem(
            icon: Icons.logout,
            title: '退出登录',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '亮色';
      case AppThemeMode.dark:
        return '暗色';
    }
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Tiz',
        applicationVersion: '1.0.0',
        applicationLegalese: '© 2024 Tiz',
        children: const [
          SizedBox(height: 16),
          Text('极简极客工具'),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已退出登录 (Mock)')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
```

**Step 5: Verify profile page compiles**

```bash
flutter analyze lib/features/profile/
```
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/profile/
git commit -m "feat: add profile page with theme, webhook, and app settings"
```

---

## Task 14: Final Testing & Polish

**Files:**
- Run: Integration test

**Step 1: Run full analysis**

```bash
flutter analyze
```
Expected: No issues found

**Step 2: Run app and test all features**

```bash
flutter run -d chrome
```

Manual test checklist:
- [ ] App loads with bottom navigation
- [ ] Can switch between 消息/发现/我的 tabs
- [ ] Discovery page shows 翻译/测验 tabs
- [ ] Translation: input text, detect language, translate, copy, share
- [ ] Quiz: shows "敬请期待" placeholder
- [ ] Messages: shows mock messages with read/unread
- [ ] Profile: shows mock user info
- [ ] Theme: can switch between system/light/dark
- [ ] Webhook: can add/edit/delete webhooks
- [ ] App settings: clear cache, version info work

**Step 3: Build for production (Android)**

```bash
flutter build apk --release --dart-define=USE_MOCK=true
```

**Step 4: Final commit**

```bash
git add .
git commit -m "chore: final MVP polish and testing"
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | Project initialization with dependencies |
| 2 | Pure black/white theme system |
| 3 | SharedPreferences storage wrapper |
| 4 | GoRouter with bottom navigation |
| 5 | App entry with Riverpod |
| 6 | Translation domain models |
| 7 | Translation repository (Mock + API) |
| 8 | Translation page UI |
| 9 | Message domain models |
| 10 | Message repository with mock |
| 11 | Message page with read/unread |
| 12 | Profile domain & data layer |
| 13 | Profile page with settings |
| 14 | Final testing & polish |

**Total: 14 tasks**

---

## Switching to Real Backend

When backend (tizsrv) is ready:

1. Set API base URL:
```bash
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://your-gateway:40004
```

2. The API repository will be used automatically

3. API endpoints expected:
- `POST /api/v1/translate` - Translation
- `POST /api/v1/detect-language` - Language detection
- `GET /api/v1/messages` - Message list
- `CRUD /api/v1/webhooks` - Webhook management
