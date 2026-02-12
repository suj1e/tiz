import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';

/// Privacy & Security Page
/// Privacy settings, data collection, account security, delete account
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  // Privacy Settings
  bool _profileVisibility = true;
  bool _activityStatus = true;
  bool _dataCollection = true;
  bool _analyticsSharing = false;
  bool _personalizedAds = false;

  // Security Settings
  bool _twoFactorAuth = false;
  bool _loginNotifications = true;
  bool _biometricLogin = false;

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
          '隐私与安全',
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
            // Privacy Section
            _buildSectionHeader(colors, '隐私设置'),
            _buildToggleItem(
              colors,
              Icons.public_rounded,
              '个人资料可见性',
              '允许其他用户查看您的基本资料',
              _profileVisibility,
              (value) => setState(() => _profileVisibility = value),
            ),
            _buildToggleItem(
              colors,
              Icons.visibility_rounded,
              '在线状态',
              '显示您的在线状态',
              _activityStatus,
              (value) => setState(() => _activityStatus = value),
            ),
            const SizedBox(height: 24),

            // Data Section
            _buildSectionHeader(colors, '数据与个性化'),
            _buildToggleItem(
              colors,
              Icons.sync_rounded,
              '数据收集',
              '允许收集使用数据以改进服务',
              _dataCollection,
              (value) => setState(() => _dataCollection = value),
            ),
            _buildToggleItem(
              colors,
              Icons.analytics_rounded,
              '分析数据共享',
              '与第三方共享匿名使用数据',
              _analyticsSharing,
              (value) => setState(() => _analyticsSharing = value),
            ),
            _buildToggleItem(
              colors,
              Icons.ad_units_rounded,
              '个性化广告',
              '根据您的兴趣显示相关广告',
              _personalizedAds,
              (value) => setState(() => _personalizedAds = value),
            ),
            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader(colors, '账户安全'),
            _buildToggleItem(
              colors,
              Icons.verified_user_rounded,
              '双重认证',
              '使用双重认证保护账户安全',
              _twoFactorAuth,
              (value) => setState(() => _twoFactorAuth = value),
            ),
            _buildToggleItem(
              colors,
              Icons.notifications_active_rounded,
              '登录通知',
              '当账户在新设备登录时通知您',
              _loginNotifications,
              (value) => setState(() => _loginNotifications = value),
            ),
            _buildToggleItem(
              colors,
              Icons.fingerprint_rounded,
              '生物识别登录',
              '使用指纹或面容 ID 登录',
              _biometricLogin,
              (value) => setState(() => _biometricLogin = value),
            ),
            const SizedBox(height: 24),

            // Password Section
            _buildNavigationItem(
              colors,
              Icons.lock_rounded,
              '修改密码',
              () => _showChangePasswordDialog(colors),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionHeader(colors, '危险操作'),
            _buildDangerItem(
              colors,
              Icons.delete_forever_rounded,
              '删除账户',
              '永久删除您的账户和所有数据',
              colors.error,
              () => _showDeleteAccountDialog(colors),
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

  Widget _buildToggleItem(
    ThemeColors colors,
    IconData icon,
    String label,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildNavigationItem(
    ThemeColors colors,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildDangerItem(
    ThemeColors colors,
    IconData icon,
    String label,
    String description,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.error.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
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

  void _showChangePasswordDialog(ThemeColors colors) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.border, width: 1),
          ),
          title: Text(
            '修改密码',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: TextStyle(color: colors.text, fontSize: 14),
                decoration: InputDecoration(
                  labelText: '当前密码',
                  labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: colors.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.accent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(color: colors.text, fontSize: 14),
                decoration: InputDecoration(
                  labelText: '新密码',
                  labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: colors.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.accent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: colors.text, fontSize: 14),
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: colors.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.accent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
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
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('请填写所有字段'),
                      backgroundColor: colors.error,
                    ),
                  );
                  return;
                }
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('两次输入的密码不一致'),
                      backgroundColor: colors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('密码修改成功'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                '确认',
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(ThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.error.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: colors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '删除账户',
              style: TextStyle(
                color: colors.error,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '此操作将永久删除您的账户和所有数据，包括：',
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildDeleteWarningItem(colors, '• 个人资料和设置'),
            _buildDeleteWarningItem(colors, '• 学习进度和记录'),
            _buildDeleteWarningItem(colors, '• 测验历史和成绩'),
            _buildDeleteWarningItem(colors, '• AI 对话记录'),
            const SizedBox(height: 12),
            Text(
              '此操作无法撤销，请谨慎操作。',
              style: TextStyle(
                color: colors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
              _showDeleteConfirmDialog(colors);
            },
            child: Text(
              '继续删除',
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

  Widget _buildDeleteWarningItem(ThemeColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(ThemeColors colors) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.error.withOpacity(0.3), width: 1),
        ),
        title: Text(
          '确认删除',
          style: TextStyle(
            color: colors.error,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '请输入 "DELETE" 以确认删除账户',
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              style: TextStyle(color: colors.text, fontSize: 14),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
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
              if (confirmController.text.toUpperCase() == 'DELETE') {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close settings page
                // Navigate to login
                Navigator.pushReplacementNamed(context, '/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('账户已删除'),
                    backgroundColor: colors.error,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('请输入 DELETE 以确认'),
                    backgroundColor: colors.error,
                  ),
                );
              }
            },
            child: Text(
              '确认删除',
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
}
