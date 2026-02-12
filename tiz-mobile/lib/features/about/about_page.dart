import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';

/// About Page
/// Accessible from Settings → About
/// App version: "1.0.0"
/// App description
/// Links: Terms of Service, Privacy Policy
/// Developer info
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String appVersion = '1.0.0';

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
          '关于',
          style: TextStyle(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          children: [
            // App Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  border: Border.all(color: colors.border, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: colors.text,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Tiz',
              style: TextStyle(
                color: colors.text,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // App Version
            Text(
              '版本 $appVersion',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关于 Tiz',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tiz 是一款智能语言学习应用，结合 AI 技术为您提供个性化的学习体验。'
                    '通过智能翻译、互动测验和 Bot，让语言学习变得更加简单高效。',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Features
            _buildFeatureItem(
              colors,
              Icons.translate_rounded,
              '智能翻译',
              '支持多种语言的实时翻译，准确理解语境',
            ),
            _buildFeatureItem(
              colors,
              Icons.quiz_rounded,
              '互动测验',
              '个性化的测验系统，帮助巩固学习成果',
            ),
            _buildFeatureItem(
              colors,
              Icons.psychology_rounded,
              'Bot',
              '智能问答，随时解答学习疑问',
            ),
            const SizedBox(height: 24),

            // Links
            _buildLinkItem(
              colors,
              Icons.description_outlined,
              '服务条款',
              () => _launchUrl('https://tiz.app/terms'),
            ),
            _buildLinkItem(
              colors,
              Icons.privacy_tip_outlined,
              '隐私政策',
              () => _launchUrl('https://tiz.app/privacy'),
            ),
            const SizedBox(height: 32),

            // Developer Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '开发者',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tiz Team',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'contact@tiz.app',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Copyright
            Text(
              '© 2026 Tiz. 保留所有权利。',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeColors colors,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colors.text,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    ThemeColors colors,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: colors.text,
              size: 20,
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
            Icon(
              Icons.open_in_new_rounded,
              color: colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle error silently or show a message
    }
  }
}
