import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Decoration Styles
/// Provides glassmorphism, shadows, and border styles
class AppDecorations {
  /// Glassmorphism decoration
  static BoxDecoration glassMorphism({
    required ThemeColors colors,
    double blur = 20,
    double opacity = 0.8,
  }) {
    return BoxDecoration(
      color: colors.glassBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colors.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.background.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Card decoration
  static BoxDecoration cardDecoration({
    required ThemeColors colors,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colors.glassBorder,
        width: 1,
      ),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: colors.textSecondary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  /// Input decoration for text fields
  static InputDecoration inputDecoration({
    required ThemeColors colors,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colors.textSecondary,
        fontSize: 15,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
    );
  }

  /// AI Badge decoration
  static BoxDecoration aiBadgeDecoration({
    required ThemeColors colors,
  }) {
    return BoxDecoration(
      color: AppColors.aiBadgeBackground,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: AppColors.aiBadgeText.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  /// Notification badge decoration
  static BoxDecoration notificationBadgeDecoration() {
    return BoxDecoration(
      color: AppColors.notificationBadge,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.notificationBadge.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Notification item decoration (unread)
  static BoxDecoration notificationItemDecoration({
    required ThemeColors colors,
    bool isRead = false,
  }) {
    return BoxDecoration(
      color: isRead ? colors.surface : AppColors.notificationUnreadBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: colors.glassBorder,
        width: 1,
      ),
    );
  }

  /// Chat bubble decoration (user)
  static BoxDecoration chatBubbleUserDecoration({
    required ThemeColors colors,
  }) {
    return BoxDecoration(
      color: colors.primary,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      ),
      boxShadow: [
        BoxShadow(
          color: colors.primary.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Chat bubble decoration (AI)
  static BoxDecoration chatBubbleAIDecoration({
    required ThemeColors colors,
  }) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(16),
      ),
      border: Border.all(
        color: colors.glassBorder,
        width: 1,
      ),
    );
  }

  /// Bottom navigation bar decoration
  static BoxDecoration bottomNavDecoration({
    required ThemeColors colors,
  }) {
    return BoxDecoration(
      color: colors.surface,
      border: Border(
        top: BorderSide(
          color: colors.glassBorder,
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: colors.textPrimary.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  /// Floating action button decoration
  static BoxDecoration fabDecoration({
    required ThemeColors colors,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.primary,
          colors.secondary,
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colors.primary.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Theme card decoration for theme selector
  static BoxDecoration themeCardDecoration({
    required AppTheme theme,
    bool isSelected = false,
  }) {
    final colors = theme.colors;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.background,
          colors.surface,
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected ? colors.primary : colors.glassBorder,
        width: isSelected ? 2 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: colors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  /// Shimmer loading decoration
  static BoxDecoration shimmerDecoration({
    required ThemeColors colors,
  }) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: colors.glassBorder,
        width: 1,
      ),
    );
  }
}

/// Shadow Styles
class AppShadows {
  static List<BoxShadow> shadowSmall({
    required ThemeColors colors,
  }) {
    return [
      BoxShadow(
        color: colors.textPrimary.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> shadowMedium({
    required ThemeColors colors,
  }) {
    return [
      BoxShadow(
        color: colors.textPrimary.withOpacity(0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> shadowLarge({
    required ThemeColors colors,
  }) {
    return [
      BoxShadow(
        color: colors.textPrimary.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: colors.textPrimary.withOpacity(0.05),
        blurRadius: 40,
        offset: const Offset(0, 16),
      ),
    ];
  }

  /// Colored shadow for primary color
  static List<BoxShadow> primaryShadow({
    required ThemeColors colors,
  }) {
    return [
      BoxShadow(
        color: colors.primary.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ];
  }
}

/// Border Radius Constants
class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 20.0;
  static const double circle = 999.0;

  static BorderRadius borderRadiusSmall = BorderRadius.circular(small);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(medium);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(large);
  static BorderRadius borderRadiusXLarge = BorderRadius.circular(xLarge);
  static BorderRadius borderRadiusCircle = BorderRadius.circular(circle);
}
