/// Status Badge Widget
/// Shows question attempt status

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../models/quiz_status.dart';

/// Status indicator badge
class StatusBadge extends StatelessWidget {
  final QuestionStatus status;
  final bool showLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(colors),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getBorderColor(colors),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 12,
            color: _getTextColor(colors),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              status.label,
              style: TextStyle(
                color: _getTextColor(colors),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    return status.materialIcon;
  }

  Color _getBackgroundColor(ThemeColors colors) {
    switch (status) {
      case QuestionStatus.notAttempted:
        return colors.bg;
      case QuestionStatus.correct:
        return colors.accent;
      case QuestionStatus.wrong:
        return colors.error;
      case QuestionStatus.skipped:
        return colors.bgSecondary;
    }
  }

  Color _getBorderColor(ThemeColors colors) {
    switch (status) {
      case QuestionStatus.notAttempted:
        return colors.border;
      case QuestionStatus.correct:
        return colors.accent;
      case QuestionStatus.wrong:
        return colors.error;
      case QuestionStatus.skipped:
        return colors.border;
    }
  }

  Color _getTextColor(ThemeColors colors) {
    switch (status) {
      case QuestionStatus.notAttempted:
        return colors.textTertiary;
      case QuestionStatus.correct:
        return colors.bg;
      case QuestionStatus.wrong:
        return colors.bg;
      case QuestionStatus.skipped:
        return colors.textSecondary;
    }
  }
}

/// Compact status indicator (circle only)
class StatusIndicator extends StatelessWidget {
  final QuestionStatus status;
  final double size;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    Color backgroundColor;
    Color iconColor;

    switch (status) {
      case QuestionStatus.notAttempted:
        backgroundColor = colors.bgSecondary;
        iconColor = colors.textTertiary;
        break;
      case QuestionStatus.correct:
        backgroundColor = colors.accent;
        iconColor = colors.bg;
        break;
      case QuestionStatus.wrong:
        backgroundColor = colors.error;
        iconColor = colors.bg;
        break;
      case QuestionStatus.skipped:
        backgroundColor = colors.bgSecondary;
        iconColor = colors.textSecondary;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: _getBorderColor(colors),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          _getIcon(),
          size: size * 0.5,
          color: iconColor,
        ),
      ),
    );
  }

  IconData _getIcon() {
    return status.materialIcon;
  }

  Color _getBorderColor(ThemeColors colors) {
    switch (status) {
      case QuestionStatus.notAttempted:
        return colors.border;
      case QuestionStatus.correct:
        return colors.accent;
      case QuestionStatus.wrong:
        return colors.error;
      case QuestionStatus.skipped:
        return colors.border;
    }
  }
}
