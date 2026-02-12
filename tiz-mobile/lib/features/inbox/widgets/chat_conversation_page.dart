import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants.dart';

/// Minimalist Chat Conversation Page
/// Full-screen chat interface without card container
class ChatConversationPage extends StatefulWidget {
  final String conversationId;
  final String title;

  const ChatConversationPage({
    super.key,
    required this.conversationId,
    required this.title,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '你好！有什么可以帮你的吗？',
      isUser: false,
    ),
    ChatMessage(
      text: '如何提高翻译准确度？',
      isUser: true,
    ),
    ChatMessage(
      text: '建议使用 AI 增强翻译模式，它可以理解上下文和语境，提供更准确的翻译结果。',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colors.text,
              size: 22,
            ),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages - Full screen, no padding constraints
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildChatBubble(message, colors);
                    },
                  ),
                  // Simple thinking indicator
                  if (_isThinking)
                    Positioned(
                      top: 8,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.bgSecondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI 正在思考...',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Input Area - Fixed at bottom
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border(
                  top: BorderSide(
                    color: colors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: '输入消息...',
                          hintStyle: TextStyle(color: colors.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colors.bgSecondary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 14,
                        ),
                        onSubmitted: (text) => _sendMessage(text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SendButton(
                      onPressed: () => _sendMessage(_controller.text),
                      colors: colors,
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

  /// Build Chat Bubble - Asymmetric corners for "tail" effect
  Widget _buildChatBubble(ChatMessage message, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: message.isUser ? colors.accent : colors.bgSecondary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(message.isUser ? 12 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 12),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? colors.bg : colors.text,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// Send Message
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isThinking = true;
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add(ChatMessage(
            text: '这是 AI 的回复占位符。实际使用时需要连接 AI 服务。',
            isUser: false,
          ));
        });

        // Scroll again after response
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }
}

/// Send Button with Scale Feedback
class _SendButton extends StatefulWidget {
  final VoidCallback onPressed;
  final ThemeColors colors;

  const _SendButton({
    required this.onPressed,
    required this.colors,
  });

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.colors.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.send_rounded,
            color: widget.colors.bg,
            size: 16,
          ),
        ),
      ),
    );
  }
}

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}
