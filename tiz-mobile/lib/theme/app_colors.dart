import 'package:flutter/material.dart';

/// Minimalist App Color System
/// Defines colors following Tiz minimalist design principles
class AppColors {
  // Light Theme Colors
  static const Color _lightBg = Color(0xFFFFFFFF);
  static const Color _lightBgSecondary = Color(0xFFF9FAFB);
  static const Color _lightText = Color(0xFF111827);
  static const Color _lightTextSecondary = Color(0xFF6B7280);
  static const Color _lightTextTertiary = Color(0xFF9CA3AF);
  static const Color _lightBorder = Color(0xFFE5E7EB);
  static const Color _lightAccent = Color(0xFF111827);

  // Dark Theme Colors
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _darkBgSecondary = Color(0xFF141414);
  static const Color _darkText = Color(0xFFFAFAFA);
  static const Color _darkTextSecondary = Color(0xFFA1A1AA);
  static const Color _darkTextTertiary = Color(0xFF71717A);
  static const Color _darkBorder = Color(0xFF262626);
  static const Color _darkAccent = Color(0xFFFAFAFA);

  // AI Feature Colors (subtle purple accent, used sparingly)
  static const Color aiPrimary = Color(0xFF6366F1);
  static const Color aiSecondary = Color(0xFFA855F7);

  // Notification Colors
  static const Color notificationBadge = Color(0xFF111827);
  static const Color notificationUnreadBg = Color(0xFFF3F4F6);
  static const Color notificationUnreadDot = Color(0xFF6366F1);

  // AI Badge Colors
  static const Color aiBadgeBackground = Color(0xFFF3F4F6);
  static const Color aiBadgeText = Color(0xFF6366F1);
}

/// Minimalist Theme Color Data
class ThemeColors {
  final Color bg;
  final Color bgSecondary;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color textPrimary;
  final Color border;
  final Color borderLight;
  final Color accent;
  final Color surface;
  final Color glassBorder;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color glassBg;
  final Color error;

  const ThemeColors({
    required this.bg,
    required this.bgSecondary,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.textPrimary,
    required this.border,
    required this.borderLight,
    required this.accent,
    required this.surface,
    required this.glassBorder,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.glassBg,
    required this.error,
  });

  /// Light theme
  factory ThemeColors.light() {
    return const ThemeColors(
      bg: AppColors._lightBg,
      bgSecondary: AppColors._lightBgSecondary,
      text: AppColors._lightText,
      textSecondary: AppColors._lightTextSecondary,
      textTertiary: AppColors._lightTextTertiary,
      textPrimary: AppColors._lightText,
      border: AppColors._lightBorder,
      borderLight: Color(0xFFF3F4F6),
      accent: AppColors._lightAccent,
      surface: AppColors._lightBg,
      glassBorder: AppColors._lightBorder,
      primary: AppColors._lightAccent,
      secondary: AppColors.aiPrimary,
      background: AppColors._lightBg,
      glassBg: AppColors._lightBg,
      error: Color(0xFFEF4444),
    );
  }

  /// Dark theme
  factory ThemeColors.dark() {
    return const ThemeColors(
      bg: AppColors._darkBg,
      bgSecondary: AppColors._darkBgSecondary,
      text: AppColors._darkText,
      textSecondary: AppColors._darkTextSecondary,
      textTertiary: AppColors._darkTextTertiary,
      textPrimary: AppColors._darkText,
      border: AppColors._darkBorder,
      borderLight: Color(0xFF1A1A1A),
      accent: AppColors._darkAccent,
      surface: AppColors._darkBgSecondary,
      glassBorder: AppColors._darkBorder,
      primary: AppColors._darkAccent,
      secondary: AppColors.aiPrimary,
      background: AppColors._darkBg,
      glassBg: AppColors._darkBgSecondary,
      error: Color(0xFFEF4444),
    );
  }
}

/// App Theme Type Enum - Minimalist (Light/Dark only)
enum AppTheme {
  light,
  dark,
}

extension AppThemeExtension on AppTheme {
  String get displayName {
    switch (this) {
      case AppTheme.light:
        return '浅色';
      case AppTheme.dark:
        return '深色';
    }
  }

  String get description {
    switch (this) {
      case AppTheme.light:
        return '纯净极简';
      case AppTheme.dark:
        return '纯黑极简';
    }
  }

  ThemeColors get colors {
    switch (this) {
      case AppTheme.light:
        return ThemeColors.light();
      case AppTheme.dark:
        return ThemeColors.dark();
    }
  }

  Brightness get brightness {
    switch (this) {
      case AppTheme.light:
        return Brightness.light;
      case AppTheme.dark:
        return Brightness.dark;
    }
  }
}
