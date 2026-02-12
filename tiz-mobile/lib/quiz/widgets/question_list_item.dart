/// Question List Item Widget
/// Displays a single question in the question bank list

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/quiz/models.dart';
import '../models/quiz_status.dart';
import 'difficulty_badge.dart';
import 'status_badge.dart';

/// List item for question bank
class QuestionListItem extends StatelessWidget {
  final QuizQuestion question;
  final QuestionStatus status;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;

  const QuestionListItem({
    super.key,
    required this.question,
    required this.status,
    required this.onTap,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: _getStatusColor(colors),
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            StatusIndicator(
              status: status,
              size: 28,
            ),

            const SizedBox(width: 12),

            // Question content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top row: ID and difficulty
                  Row(
                    children: [
                      Text(
                        question.id.toUpperCase(),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DifficultyBadge(
                        difficulty: question.difficulty,
                        showLabel: true,
                      ),
                      const Spacer(),
                      // Tags (optional)
                      if (question.tags != null && question.tags!.isNotEmpty)
                        Text(
                          _getPrimaryTag(),
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Question text
                  Text(
                    question.question,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeColors colors) {
    switch (status) {
      case QuestionStatus.notAttempted:
        return colors.border;
      case QuestionStatus.correct:
        return colors.accent;
      case QuestionStatus.wrong:
        return colors.error;
      case QuestionStatus.skipped:
        return colors.textSecondary.withOpacity(0.5);
    }
  }

  String _getPrimaryTag() {
    if (question.tags == null || question.tags!.isEmpty) return '';
    final tags = question.tags!.split(',');
    return '#${tags.first.trim()}';
  }
}
