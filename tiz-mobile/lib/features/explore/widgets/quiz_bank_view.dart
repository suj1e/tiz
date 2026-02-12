import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/language_selector.dart';
import '../../quiz/models.dart';
import 'quiz_practice_page.dart';

/// Question Bank View - Tech-minimalist design (LeetCode/Codeforces style)
/// Compact rows, monospace fonts, status dots, thin progress lines
class QuizBankView extends StatefulWidget {
  final QuizCategory initialCategory;

  const QuizBankView({super.key, this.initialCategory = QuizCategory.english});

  @override
  State<QuizBankView> createState() => _QuizBankViewState();
}

class _QuizBankViewState extends State<QuizBankView> {
  late QuizCategory _selectedCategory;
  QuestionStatusFilter _statusFilter = QuestionStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(QuizBankView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      children: [
        // Filter chips - compact horizontal
        _buildFilters(colors),

        // Question list - data-dense
        Expanded(
          child: _buildQuestionList(colors),
        ),
      ],
    );
  }

  Widget _buildFilters(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: QuestionStatusFilter.values.map((filter) {
            final isSelected = _statusFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TechFilterChip(
                label: filter.label,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _statusFilter = filter;
                  });
                },
                colors: colors,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuestionList(ThemeColors colors) {
    final questions = mockQuestions[_selectedCategory] ?? [];
    final filteredQuestions = _filterQuestions(questions);

    if (filteredQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              '暂无题目',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: filteredQuestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final question = filteredQuestions[index];
        return _TechQuestionCard(
          question: question,
          index: index,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizPracticePage(
                  questions: filteredQuestions,
                  startIndex: index,
                ),
              ),
            );
          },
          colors: colors,
        );
      },
    );
  }

  List<QuizQuestion> _filterQuestions(List<QuizQuestion> questions) {
    switch (_statusFilter) {
      case QuestionStatusFilter.all:
        return questions;
      case QuestionStatusFilter.beginner:
        return questions.where((q) => q.difficulty == QuizDifficulty.beginner).toList();
      case QuestionStatusFilter.intermediate:
        return questions.where((q) => q.difficulty == QuizDifficulty.intermediate).toList();
      case QuestionStatusFilter.advanced:
        return questions.where((q) => q.difficulty == QuizDifficulty.advanced).toList();
    }
  }
}

/// Question status filter
enum QuestionStatusFilter {
  all,
  beginner,
  intermediate,
  advanced,
}

extension QuestionStatusFilterExtension on QuestionStatusFilter {
  String get label {
    switch (this) {
      case QuestionStatusFilter.all:
        return '全部';
      case QuestionStatusFilter.beginner:
        return '简单';
      case QuestionStatusFilter.intermediate:
        return '中等';
      case QuestionStatusFilter.advanced:
        return '困难';
    }
  }
}

/// Tech-minimalist filter chip
class _TechFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  const _TechFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.text : colors.bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? colors.text : colors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.bg : colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'JetBrains Mono',
          ),
        ),
      ),
    );
  }
}

/// Tech-minimalist question card
class _TechQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int index;
  final VoidCallback onTap;
  final ThemeColors colors;

  const _TechQuestionCard({
    required this.question,
    required this.index,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border.all(
            color: colors.borderLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Status dot
            _buildStatusDot(),

            const SizedBox(width: 10),

            // Question number - monospace
            Text(
              '${index + 1}.',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(width: 8),

            // Question text
            Expanded(
              child: Text(
                question.question,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'JetBrains Mono',
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            // Difficulty indicator
            _buildDifficultyIndicator(),

            const SizedBox(width: 4),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot() {
    // Mock status - in real app, this would come from user progress
    final statuses = [QuizStatus.solved, QuizStatus.attempted, QuizStatus.unsolved];
    final status = statuses[index % statuses.length];

    Color color;
    switch (status) {
      case QuizStatus.solved:
        color = const Color(0xFF059669);
        break;
      case QuizStatus.attempted:
        color = const Color(0xFFD97706);
        break;
      case QuizStatus.unsolved:
      default:
        color = const Color(0xFF9CA3AF);
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDifficultyIndicator() {
    String label;
    Color color;

    switch (question.difficulty) {
      case QuizDifficulty.beginner:
        label = 'E';
        color = const Color(0xFF059669);
        break;
      case QuizDifficulty.intermediate:
        label = 'M';
        color = const Color(0xFFF59E0B);
        break;
      case QuizDifficulty.advanced:
        label = 'H';
        color = const Color(0xFFEF4444);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }
}

/// Quiz status enum
enum QuizStatus {
  solved,
  attempted,
  unsolved,
}
