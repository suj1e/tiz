import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';

/// Minimalist Profile Page
/// User profile, settings, and navigation to AI settings
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              _buildProfileCard(context, colors),

              const SizedBox(height: 24),

              // AI Settings Navigation
              _buildSettingsSection(context, colors, AppStrings.profileAiSettings, [
                _buildAiSettingsNavigation(context, colors),
              ]),

              const SizedBox(height: 24),

              // App Settings Section
              _buildSettingsSection(context, colors, '应用设置', [
                _buildThemeItem(colors),
              ]),

              const SizedBox(height: 24),

              // Other Section
              _buildSettingsSection(context, colors, '其他', [
                _buildNavigationItem(context, colors, Icons.person_outline_rounded, '个人信息'),
                _buildNavigationItem(context, colors, Icons.shield_outlined, '隐私与安全'),
                _buildNavigationItem(context, colors, Icons.info_outline_rounded, '关于 Tiz'),
              ]),

              const SizedBox(height: 24),

              // Logout Button
              _buildLogoutButton(context, colors),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Profile Card
  Widget _buildProfileCard(BuildContext context, ThemeColors colors) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/personal-info'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar - SVG Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                border: Border.all(color: colors.border, width: 1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: colors.text,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              'Tiz 用户',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Bio
            Text(
              '学习语言，探索世界',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Edit hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: colors.textTertiary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '点击编辑',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Settings Section with Title
  Widget _buildSettingsSection(BuildContext context, ThemeColors colors, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05,
            ),
          ),
        ),
        // Section Items
        ...items,
      ],
    );
  }

  /// Build AI Settings Navigation Item
  Widget _buildAiSettingsNavigation(BuildContext context, ThemeColors colors) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ai-settings'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: colors.text,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 配置',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '模型选择、API Key、高级设置',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Text(
              '›',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Theme Item
  Widget _buildThemeItem(ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border.all(color: colors.border, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: colors.text,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Label
          Expanded(
            child: Text(
              AppStrings.profileTheme,
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Theme Selector
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final currentTheme = themeProvider.currentThemeType;
              return Row(
                children: AppTheme.values.map((theme) {
                  final isSelected = currentTheme == theme;
                  return GestureDetector(
                    onTap: () {
                      context.read<ThemeProvider>().setTheme(theme);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.accent : colors.bgSecondary,
                        border: Border.all(
                          color: isSelected ? colors.accent : colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            theme == AppTheme.light
                                ? Icons.wb_sunny_outlined
                                : Icons.nights_stay_outlined,
                            color: isSelected ? colors.bg : colors.text,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            theme.displayName,
                            style: TextStyle(
                              color: isSelected ? colors.bg : colors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build Navigation Item (with arrow)
  Widget _buildNavigationItem(BuildContext context, ThemeColors colors, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Navigate to appropriate page based on label
        switch (label) {
          case '个人信息':
            Navigator.pushNamed(context, '/personal-info');
            break;
          case '隐私与安全':
            Navigator.pushNamed(context, '/privacy');
            break;
          case '关于 Tiz':
            Navigator.pushNamed(context, '/about');
            break;
          default:
            _showMockDialog(context, colors, label);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colors.text,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow
            Text(
              '›',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Logout Button
  Widget _buildLogoutButton(BuildContext context, ThemeColors colors) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context, colors),
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '退出登录',
            style: TextStyle(
              color: colors.error,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Show Logout Dialog
  void _showLogoutDialog(BuildContext context, ThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text(
          '退出登录',
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          '确定要退出登录吗？',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: colors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show Mock Dialog
  void _showMockDialog(BuildContext context, ThemeColors colors, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          '此功能正在开发中',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '确定',
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

