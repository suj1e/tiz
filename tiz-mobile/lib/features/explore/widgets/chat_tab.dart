import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants.dart';

/// Slash Command Model
/// Represents a slash command that can be auto-completed
class SlashCommand {
  final String command;
  final String description;
  final IconData icon;
  final String example;

  const SlashCommand({
    required this.command,
    required this.description,
    required this.icon,
    required this.example,
  });

  static const List<SlashCommand> allCommands = [
    SlashCommand(
      command: '/translate',
      description: '翻译文本',
      icon: Icons.translate,
      example: '/translate Hello to Chinese',
    ),
    SlashCommand(
      command: '/quiz',
      description: '开始测验',
      icon: Icons.quiz,
      example: '/quiz English 5 questions',
    ),
    SlashCommand(
      command: '/explain',
      description: '解释语法',
      icon: Icons.school,
      example: '/explain past perfect tense',
    ),
    SlashCommand(
      command: '/practice',
      description: '对话练习',
      icon: Icons.mic_none,
      example: '/practice conversation Japanese',
    ),
    SlashCommand(
      command: '/vocab',
      description: '词汇学习',
      icon: Icons.book,
      example: '/vocab food words',
    ),
    SlashCommand(
      command: '/grammar',
      description: '语法检查',
      icon: Icons.rate_review,
      example: '/grammar Check this sentence',
    ),
    SlashCommand(
      command: '/pronounce',
      description: '发音练习',
      icon: Icons.record_voice_over,
      example: '/pronounce How do you say "hello"?',
    ),
    SlashCommand(
      command: '/help',
      description: '获取帮助',
      icon: Icons.help_outline,
      example: '/help',
    ),
  ];
}

/// Minimalist Chat Tab
/// AI chat assistant interface - matches prototype exactly
class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;
  bool _isScrolling = false;

  // Slash command auto-complete state
  String _currentQuery = '';
  List<SlashCommand> _filteredCommands = [];
  bool _showSuggestions = false;
  int _selectedIndex = 0;

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
      text: '建议使用 AI 增强翻译模式，它可以理解上下文和语境。',
      isUser: false,
    ),
  ];

  /// Handle text input changes for slash command auto-complete
  void _onTextChanged(String text) {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _currentQuery = '';
        _filteredCommands = [];
      });
      return;
    }

    // Check if text starts with '/'
    if (trimmedText.startsWith('/')) {
      final query = trimmedText.substring(1).toLowerCase();
      final filtered = SlashCommand.allCommands
          .where((cmd) =>
              cmd.command.toLowerCase().contains(query) ||
              cmd.description.toLowerCase().contains(query))
          .toList();

      setState(() {
        _currentQuery = trimmedText;
        _filteredCommands = filtered;
        _showSuggestions = filtered.isNotEmpty;
        _selectedIndex = 0;
      });
    } else {
      setState(() {
        _showSuggestions = false;
        _currentQuery = '';
        _filteredCommands = [];
      });
    }
  }

  /// Apply selected slash command
  void _applyCommand(SlashCommand command) {
    setState(() {
      _controller.text = command.example;
      _showSuggestions = false;
      _currentQuery = '';
      _filteredCommands = [];
    });
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  /// Handle keyboard navigation in suggestions
  void _handleKeyEvent(KeyEvent event) {
    if (!_showSuggestions) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + _filteredCommands.length) %
            _filteredCommands.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex < _filteredCommands.length) {
        _applyCommand(_filteredCommands[_selectedIndex]);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title only
          Text(
            AppStrings.chatTitle,
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Chat Messages
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildChatBubble(message, colors);
                  },
                ),
                // Simple thinking indicator
                if (_isThinking)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.bgSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
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

          const SizedBox(height: 12),

          // Slash Command Suggestions
          if (_showSuggestions && _filteredCommands.isNotEmpty)
            _buildSuggestionsPanel(colors),

          const SizedBox(height: 8),

          // Input Area
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  decoration: InputDecoration(
                    hintText: AppStrings.chatHint,
                    hintStyle: TextStyle(color: colors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.textTertiary, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
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
        ],
      ),
    );
  }

  /// Build slash command suggestions panel
  Widget _buildSuggestionsPanel(ThemeColors colors) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.borderLight, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '快捷指令',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Command list
            ..._filteredCommands.asMap().entries.map((entry) {
              final index = entry.key;
              final command = entry.value;
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () => _applyCommand(command),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.border.withOpacity(0.3) : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        command.icon,
                        size: 18,
                        color: isSelected ? colors.text : colors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              command.command,
                              style: TextStyle(
                                color: isSelected ? colors.text : colors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              command.description,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 16,
                          color: colors.textTertiary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            // Footer hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.borderLight, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '使用 ↑↓ 选择，Enter 确认',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${_filteredCommands.length} 个指令',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 10,
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

  /// Build Chat Bubble
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

    // Scroll to bottom (with guard to prevent concurrent scrolls)
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add(ChatMessage(
            text: '这是 AI 的回复占位符。实际使用时需要连接 AI 服务。',
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  /// Scroll to bottom of messages (with guard to prevent concurrent animations)
  void _scrollToBottom() {
    if (_isScrolling) return;
    _isScrolling = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        ).then((_) {
          // Reset flag after animation completes
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 200), () {
              _isScrolling = false;
            });
          }
        });
      } else {
        _isScrolling = false;
      }
    });
  }
}

/// Send Button with Scale Feedback Animation
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.colors.accent,
            borderRadius: BorderRadius.circular(10),
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
