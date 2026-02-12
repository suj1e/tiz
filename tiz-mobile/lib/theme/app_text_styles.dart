import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Text Styles
/// Typography system following iOS 26 design guidelines
class AppTextStyles {
  // Display Styles - For large, expressive text
  static TextStyle displayLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.displayLarge?.copyWith(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
        ) ??
        TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle displayMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.displayMedium?.copyWith(
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle displaySmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.displaySmall?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );
  }

  // Headline Styles - For section headers and titles
  static TextStyle headlineLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle headlineMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle headlineSmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  // Title Styles - For list items, cards, and dialogs
  static TextStyle titleLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle titleMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ) ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle titleSmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: theme.colorScheme.onSurface,
        );
  }

  // Body Styles - For primary content
  static TextStyle bodyLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ) ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle bodyMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle bodySmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
        ) ??
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          color: theme.colorScheme.onSurfaceVariant,
        );
  }

  // Label Styles - For buttons, tabs, and labels
  static TextStyle labelLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: theme.colorScheme.primary,
        );
  }

  static TextStyle labelMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ) ??
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: theme.colorScheme.onSurface,
        );
  }

  static TextStyle labelSmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ) ??
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: theme.colorScheme.onSurfaceVariant,
        );
  }

  // Custom Styles for Specific Use Cases
  static TextStyle aiBadge(BuildContext context) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.aiBadgeText,
      letterSpacing: 0.5,
    );
  }

  static TextStyle chatUser(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle chatAI(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle notificationTitle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle notificationBody(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle notificationTime(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
    );
  }
}

/// Text Style Extensions for easy access
extension TextStyleExtensions on BuildContext {
  // Display
  TextStyle get displayLarge => AppTextStyles.displayLarge(this);
  TextStyle get displayMedium => AppTextStyles.displayMedium(this);
  TextStyle get displaySmall => AppTextStyles.displaySmall(this);

  // Headline
  TextStyle get headlineLarge => AppTextStyles.headlineLarge(this);
  TextStyle get headlineMedium => AppTextStyles.headlineMedium(this);
  TextStyle get headlineSmall => AppTextStyles.headlineSmall(this);

  // Title
  TextStyle get titleLarge => AppTextStyles.titleLarge(this);
  TextStyle get titleMedium => AppTextStyles.titleMedium(this);
  TextStyle get titleSmall => AppTextStyles.titleSmall(this);

  // Body
  TextStyle get bodyLarge => AppTextStyles.bodyLarge(this);
  TextStyle get bodyMedium => AppTextStyles.bodyMedium(this);
  TextStyle get bodySmall => AppTextStyles.bodySmall(this);

  // Label
  TextStyle get labelLarge => AppTextStyles.labelLarge(this);
  TextStyle get labelMedium => AppTextStyles.labelMedium(this);
  TextStyle get labelSmall => AppTextStyles.labelSmall(this);
}
