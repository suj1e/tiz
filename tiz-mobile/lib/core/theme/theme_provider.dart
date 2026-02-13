import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../storage/preferences.dart';

enum AppThemeMode { system, light, dark }

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final asyncPrefs = ref.watch(preferencesProvider);
  return asyncPrefs.when(
    data: (prefs) => ThemeModeNotifier(prefs),
    loading: () => ThemeModeNotifier(null),
    error: (_, __) => ThemeModeNotifier(null),
  );
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final Preferences? _preferences;

  ThemeModeNotifier(this._preferences) : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    if (_preferences == null) return;
    final themeIndex = _preferences!.getThemeMode();
    state = AppThemeMode.values[themeIndex];
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    if (_preferences == null) return;
    await _preferences!.setThemeMode(mode.index);
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
