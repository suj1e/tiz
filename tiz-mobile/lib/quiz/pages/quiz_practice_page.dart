/// Quiz Practice Page
/// Continuous practice mode with skip functionality

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/quiz/models.dart';
import '../models/quiz_status.dart';
import '../providers/quiz_practice_provider.dart';
import '../providers/quiz_progress_provider.dart';
import '../services/quiz_bank_service.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/option_button.dart';
import '../widgets/progress_dots.dart';
import 'quiz_results_summary_page.dart';

/// Practice mode page - continuous question flow
class QuizPracticePage extends StatefulWidget {
  final QuizCategory category;
  final String? startQuestionId;
  final PracticeMode mode;

  const QuizPracticePage({
    super.key,
    required this.category,
    this.startQuestionId,
    this.mode = PracticeMode.continuous,
  });

  @override
  State<QuizPracticePage> createState() => _QuizPracticePageState();
}

class _QuizPracticePageState extends State<QuizPracticePage>
    with TickerProviderStateMixin {
  late QuizPracticeProvider _provider;
  late AnimationController _questionController;
  late AnimationController _feedbackController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _provider = QuizPracticeProvider(
      QuizBankService(),
      context.read<QuizProgressProvider>(),
    );
    _initializeAnimations();
    _initializePractice();
    _startTimer();
  }

  void _initializeAnimations() {
    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeOutBack),
    );

    _questionController.forward();
  }

  void _initializePractice() {
    _provider.initialize(
      category: widget.category,
      mode: widget.mode,
    );

    // Jump to specific question if provided
    if (widget.startQuestionId != null) {
      final index = _provider.totalQuestions > 0
          ? 0 // TODO: Find question by ID
          : 0;
      if (index >= 0) {
        _provider.jumpToQuestion(index);
      }
    }
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final newElapsed = (_provider.elapsedSeconds + 1);
      _provider.updateElapsedTime(newElapsed);
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _feedbackController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          backgroundColor: colors.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: colors.text),
            onPressed: () => _showQuitConfirmation(context),
          ),
          title: Text(
            _getCategoryLabel(widget.category),
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            // Timer
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_provider.elapsedSeconds),
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Consumer<QuizPracticeProvider>(
          builder: (context, provider, child) {
            if (provider.isCompleted) {
              // Navigate to results
              SchedulerBinding.instance
                  .addPostFrameCallback((_) => _navigateToResults(context));
              return _buildLoading(colors);
            }

            final question = provider.currentQuestion;
            if (question == null) return _buildLoading(colors);

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: SafeArea(
                child: Column(
                  children: [
                    // Progress dots
                    _buildProgressDots(colors, provider),

                    const SizedBox(height: 16),

                    // Question counter
                    Text(
                      '第 ${provider.currentIndex + 1}/${provider.totalQuestions} 题',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats panel
                    _buildStatsPanel(colors, provider),

                    const SizedBox(height: 16),

                    // Question card
                    Expanded(
                      child: Center(
                        child: _buildQuestionCard(
                          colors,
                          question,
                          provider,
                        ),
                      ),
                    ),

                    // Options
                    _buildOptions(colors, provider, question),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.accent),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots(
    ThemeColors colors,
    QuizPracticeProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ProgressDots(
        total: provider.totalQuestions,
        current: provider.currentIndex,
        userAnswers: List.filled(provider.totalQuestions, null),
        onTap: (index) => provider.jumpToQuestion(index),
      ),
    );
  }

  Widget _buildStatsPanel(
    ThemeColors colors,
    QuizPracticeProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatItem(colors, '正确', '${provider.correctCount}'),
          Container(
            width: 1,
            height: 20,
            color: colors.border,
          ),
          _buildStatItem(colors, '错误', '${provider.wrongCount}'),
          Container(
            width: 1,
            height: 20,
            color: colors.border,
          ),
          _buildStatItem(colors, 'XP', '+${provider.correctCount * 10}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeColors colors, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    ThemeColors colors,
    QuizQuestion question,
    QuizPracticeProvider provider,
  ) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border.all(color: colors.border, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Difficulty badge
                Center(
                  child: DifficultyBadge(
                    difficulty: question.difficulty,
                    showLabel: true,
                  ),
                ),

                const SizedBox(height: 16),

                // Question text
                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                // Show explanation after answering
                if (provider.hasSubmitted) ...[
                  const SizedBox(height: 20),
                  _buildExplanationCard(colors, question, provider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExplanationCard(
    ThemeColors colors,
    QuizQuestion question,
    QuizPracticeProvider provider,
  ) {
    final isCorrect = provider.selectedAnswer == question.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? colors.accent.withOpacity(0.05) : colors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? colors.accent : colors.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCorrect ? colors.accent : colors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: colors.bg,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? '回答正确！' : '回答错误',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.explanation,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(
    ThemeColors colors,
    QuizPracticeProvider provider,
    QuizQuestion question,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OptionButtonGrid(
        options: question.options,
        selectedIndex: provider.selectedAnswer,
        correctIndex: provider.hasSubmitted ? question.correctAnswer : null,
        showResult: provider.hasSubmitted,
        onOptionTap: (index) {
          if (!provider.hasSubmitted) {
            provider.selectAnswer(index);
          }
        },
        isCompact: false,
      ),
    );
  }

  Widget _buildBottomBar(ThemeColors colors, QuizPracticeProvider provider) {
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
            // Skip button
            if (!provider.hasSubmitted) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: provider.canGoNext
                      ? () => provider.nextQuestion()
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.border, width: 1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('跳过',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            // Main action button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (provider.hasSubmitted) {
                    provider.nextQuestion();
                  } else if (provider.selectedAnswer != null) {
                    provider.submitAnswer();
                  }
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.hasSubmitted
                          ? (provider.isCompleted ? '查看结果' : '继续')
                          : '提交',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      provider.hasSubmitted
                          ? (provider.isCompleted
                              ? Icons.assessment_rounded
                              : Icons.arrow_forward_rounded)
                          : Icons.check_rounded,
                      size: 20,
                      color: colors.bg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getCategoryLabel(QuizCategory category) {
    switch (category) {
      case QuizCategory.english:
        return '英语';
      case QuizCategory.japanese:
        return '日本語';
      case QuizCategory.german:
        return '德语';
    }
  }

  void _showQuitConfirmation(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '退出练习？',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '进度将会保存',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colors.textSecondary,
            ),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _navigateToResults(BuildContext context) {
    final result = _provider.getResults();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsSummaryPage(
          result: result,
          category: widget.category,
        ),
      ),
    );
  }
}
