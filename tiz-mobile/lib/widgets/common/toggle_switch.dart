import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';

/// Toggle Switch Widget
/// Custom toggle switch with iOS-style animation
class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;

  const ToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    Widget switchWidget = GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? colors.accent : colors.border,
          borderRadius: BorderRadius.circular(12),
          border: value
              ? null
              : Border.all(
                  color: colors.border,
                  width: 1,
                ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colors.bg,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );

    if (label != null || description != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          switchWidget,
        ],
      );
    }

    return switchWidget;
  }
}

/// Setting Item with Toggle
/// List tile style setting item with toggle switch
class SettingToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showAI;

  const SettingToggleItem({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
    this.showAI = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: showAI
                ? AppColors.aiBadgeBackground
                : colors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: showAI ? AppColors.aiBadgeText : colors.accent,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showAI) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.aiBadgeBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: AppColors.aiBadgeText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: description != null
            ? Text(
                description!,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: ToggleSwitch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// Setting Item with Navigation Arrow
/// List tile style setting item that navigates to another page
class SettingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showAI;

  const SettingNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showAI = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: showAI
                  ? AppColors.aiBadgeBackground
                  : colors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: showAI ? AppColors.aiBadgeText : colors.accent,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showAI) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.aiBadgeBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AI',
                    style: TextStyle(
                      color: AppColors.aiBadgeText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
