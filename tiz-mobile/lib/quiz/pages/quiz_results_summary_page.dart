/// Quiz Results Summary Page
/// Shows practice session results with detailed breakdown

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/quiz/models.dart';
import '../providers/quiz_practice_provider.dart';
import '../widgets/progress_dots.dart';
import 'quiz_bank_page.dart';

/// Results summary page for practice mode
class QuizResultsSummaryPage extends StatefulWidget {
  final PracticeResult result;
  final QuizCategory category;

  const QuizResultsSummaryPage({
    super.key,
    required this.result,
    required this.category,
  });

  @override
  State<QuizResultsSummaryPage> createState() =>
      _QuizResultsSummaryPageState();
}

class _QuizResultsSummaryPageState
    extends State<QuizResultsSummaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          '练习结果',
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Card
              _buildScoreCard(colors),

              const SizedBox(height: 20),

              // XP Reward
              _buildXPRewardCard(colors),

              const SizedBox(height: 20),

              // Stats breakdown
              _buildStatsBreakdown(colors),

              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(ThemeColors colors) {
    final percentage = widget.result.percentage;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Pass/Fail Badge
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.result.passed
                          ? colors.accent
                          : colors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.result.passed
                              ? Icons.emoji_events_rounded
                              : Icons.pending_rounded,
                          color: colors.bg,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.result.passed ? '通过' : '未通过',
                          style: TextStyle(
                            color: colors.bg,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Score Display
            TweenAnimationBuilder<double>(
              tween: Tween(
                  begin: 0.0, end: widget.result.correctCount.toDouble()),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Text(
                  '${value.toInt()}/${widget.result.totalQuestions}',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    height: 1,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Percentage
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: widget.result.passed ? colors.accent : colors.error,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // Count breakdown
            Text(
              '正确 ${widget.result.correctCount} · 错误 ${widget.result.wrongCount}',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 13,
              ),
            ),

            // Time elapsed
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.result.formattedTime,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPRewardCard(ThemeColors colors) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stars_rounded,
              size: 28,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: 12),
            Text(
              '+${widget.result.earnedXP}',
              style: TextStyle(
                color: colors.text,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'XP',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBreakdown(ThemeColors colors) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '答题统计',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  colors: colors,
                  label: '正确率',
                  value: '${widget.result.accuracyPercentage}%',
                  icon: Icons.check_circle,
                  iconColor: colors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  colors: colors,
                  label: '用时',
                  value: widget.result.formattedTime,
                  icon: Icons.access_time,
                  iconColor: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required ThemeColors colors,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeColors colors) {
    return Column(
      children: [
        // Try Wrong Answers Button (if there are wrong answers)
        if (widget.result.correctCount < widget.result.totalQuestions) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showRetryWrongDialog();
              },
              icon: Icon(Icons.refresh_rounded, size: 18, color: colors.text),
              label: const Text('重做错题'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                side: BorderSide(color: colors.border, width: 1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Practice Again Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => QuizBankPage(
                    initialCategory: widget.category,
                  ),
                ),
              );
            },
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
            child: const Text('继续练习',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),

        const SizedBox(height: 10),

        // Back to Bank Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => QuizBankPage(
                    initialCategory: widget.category,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('返回题库'),
          ),
        ),
      ],
    );
  }

  void _showRetryWrongDialog() {
    final colors = context.read<ThemeProvider>().colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '重做错题',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '此功能即将推出，将为您生成包含错误题目的新测验',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colors.text,
            ),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
