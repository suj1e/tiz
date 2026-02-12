/// Quiz Bank Page
/// Main question bank interface - LeetCode style

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/quiz/models.dart';
import '../models/quiz_status.dart';
import '../models/quiz_progress.dart';
import '../providers/quiz_bank_provider.dart';
import '../providers/quiz_progress_provider.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/status_badge.dart';
import '../widgets/question_list_item.dart';
import '../widgets/filter_chip.dart' as quiz_widgets;
import '../widgets/progress_dots.dart';
import 'quiz_practice_page.dart';

/// Question bank page - displays all questions with filters
class QuizBankPage extends StatefulWidget {
  final QuizCategory? initialCategory;

  const QuizBankPage({
    super.key,
    this.initialCategory,
  });

  @override
  State<QuizBankPage> createState() => _QuizBankPageState();
}

class _QuizBankPageState extends State<QuizBankPage> {
  @override
  void initState() {
    super.initState();
    // Set initial category if provided
    if (widget.initialCategory != null) {
      Future.microtask(() {
        context
            .read<QuizBankProvider>()
            .setCategory(widget.initialCategory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '题库',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Settings button
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colors.text),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<QuizBankProvider>(
        builder: (context, bankProvider, child) {
          return Column(
            children: [
              // Category selector
              _buildCategorySelector(colors, bankProvider),

              const SizedBox(height: 12),

              // Stats cards
              _buildStatsCards(colors, bankProvider),

              const SizedBox(height: 16),

              // Status filter chips
              _buildStatusFilter(colors, bankProvider),

              const SizedBox(height: 16),

              // Question list
              Expanded(
                child: _buildQuestionList(colors, bankProvider),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildCategorySelector(
    ThemeColors colors,
    QuizBankProvider bankProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip(
              colors: colors,
              label: '全部',
              emoji: '📚',
              isSelected: bankProvider.selectedCategory == null,
              onTap: () => bankProvider.setCategory(null),
            ),
            const SizedBox(width: 12),
            ...QuizCategory.values.map((category) {
              final isSelected = bankProvider.selectedCategory == category.name;
              final stats = bankProvider.getCategoryStats()[category] ??
                  CategoryStats(
                    category: category,
                    total: 0,
                    attempted: 0,
                    correct: 0,
                  );
              return _buildCategoryChip(
                colors: colors,
                label: stats.categoryLabel,
                emoji: _getCategoryEmoji(category),
                isSelected: isSelected,
                onTap: () => bankProvider.setCategory(category),
                stats: stats,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required ThemeColors colors,
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
    CategoryStats? stats,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.bgSecondary : colors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.text : colors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (stats != null) ...[
              const SizedBox(width: 8),
              Text(
                '${stats.attempted}/${stats.total}',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(QuizCategory category) {
    switch (category) {
      case QuizCategory.english:
        return '🇬🇧';
      case QuizCategory.japanese:
        return '🇯🇵';
      case QuizCategory.german:
        return '🇩🇪';
    }
  }

  Widget _buildStatsCards(
    ThemeColors colors,
    QuizBankProvider bankProvider,
  ) {
    final progressProvider = context.read<QuizProgressProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Overall progress
          Expanded(
            child: _buildStatCard(
              colors: colors,
              title: '总进度',
              value: '${bankProvider.attemptedQuestionCount}/${bankProvider.totalQuestionCount}',
              subtitle: '正确率: ${progressProvider.getAllCategoryStats().values.isEmpty ? 0 : (progressProvider.getAllCategoryStats().values.map((s) => s.accuracy).reduce((a, b) => a + b) / progressProvider.getAllCategoryStats().values.length * 100).toInt()}%',
            ),
          ),
          const SizedBox(width: 12),
          // XP and streak
          Expanded(
            child: _buildStatCard(
              colors: colors,
              title: '今日',
              value: '${progressProvider.dailyXP}/100',
              subtitle: 'XP',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required ThemeColors colors,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(
    ThemeColors colors,
    QuizBankProvider bankProvider,
  ) {
    // Count questions by status
    final allQuestions = bankProvider.filteredQuestions;
    final statusCounts = <QuestionStatus, int>{
      QuestionStatus.notAttempted: 0,
      QuestionStatus.correct: 0,
      QuestionStatus.wrong: 0,
    };

    for (final question in allQuestions) {
      final status = bankProvider.getQuestionStatus(question.id);
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    final selectedStatus = bankProvider.filter.status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              colors: colors,
              label: '全部',
              isSelected: selectedStatus == null,
              count: allQuestions.length,
              onTap: () => bankProvider.setStatus(null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              colors: colors,
              label: '未做',
              isSelected: selectedStatus == QuestionStatus.notAttempted,
              count: statusCounts[QuestionStatus.notAttempted],
              onTap: () => bankProvider.setStatus(QuestionStatus.notAttempted),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              colors: colors,
              label: '正确',
              isSelected: selectedStatus == QuestionStatus.correct,
              count: statusCounts[QuestionStatus.correct],
              onTap: () => bankProvider.setStatus(QuestionStatus.correct),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              colors: colors,
              label: '错误',
              isSelected: selectedStatus == QuestionStatus.wrong,
              count: statusCounts[QuestionStatus.wrong],
              onTap: () => bankProvider.setStatus(QuestionStatus.wrong),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeColors colors,
    required String label,
    required bool isSelected,
    required int? count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                '($count)',
                style: TextStyle(
                  color: isSelected ? colors.bg.withOpacity(0.7) : colors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(
    ThemeColors colors,
    QuizBankProvider bankProvider,
  ) {
    if (bankProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.accent),
      );
    }

    final questions = bankProvider.filteredQuestions;

    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 48,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到题目',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: questions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final question = questions[index];
        final status = bankProvider.getQuestionStatus(question.id);
        return QuestionListItem(
          question: question,
          status: status,
          onTap: () => _navigateToQuestion(context, question),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final bankProvider = context.read<QuizBankProvider>();

    // Determine which category to use
    final category = bankProvider.filter.category ?? QuizCategory.english;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(
          top: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Practice mode button
            Expanded(
              child: OutlinedButton(
                onPressed: () => _startPractice(context, category),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.border, width: 1),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shuffle_rounded, size: 18, color: colors.text),
                    const SizedBox(width: 8),
                    const Text('随机练习', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Start practice button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _startPractice(context, category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.bg,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('开始练习', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Icon(Icons.play_arrow_rounded,
                        size: 20, color: colors.bg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuestion(BuildContext context, QuizQuestion question) {
    // TODO: Navigate to question detail page
    // For now, just start practice at this question
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPracticePage(
          category: question.category,
          startQuestionId: question.id,
        ),
      ),
    );
  }

  void _startPractice(BuildContext context, QuizCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPracticePage(
          category: category,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;
    final bankProvider = context.read<QuizBankProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '筛选选项',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '难度',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: QuizDifficulty.values.map((difficulty) {
                final isSelected = bankProvider.filter.difficulty == difficulty;
                return quiz_widgets.FilterChip(
                  label: _getDifficultyLabel(difficulty),
                  isSelected: isSelected,
                  onTap: () {
                    bankProvider.setDifficulty(
                      isSelected ? null : difficulty,
                    );
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              bankProvider.clearFilters();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.textSecondary,
            ),
            child: const Text('清除筛选'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colors.text,
            ),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return '初级';
      case QuizDifficulty.intermediate:
        return '中级';
      case QuizDifficulty.advanced:
        return '高级';
    }
  }
}
