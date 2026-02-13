import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/preferences.dart';
import '../profile_provider.dart';
import 'theme_settings_page.dart';
import 'webhook_settings_page.dart';
import 'widgets/profile_menu_item.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // User info card
          _UserInfoCard(userProfile: userProfile),

          const SizedBox(height: 16),

          // Preference settings
          _SectionHeader(title: '偏好设置'),
          ProfileMenuItem(
            icon: Icons.palette_outlined,
            title: '主题',
            subtitle: _getThemeSubtitle(ref),
            onTap: () => _navigateToThemeSettings(context),
          ),

          const Divider(height: 1),

          // Integration settings
          _SectionHeader(title: '集成'),
          ProfileMenuItem(
            icon: Icons.webhook_outlined,
            title: 'Webhook配置',
            subtitle: '管理消息推送Webhook',
            onTap: () => _navigateToWebhookSettings(context),
          ),

          const Divider(height: 1),

          // App settings
          _SectionHeader(title: '应用'),
          ProfileMenuItem(
            icon: Icons.cleaning_services_outlined,
            title: '清除缓存',
            onTap: () => _showClearCacheDialog(context, ref),
          ),
          ProfileMenuItem(
            icon: Icons.info_outline,
            title: '版本信息',
            subtitle: 'v1.0.0',
            trailing: const SizedBox.shrink(),
            onTap: () => _showAboutDialog(context),
          ),
          ProfileMenuItem(
            icon: Icons.logout,
            title: '退出登录',
            iconColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  String _getThemeSubtitle(WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    switch (themeMode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ThemeSettingsPage()),
    );
  }

  void _navigateToWebhookSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WebhookSettingsPage()),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final asyncPrefs = ref.read(preferencesProvider);
              asyncPrefs.whenData((prefs) async {
                await prefs.setReadMessageIds({});
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Tiz',
      applicationVersion: 'v1.0.0',
      applicationLegalese: 'Copyright 2024 Tiz',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Tiz 是一个企业级微服务平台,'
          '提供消息翻译、内容发现等功能。',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已退出登录 (Mock)')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final userProfile;

  const _UserInfoCard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                userProfile.nickname.isNotEmpty
                    ? userProfile.nickname[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile.nickname,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
