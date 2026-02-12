import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';

/// Settings Page
/// Accessible from Profile → Settings menu item
/// Sections: Account, Notifications, Privacy, Language, Help
/// Each section has toggle/arrow items
/// Back button at top
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '设置',
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          children: [
            // Account Section
            _buildSectionHeader(colors, '账户'),
            _buildSettingsItem(
              colors,
              Icons.person_outline_rounded,
              '个人信息',
              () => _showMockDialog(context, colors, '个人信息'),
            ),
            _buildSettingsItem(
              colors,
              Icons.lock_outline_rounded,
              '密码与安全',
              () => _showMockDialog(context, colors, '密码与安全'),
            ),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(colors, '通知'),
            _buildToggleItem(
              colors,
              Icons.notifications_outlined,
              '推送通知',
              true,
              (value) {},
            ),
            _buildToggleItem(
              colors,
              Icons.email_outlined,
              '邮件通知',
              false,
              (value) {},
            ),
            const SizedBox(height: 24),

            // Privacy Section
            _buildSectionHeader(colors, '隐私'),
            _buildToggleItem(
              colors,
              Icons.visibility_outlined,
              '在线状态',
              true,
              (value) {},
            ),
            _buildSettingsItem(
              colors,
              Icons.shield_outlined,
              '隐私设置',
              () => _showMockDialog(context, colors, '隐私设置'),
            ),
            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader(colors, '语言'),
            _buildSettingsItem(
              colors,
              Icons.translate_rounded,
              '界面语言',
              () => _showLanguageSelector(context, colors),
            ),
            _buildSettingsItem(
              colors,
              Icons.g_translate,
              '学习语言',
              () => _showMockDialog(context, colors, '学习语言'),
            ),
            const SizedBox(height: 24),

            // Help Section
            _buildSectionHeader(colors, '帮助'),
            _buildSettingsItem(
              colors,
              Icons.help_outline_rounded,
              '帮助中心',
              () => _showMockDialog(context, colors, '帮助中心'),
            ),
            _buildSettingsItem(
              colors,
              Icons.chat_bubble_outline_rounded,
              '联系客服',
              () => _showMockDialog(context, colors, '联系客服'),
            ),
            _buildSettingsItem(
              colors,
              Icons.bug_report_outlined,
              '反馈问题',
              () => _showMockDialog(context, colors, '反馈问题'),
            ),
            _buildSettingsItem(
              colors,
              Icons.info_outline_rounded,
              '关于 Tiz',
              () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    ThemeColors colors,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colors.text,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
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

  Widget _buildToggleItem(
    ThemeColors colors,
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colors.text,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
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
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value ? colors.accent : colors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.bg,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  void _showLanguageSelector(BuildContext context, ThemeColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
          ),
          border: Border.all(color: colors.border, width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '界面语言',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, colors, '简体中文', true),
            _buildLanguageOption(context, colors, 'English', false),
            _buildLanguageOption(context, colors, '日本語', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, ThemeColors colors, String language, bool isSelected) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.bgSecondary,
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  color: isSelected ? colors.bg : colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: colors.bg,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
