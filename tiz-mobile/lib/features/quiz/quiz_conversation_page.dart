import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../ai/providers/ai_config_provider.dart';
import '../../../ai/models/chat_message.dart';
import '../../../ai/models/ai_model.dart';
import '../../../ai/widgets/chat_bubble.dart';
import '../../../quiz/models/quiz_models.dart' show QuizMode, QuizCategory, QuizQuestion;
import 'quiz_voice_call_page.dart';

/// AI Conversation Quiz Page
/// Allows users to have AI-powered conversations for language learning
class QuizConversationPage extends StatefulWidget {
  final QuizCategory category;

  const QuizConversationPage({
    super.key,
    required this.category,
  });

  @override
  State<QuizConversationPage> createState() => _QuizConversationPageState();
}

class _QuizConversationPageState extends State<QuizConversationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isThinking = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Add initial AI greeting
    _addAiGreeting();
  }

  void _addAiGreeting() {
    final greeting = _getGreetingForCategory();
    _messages.add(
      ChatMessage.assistant(
        greeting,
        metadata: {'category': widget.category.name},
      ),
    );
  }

  String _getGreetingForCategory() {
    switch (widget.category) {
      case QuizCategory.english:
        return 'Hello! I\'m your AI conversation partner for English practice. Let\'s start with a simple question: How are you feeling today? (用英文回答哦)';
      case QuizCategory.japanese:
        return 'こんにちは！私は日本語会話の練習パートナーです。では、最初の質問です：今日、どうですか？';
      case QuizCategory.german:
        return 'Hallo! Ich bin dein Deutschübungspartner. Lass uns mit einer einfachen Frage beginnen: Wie geht es dir heute?';
      default:
        return 'Hello! Let\'s practice language together.';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage.user(text);
    setState(() {
      _messages.add(userMessage);
      _isThinking = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final aiProvider = context.read<AiConfigProvider>();

      // Simulate AI response with topic-aware response
      await Future.delayed(const Duration(milliseconds: 800));

      String response = _generateAiResponse(text);

      setState(() {
        _messages.add(ChatMessage.assistant(response));
        _isThinking = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isThinking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _generateAiResponse(String userText) {
    // Generate contextual AI response based on category and input
    final categoryName = widget.category.name;

    // Check if user answered a question
    if (userText.toLowerCase().contains('good') ||
        userText.toLowerCase().contains('fine') ||
        userText.toLowerCase().contains('great') ||
        userText.toLowerCase().contains('不错') ||
        userText.toLowerCase().contains('元気') ||
        userText.toLowerCase().contains('gut')) {
      switch (widget.category) {
        case QuizCategory.english:
          return 'Great! Now let\'s practice. Tell me about your day in English. What did you do today?';
        case QuizCategory.japanese:
          return 'それは良いですね！では、実践的な会話に入りましょう。今日は何がありましたか？教えてくれますか？';
        case QuizCategory.german:
          return 'Das ist schön! Lass uns jetzt üben. Was hast du heute gemacht? Erzähle mir davon auf Deutsch!';
        default:
          return 'Great! Let\'s continue practicing.';
      }
    }

    // Default responses
    switch (widget.category) {
      case QuizCategory.english:
        return 'That\'s a good answer! Keep practicing. Try to use more vocabulary in your response. What else can you tell me?';
      case QuizCategory.japanese:
        return '上手ですね！もう少し詳しく教えてください。例えば：朝何を食べましたか？';
      case QuizCategory.german:
        return 'Gut gemacht! Versuche, mehr Vokabular zu verwenden. Was möchtest du mir noch erzählen?';
      default:
        return 'That\'s a good answer! Keep practicing.';
    }
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
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
                Icons.smart_toy_rounded,
                color: colors.bg,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _getCategoryName(),
              style: TextStyle(
                color: colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Voice call button
          IconButton(
            icon: Icon(Icons.phone_outlined, color: colors.text),
            onPressed: () {
              // Navigate to voice call page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizVoiceCallPage(category: widget.category),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Status Banner
          _buildStatusBanner(colors, aiProvider),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(colors)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildThinkingIndicator(colors, aiProvider);
                      }
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ChatBubble(message: message),
                      );
                    },
                  ),
          ),

          // Input Area
          _buildInputArea(colors),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ThemeColors colors, AiConfigProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: aiProvider.deepThinkingMode
            ? AppColors.aiBadgeBackground.withOpacity(0.3)
            : colors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            aiProvider.deepThinkingMode
                ? Icons.psychology_rounded
                : Icons.auto_awesome_rounded,
            size: 16,
            color: aiProvider.deepThinkingMode
                ? AppColors.aiBadgeText
                : colors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            aiProvider.deepThinkingMode ? '深度思考模式' : 'AI对话练习',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Mode toggle
          GestureDetector(
            onTap: aiProvider.model.supportsDeepThinking
                ? () => aiProvider.toggleDeepThinkingMode()
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: aiProvider.deepThinkingMode
                    ? AppColors.aiBadgeBackground
                    : colors.bg,
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
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.aiPrimary.withOpacity(0.2),
                  AppColors.aiSecondary.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 32,
              color: AppColors.aiPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI对话练习',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '与AI进行${_getCategoryName()}对话练习',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(ThemeColors colors, AiConfigProvider aiProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          aiProvider.deepThinkingMode
              ? _buildWaveIndicator()
              : SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
                  ),
                ),
          const SizedBox(width: 10),
          Text(
            aiProvider.deepThinkingMode ? 'AI正在思考...' : 'AI正在回复...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveIndicator() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = ((_waveController.value + delay) % 1.0);
            final height = 8.0 + 12.0 * animValue;

            return Container(
              width: 4,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.aiPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInputArea(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice input button
            GestureDetector(
              onTap: () {
                // TODO: Implement voice input
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: Icon(
                  Icons.mic_outlined,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Input field
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                minLines: 1,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '输入消息... (输入${{
                    'english': '英文',
                    'japanese': '日文',
                    'german': '德文',
                  }[widget.category.name]})',
                  hintStyle: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.text, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            // Send button
            GestureDetector(
              onTap: _isThinking ? null : _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isThinking ? colors.textTertiary : colors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isThinking ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                  color: colors.bg,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName() {
    switch (widget.category) {
      case QuizCategory.english:
        return '英语对话';
      case QuizCategory.japanese:
        return '日语对话';
      case QuizCategory.german:
        return '德语对话';
    }
  }
}
