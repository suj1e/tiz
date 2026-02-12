import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';
import 'models.dart';

/// Quiz Results Page
/// Displays final score and question breakdown
class QuizResultsPage extends StatefulWidget {
  final QuizSession session;

  const QuizResultsPage({
    super.key,
    required this.session,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
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
          '测验结果',
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Card
              _buildScoreCard(colors),

              const SizedBox(height: 20),

              // Questions List
              Text(
                '题目详情',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _buildQuestionsList(colors),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(ThemeColors colors) {
    final percentage = widget.session.percentage;
    final passed = widget.session.passed;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Pass/Fail Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: passed ? colors.accent : colors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              passed ? '通过' : '未通过',
              style: TextStyle(
                color: colors.bg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Score Display
          Text(
            '${widget.session.score}/${widget.session.questions.length}',
            style: TextStyle(
              color: colors.text,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 8),

          // Percentage
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // Correct/Incorrect Count
          Text(
            '正确 ${widget.session.score} · 错误 ${widget.session.questions.length - widget.session.score}',
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(ThemeColors colors) {
    return ListView.builder(
      itemCount: widget.session.questions.length,
      itemBuilder: (context, index) {
        final question = widget.session.questions[index];
        final userAnswer = widget.session.userAnswers[index];
        final isCorrect = userAnswer == question.correctAnswer;
        final wasAnswered = userAnswer != null;

        return _buildQuestionItem(
          question,
          index + 1,
          isCorrect,
          wasAnswered,
          colors,
        );
      },
    );
  }

  Widget _buildQuestionItem(
    QuizQuestion question,
    int questionNumber,
    bool isCorrect,
    bool wasAnswered,
    ThemeColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(
          color: wasAnswered
              ? (isCorrect ? colors.accent : colors.error)
              : colors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: wasAnswered
                  ? (isCorrect ? colors.accent : colors.error)
                  : colors.bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: wasAnswered
                  ? Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: colors.bg,
                      size: 16,
                    )
                  : Text(
                      '$questionNumber',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Question Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                // Correct Answer
                if (!isCorrect || !wasAnswered)
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: colors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '正确答案: ${question.options[question.correctAnswer].substring(3)}',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Explanation
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeColors colors) {
    return Column(
      children: [
        // Try Again Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.bg,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '再试一次',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Back to Explore Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.text,
              side: BorderSide(color: colors.border, width: 1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '返回Explore',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
