import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题'),
      ),
      body: ListView(
        children: [
          _ThemeOption(
            title: '跟随系统',
            subtitle: '根据系统设置自动切换',
            value: AppThemeMode.system,
            groupValue: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setTheme(mode),
          ),
          _ThemeOption(
            title: '浅色模式',
            subtitle: '始终使用浅色主题',
            value: AppThemeMode.light,
            groupValue: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setTheme(mode),
          ),
          _ThemeOption(
            title: '深色模式',
            subtitle: '始终使用深色主题',
            value: AppThemeMode.dark,
            groupValue: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setTheme(mode),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final AppThemeMode value;
  final AppThemeMode groupValue;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
