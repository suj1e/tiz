import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_decorations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_colors.dart';

/// Theme Selector Widget
/// Displays all available themes with preview and selection
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: AppTheme.values.map((theme) {
            final isSelected = themeProvider.currentThemeType == theme;
            final colors = theme.colors;

            return GestureDetector(
              onTap: () => themeProvider.setTheme(theme),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
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
                      ? AppShadows.primaryShadow(colors: colors)
                      : null,
                ),
                child: Row(
                  children: [
                    // Theme Preview
                    _ThemePreview(colors: colors),
                    const SizedBox(width: 16),
                    // Theme Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                theme.displayName,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '当前',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.description,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Selected Indicator
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: colors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Theme Preview Widget
/// Shows a mini preview of the theme colors
class _ThemePreview extends StatelessWidget {
  final ThemeColors colors;

  const _ThemePreview({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Stack(
        children: [
          // Primary color block
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Secondary color block
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Surface color block
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.glassBorder),
              ),
            ),
          ),
          // Text color block
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.textPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme Quick Selector Widget
/// Compact horizontal theme selector for inline use
class ThemeQuickSelector extends StatelessWidget {
  final ValueChanged<AppTheme>? onThemeChanged;

  const ThemeQuickSelector({
    super.key,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: AppTheme.values.map((theme) {
              final isSelected = themeProvider.currentThemeType == theme;
              final colors = theme.colors;

              return GestureDetector(
                onTap: () {
                  themeProvider.setTheme(theme);
                  onThemeChanged?.call(theme);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mini preview
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colors.primary, colors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Name
                      Text(
                        theme.displayName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Theme Color Swatch
/// Shows a color from the theme palette
class ThemeColorSwatch extends StatelessWidget {
  final Color color;
  final String? label;
  final VoidCallback? onTap;

  const ThemeColorSwatch({
    super.key,
    required this.color,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: label ?? '',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme Preview Card
/// Larger preview card showing theme elements
class ThemePreviewCard extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback? onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
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
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Card preview
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Button preview
            Container(
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.secondary],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
