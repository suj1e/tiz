import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../ai/providers/ai_config_provider.dart';
import '../../../ai/models/ai_model.dart';
import '../../../ai/models/chat_message.dart';
import '../../../ai/widgets/chat_bubble.dart';

/// AI Chat Assistant Widget
/// AI-powered chat assistant with deep thinking mode toggle
class AiChatAssistant extends StatefulWidget {
  const AiChatAssistant({super.key});

  @override
  State<AiChatAssistant> createState() => _AiChatAssistantState();
}

class _AiChatAssistantState extends State<AiChatAssistant> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isThinking = false;
  bool _showDeepThinking = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(_messageController.text);
    setState(() {
      _messages.add(userMessage);
      _isThinking = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final aiProvider = context.read<AiConfigProvider>();

      // Simulate AI response
      await Future.delayed(
        Duration(
          milliseconds: aiProvider.deepThinkingMode ? 1500 : 500,
        ),
      );

      String response;
      if (aiProvider.deepThinkingMode) {
        response = '''<thinking>
Let me think about this question carefully...

The user asked: "${userMessage.content}"

I should provide a thoughtful and helpful response.
</thinking>

感谢你的问题！这是一个AI助手演示。在实际使用时，我会连接真实的AI服务来提供智能回答。

你可以问我关于翻译、学习建议或任何其他问题。''';
      } else {
        response = '你好！这是AI助手演示。在实际使用时，我会连接真实的AI服务来回答你的问题。你可以问我关于翻译、学习建议等任何问题。';
      }

      setState(() {
        _messages.add(ChatMessage.assistant(
          response,
          isDeepThinking: aiProvider.deepThinkingMode,
        ));
        _isThinking = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isThinking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final aiProvider = context.watch<AiConfigProvider>();

    return Column(
      children: [
        // Chat Header with Deep Thinking Toggle
        _buildHeader(colors, aiProvider),

        // Messages List
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
                    return ChatBubble(
                      message: message,
                      showThinking: _showDeepThinking && message.isDeepThinking,
                    );
                  },
                ),
        ),

        // Input Area
        _buildInputArea(colors, aiProvider),
      ],
    );
  }

  /// Build Header
  Widget _buildHeader(ThemeColors colors, AiConfigProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.glassBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI助手',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('✨', style: TextStyle(fontSize: 14)),
                  ],
                ),
                if (aiProvider.deepThinkingMode)
                  Text(
                    '深度思考模式已开启',
                    style: TextStyle(
                      color: AppColors.aiPrimary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Deep Thinking Toggle
          if (aiProvider.model.supportsDeepThinking)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showDeepThinking = !_showDeepThinking;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: aiProvider.deepThinkingMode
                      ? AppColors.aiBadgeBackground
                      : colors.glassBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: aiProvider.deepThinkingMode
                        ? AppColors.aiBadgeText
                        : colors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      size: 14,
                      color: aiProvider.deepThinkingMode
                          ? AppColors.aiBadgeText
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '深度思考',
                      style: TextStyle(
                        color: aiProvider.deepThinkingMode
                            ? AppColors.aiBadgeText
                            : colors.textSecondary,
                        fontSize: 12,
                        fontWeight: aiProvider.deepThinkingMode
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
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
              Icons.smart_toy_rounded,
              size: 40,
              color: AppColors.aiPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI助手',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '有什么我可以帮助你的吗？',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Quick Questions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _QuickQuestion(
                text: '如何学习英语？',
                onTap: () {
                  _messageController.text = '如何学习英语？';
                  _sendMessage();
                },
                colors: colors,
              ),
              _QuickQuestion(
                text: '翻译这句话',
                onTap: () {
                  _messageController.text = '请帮我翻译：Hello, how are you?';
                  _sendMessage();
                },
                colors: colors,
              ),
              _QuickQuestion(
                text: '推荐学习资料',
                onTap: () {
                  _messageController.text = '有什么推荐的英语学习资料吗？';
                  _sendMessage();
                },
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Thinking Indicator
  Widget _buildThinkingIndicator(ThemeColors colors, AiConfigProvider aiProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (aiProvider.deepThinkingMode)
            _DeepThinkingIndicator(colors: colors)
          else
            _NormalThinkingIndicator(colors: colors),
          const SizedBox(width: 12),
          Text(
            aiProvider.deepThinkingMode ? '正在深度思考...' : '正在思考...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Input Area
  Widget _buildInputArea(ThemeColors colors, AiConfigProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.glassBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice Button (simple icon button)
            IconButton(
              icon: Icon(
                Icons.mic_outlined,
                color: colors.textSecondary,
              ),
              onPressed: () {
                // TODO: Implement voice input
              },
            ),
            const SizedBox(width: 8),
            // Input Field
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                minLines: 1,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            // Send Button
            GestureDetector(
              onTap: _isThinking ? null : _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary,
                      colors.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isThinking ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Question Button
class _QuickQuestion extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final ThemeColors colors;

  const _QuickQuestion({
    required this.text,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.aiPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.aiPrimary.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.aiPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Deep Thinking Indicator
class _DeepThinkingIndicator extends StatefulWidget {
  final ThemeColors colors;

  const _DeepThinkingIndicator({required this.colors});

  @override
  State<_DeepThinkingIndicator> createState() => _DeepThinkingIndicatorState();
}

class _DeepThinkingIndicatorState extends State<_DeepThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(
            3,
            (index) {
              final delay = index * 0.2;
              final animValue = ((_controller.value + delay) % 1.0);
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
            },
          ),
        );
      },
    );
  }
}

/// Normal Thinking Indicator
class _NormalThinkingIndicator extends StatefulWidget {
  final ThemeColors colors;

  const _NormalThinkingIndicator({required this.colors});

  @override
  State<_NormalThinkingIndicator> createState() => _NormalThinkingIndicatorState();
}

class _NormalThinkingIndicatorState extends State<_NormalThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.colors.primary,
            ),
          ),
        );
      },
    );
  }
}
