/// Filter Chip Widget
/// Used for filtering questions by status, difficulty, etc.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../models/quiz_status.dart';

/// Filter selection chip
class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;
  final bool isDense;

  const FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;

    final padding = isDense
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.bg : colors.textSecondary,
                fontSize: isDense ? 12 : 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.bg.withOpacity(0.2)
                      : colors.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? colors.bg : colors.textSecondary,
                    fontSize: isDense ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Category chip with icon
class CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.bgSecondary : colors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.text : colors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status filter chips row
class StatusFilterChips extends StatelessWidget {
  final QuestionStatus selectedStatus;
  final Function(QuestionStatus?) onStatusSelected;
  final Map<QuestionStatus, int> counts;

  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip(
          label: '全部',
          isSelected: selectedStatus == null,
          onTap: () => onStatusSelected(null),
          count: null,
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: '未做',
          isSelected: selectedStatus == QuestionStatus.notAttempted,
          onTap: () => onStatusSelected(QuestionStatus.notAttempted),
          count: counts[QuestionStatus.notAttempted],
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: '正确',
          isSelected: selectedStatus == QuestionStatus.correct,
          onTap: () => onStatusSelected(QuestionStatus.correct),
          count: counts[QuestionStatus.correct],
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: '错误',
          isSelected: selectedStatus == QuestionStatus.wrong,
          onTap: () => onStatusSelected(QuestionStatus.wrong),
          count: counts[QuestionStatus.wrong],
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    return FilterChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      isDense: true,
    );
  }
}
