/// Difficulty Badge Widget
/// Shows difficulty level with appropriate styling

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/quiz/models.dart';

/// Difficulty indicator badge
class DifficultyBadge extends StatelessWidget {
  final QuizDifficulty difficulty;
  final bool showLabel;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            size: 10,
            color: colors.textSecondary,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getLabel(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLabel() {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return '初级';
      case QuizDifficulty.intermediate:
        return '中级';
      case QuizDifficulty.advanced:
        return '高级';
    }
  }

  IconData _getIcon() {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return Icons.looks_one;
      case QuizDifficulty.intermediate:
        return Icons.looks_two;
      case QuizDifficulty.advanced:
        return Icons.looks_3;
    }
  }

  Color _getBackgroundColor(ThemeColors colors) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return colors.bg;
      case QuizDifficulty.intermediate:
        return colors.bg;
      case QuizDifficulty.advanced:
        return colors.bg;
    }
  }

  Color _getBorderColor(ThemeColors colors) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return colors.borderLight;
      case QuizDifficulty.intermediate:
        return colors.border;
      case QuizDifficulty.advanced:
        return colors.textSecondary.withOpacity(0.3);
    }
  }
}
