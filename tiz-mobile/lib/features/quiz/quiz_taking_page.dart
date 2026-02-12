import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';
import '../../ai/providers/ai_config_provider.dart';
import '../../ai/models/chat_message.dart';
import '../../ai/models/ai_model.dart';
import 'models.dart';
import 'quiz_results_page.dart';
import 'quiz_conversation_page.dart';
import 'quiz_voice_call_page.dart';

/// Quiz Taking Page
/// Displays questions and handles user interactions
class QuizTakingPage extends StatefulWidget {
  final QuizCategory category;
  final QuizMode mode;

  const QuizTakingPage({
    super.key,
    required this.category,
    required this.mode,
  });

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  late QuizSession _session;
  int? _selectedAnswer;
  bool _hasAnswered = false;

  // AI Chat panel state
  bool _showChatPanel = false;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isAiThinking = false;
  final List<ChatMessage> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _initializeChat();
  }

  void _initializeChat() {
    // Add initial AI greeting
    _chatMessages.add(
      ChatMessage.assistant(
        '我是你的AI学习助手！如果有题目不懂，可以随时问我。',
        metadata: {'type': 'greeting'},
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _toggleChatPanel() {
    setState(() {
      _showChatPanel = !_showChatPanel;
    });
  }

  void _startVoiceCall() {
    // Navigate to voice call page with current quiz state
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizVoiceCallPage(category: widget.category),
      ),
    );
  }

  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage.user(text);
    setState(() {
      _chatMessages.add(userMessage);
      _isAiThinking = true;
    });
    _chatController.clear();
    _scrollChatToBottom();

    try {
      final aiProvider = context.read<AiConfigProvider>();

      // Simulate AI response
      await Future.delayed(Duration(milliseconds: aiProvider.deepThinkingMode ? 1500 : 800));

      final currentQuestion = _session.currentQuestion;
      String response;

      if (currentQuestion != null &&
          (text.contains('这道题') ||
              text.contains('这道') ||
              text.contains('解释') ||
              text.contains('为什么') ||
              text.contains('怎么'))) {
        // Question-specific help
        response = '''这道题的答案是：${String.fromCharCode(65 + currentQuestion.correctAnswer)}

解析：${currentQuestion.explanation}

提示：${currentQuestion.hint ?? '仔细阅读题目，注意关键词'}''';
      } else {
        // General learning help
        response = '这是一个很好的问题！在学习语言时，多听、多说、多练习是非常重要的。如果对当前题目有疑问，可以直接问我，我会为你详细解释。';
      }

      setState(() {
        _chatMessages.add(ChatMessage.assistant(response));
        _isAiThinking = false;
      });
      _scrollChatToBottom();
    } catch (e) {
      setState(() {
        _isAiThinking = false;
      });
    }
  }

  void _scrollChatToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _initializeQuiz() {
    final questions = mockQuestions[widget.category] ?? [];
    _session = QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      questions: questions,
      mode: widget.mode,
      category: widget.category,
      startedAt: DateTime.now(),
    );
  }

  void _selectAnswer(int answerIndex) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answerIndex;
      _hasAnswered = true;
    });

    // Submit the answer
    _session.submitAnswer(answerIndex);
  }

  void _nextQuestion() {
    if (_session.isFinished) {
      _session.complete();
      _navigateToResults();
      return;
    }

    setState(() {
      _session.nextQuestion();
      _selectedAnswer = null;
      _hasAnswered = false;
    });
  }

  void _quitQuiz() {
    Navigator.of(context).pop();
  }

  void _navigateToResults() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsPage(session: _session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final aiProvider = context.watch<AiConfigProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.text),
          onPressed: _quitQuiz,
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
          // Voice Call button
          IconButton(
            icon: Icon(Icons.phone_outlined, color: colors.text),
            onPressed: _startVoiceCall,
            tooltip: '语音通话模式',
          ),
          // AI Chat button in app bar
          IconButton(
            icon: Icon(
              _showChatPanel ? Icons.chat_bubble : Icons.chat_bubble_outlined,
              color: colors.text,
            ),
            onPressed: _toggleChatPanel,
          ),
        ],
      ),
      body: Stack(
        children: [
          _session.isFinished
              ? _buildLoading(colors)
              : _buildQuestionContent(colors),
          // AI Chat Panel
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildChatPanel(colors, aiProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(ThemeColors colors) {
    return Center(
      child: CircularProgressIndicator(color: colors.accent),
    );
  }

  Widget _buildQuestionContent(ThemeColors colors) {
    final question = _session.currentQuestion;
    if (question == null) return _buildLoading(colors);

    return SafeArea(
      child: Column(
        children: [
          // Top Bar: Title + Progress
          _buildTopBar(colors),

          // Question Card - Centered
          Expanded(
            child: Center(
              child: _buildQuestionCard(question, colors),
            ),
          ),

          // Bottom Options - 4 buttons in 2x2 grid
          _buildOptionsGrid(question, colors),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _session.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Question Counter
          Text(
            '第 ${_session.currentIndex + 1}/${_session.questions.length} 题',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuestionCard(QuizQuestion question, ThemeColors colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Difficulty Badge - centered
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getDifficultyLabel(question.difficulty),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Question Text - Large, centered
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          // Show explanation after answering
          if (_hasAnswered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedAnswer == question.correctAnswer
                    ? colors.bg
                    : colors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedAnswer == question.correctAnswer
                      ? colors.accent
                      : colors.error,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedAnswer == question.correctAnswer
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _selectedAnswer == question.correctAnswer
                        ? colors.accent
                        : colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(QuizQuestion question, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 2x2 Grid for options
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(question.options[0], 0, colors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton(question.options[1], 1, colors),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(question.options[2], 2, colors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton(question.options[3], 3, colors),
              ),
            ],
          ),

          // Continue Button (only shown after answering)
          if (_hasAnswered) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.bg,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _session.isFinished ? '查看结果' : '继续',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, ThemeColors colors) {
    final isSelected = _selectedAnswer == index;
    final currentQuestion = _session.currentQuestion;
    final isCorrect = currentQuestion?.correctAnswer == index;
    final showResult = _hasAnswered;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (!showResult) {
      // Before answering - clean state
      backgroundColor = isSelected ? colors.accent : colors.bgSecondary;
      borderColor = isSelected ? colors.accent : colors.border;
      textColor = isSelected ? colors.bg : colors.text;
    } else {
      // After answering - show results
      if (isCorrect) {
        backgroundColor = colors.accent;
        borderColor = colors.accent;
        textColor = colors.bg;
      } else if (isSelected) {
        backgroundColor = colors.error;
        borderColor = colors.error;
        textColor = colors.bg;
      } else {
        backgroundColor = colors.bgSecondary;
        borderColor = colors.border;
        textColor = colors.textTertiary;
      }
    }

    final optionLetter = String.fromCharCode(65 + index);
    final optionText = option.substring(3); // Remove "A. " prefix

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Option Letter
            Text(
              optionLetter,
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            // Option Text
            Text(
              optionText,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Result icon for answered state
            if (showResult && isCorrect) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: textColor,
                size: 20,
              ),
            ],
            if (showResult && isSelected && !isCorrect) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.cancel,
                color: textColor,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(QuizCategory category) {
    switch (category) {
      case QuizCategory.english:
        return AppStrings.quizCategoryEnglish;
      case QuizCategory.japanese:
        return AppStrings.quizCategoryJapanese;
      case QuizCategory.german:
        return AppStrings.quizCategoryGerman;
    }
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

  /// Build floating AI chat button
  Widget _buildChatButton(ThemeColors colors) {
    return GestureDetector(
      onTap: _toggleChatPanel,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.aiPrimary.withOpacity(0.9),
              AppColors.aiSecondary.withOpacity(0.9),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.aiPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _showChatPanel ? Icons.close : Icons.smart_toy,
          color: colors.bg,
          size: 26,
        ),
      ),
    );
  }

  /// Build AI chat panel
  Widget _buildChatPanel(ThemeColors colors, AiConfigProvider aiProvider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: _showChatPanel ? 400 : 0,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.text.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.aiPrimary.withOpacity(0.1),
                    AppColors.aiSecondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(
                  bottom: BorderSide(color: colors.borderLight, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.aiPrimary.withOpacity(0.8),
                          AppColors.aiSecondary.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: colors.bg,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI 老师',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '随时为你解答问题',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Deep thinking toggle
                  GestureDetector(
                    onTap: aiProvider.model.supportsDeepThinking
                        ? () => aiProvider.toggleDeepThinkingMode()
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: aiProvider.deepThinkingMode
                            ? AppColors.aiBadgeBackground
                            : colors.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: aiProvider.deepThinkingMode
                              ? AppColors.aiBadgeText
                              : colors.border,
                        ),
                      ),
                      child: Text(
                        '深度思考',
                        style: TextStyle(
                          color: aiProvider.deepThinkingMode
                              ? AppColors.aiBadgeText
                              : colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: _chatMessages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 40,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '向AI老师提问',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _chatMessages.length + (_isAiThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _chatMessages.length) {
                          return _buildAiThinkingIndicator(colors, aiProvider);
                        }
                        final message = _chatMessages[index];
                        return _buildChatBubble(message, colors);
                      },
                    ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.borderLight, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: '输入问题...',
                        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: colors.border, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: colors.border, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(color: colors.text, fontSize: 13),
                      onSubmitted: (_) => _sendChatMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isAiThinking ? null : _sendChatMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isAiThinking ? colors.textTertiary : colors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isAiThinking
                            ? Icons.hourglass_empty
                            : Icons.send,
                        color: colors.bg,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, ThemeColors colors) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isUser ? colors.accent : colors.bgSecondary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isUser ? 12 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 12),
            ),
            border: Border.all(
              color: isUser ? Colors.transparent : colors.border,
              width: 1,
            ),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: isUser ? colors.bg : colors.text,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiThinkingIndicator(ThemeColors colors, AiConfigProvider aiProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          aiProvider.deepThinkingMode
              ? _buildWaveIndicator()
              : SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
                  ),
                ),
          const SizedBox(width: 8),
          Text(
            aiProvider.deepThinkingMode ? 'AI思考中...' : 'AI回复中...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.15;
        return AnimatedBuilder(
          animation: const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            return Container(
              width: 4,
              height: 8 + 8 * ((DateTime.now().millisecondsSinceEpoch / 500 + index * 0.2) % 1.0),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.aiPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
