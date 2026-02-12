import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../quiz/models.dart';

/// Quiz Practice Page - Clean minimal design
/// Single question practice with instant feedback
class QuizPracticePage extends StatefulWidget {
  final List<QuizQuestion> questions;
  final int startIndex;

  const QuizPracticePage({
    super.key,
    required this.questions,
    required this.startIndex,
  });

  @override
  State<QuizPracticePage> createState() => _QuizPracticePageState();
}

class _QuizPracticePageState extends State<QuizPracticePage> {
  late int _currentIndex;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _selectAnswer(int index) {
    if (_showFeedback) return;

    setState(() {
      _selectedAnswer = index;
      _isCorrect = index == _currentQuestion.correctAnswer;
      _showFeedback = true;
    });

    // Auto advance after delay if correct
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _isCorrect == true && _currentIndex < widget.questions.length - 1) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showFeedback = false;
        _isCorrect = null;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswer = null;
        _showFeedback = false;
        _isCorrect = null;
      });
    }
  }

  void _showCompletionDialog() {
    final colors = context.read<ThemeProvider>().colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '练习完成！',
          style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '已完成本组题目练习',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              '返回',
              style: TextStyle(color: colors.accent, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 0;
                _selectedAnswer = null;
                _showFeedback = false;
                _isCorrect = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.bg,
            ),
            child: const Text('重新练习'),
          ),
        ],
      ),
    );
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
          '题目 ${_currentIndex + 1}/${widget.questions.length}',
          style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: colors.textSecondary),
            onPressed: _showQuestionList,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(colors),

            // Question content
            Expanded(
              child: _buildContent(colors),
            ),

            // Bottom action bar
            _buildBottomBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeColors colors) {
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: colors.bgSecondary,
          valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Difficulty badge
          _buildDifficultyBadge(colors),

          const SizedBox(height: 16),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border.all(color: colors.border, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _currentQuestion.question,
              style: TextStyle(
                color: colors.text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Options
          ...List.generate(
            _currentQuestion.options.length,
            (index) => _buildOption(index, colors),
          ),

          const SizedBox(height: 16),

          // Explanation (show after answer)
          if (_showFeedback) _buildExplanation(colors),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(ThemeColors colors) {
    Color color;
    String label;

    switch (_currentQuestion.difficulty) {
      case QuizDifficulty.beginner:
        color = const Color(0xFF22C55E);
        label = '简单';
        break;
      case QuizDifficulty.intermediate:
        color = const Color(0xFFF59E0B);
        label = '中等';
        break;
      case QuizDifficulty.advanced:
        color = const Color(0xFFEF4444);
        label = '困难';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOption(int index, ThemeColors colors) {
    final isSelected = _selectedAnswer == index;
    final isCorrectAnswer = index == _currentQuestion.correctAnswer;
    final showCorrect = _showFeedback && isCorrectAnswer;
    final showWrong = _showFeedback && isSelected && !isCorrectAnswer;

    Color? cardColor;
    Color? borderColor;
    Color textColor = colors.text;

    if (showCorrect) {
      cardColor = const Color(0xFF22C55E);
      borderColor = const Color(0xFF22C55E);
      textColor = colors.bg;
    } else if (showWrong) {
      cardColor = const Color(0xFFEF4444);
      borderColor = const Color(0xFFEF4444);
      textColor = colors.bg;
    } else if (isSelected) {
      cardColor = colors.accent;
      borderColor = colors.accent;
      textColor = colors.bg;
    } else {
      cardColor = colors.bgSecondary;
      borderColor = colors.border;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectAnswer(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor!, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Option text
              Expanded(
                child: Text(
                  _currentQuestion.getOptionText(index),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              // Icon for correct/wrong
              if (showCorrect)
                Icon(Icons.check_rounded, color: textColor, size: 22)
              else if (showWrong)
                Icon(Icons.close_rounded, color: textColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(ThemeColors colors) {
    final isCorrect = _isCorrect ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF22C55E).withOpacity(0.08)
            : const Color(0xFFEF4444).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.lightbulb_outline : Icons.info_outline,
                color: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '解析',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currentQuestion.explanation,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeColors colors) {
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
            // Previous button
            if (_currentIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousQuestion,
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
                      Icon(Icons.arrow_back, size: 18, color: colors.text),
                      const SizedBox(width: 8),
                      const Text('上一题', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),

            if (_currentIndex > 0) const SizedBox(width: 12),

            // Next/Skip button
            Expanded(
              flex: _currentIndex > 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_showFeedback) {
                    if (_currentIndex < widget.questions.length - 1) {
                      _nextQuestion();
                    } else {
                      _showCompletionDialog();
                    }
                  } else {
                    // Skip
                    if (_currentIndex < widget.questions.length - 1) {
                      _nextQuestion();
                    }
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
                      _showFeedback
                          ? (_currentIndex < widget.questions.length - 1 ? '下一题' : '完成')
                          : '跳过',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    if (!_showFeedback || _currentIndex < widget.questions.length - 1) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18, color: colors.bg),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionList() {
    final colors = context.read<ThemeProvider>().colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '题目列表',
                style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  final isCurrent = index == _currentIndex;

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentIndex = index;
                        _selectedAnswer = null;
                        _showFeedback = false;
                        _isCorrect = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent ? colors.accent.withOpacity(0.1) : colors.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? colors.accent : colors.border,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCurrent ? colors.accent : colors.bgSecondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent ? colors.bg : colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.question,
                              style: TextStyle(
                                color: colors.text,
                                fontSize: 14,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
