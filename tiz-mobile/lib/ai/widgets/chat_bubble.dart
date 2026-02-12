import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_colors.dart';
import '../models/chat_message.dart';

/// Chat Bubble Widget
/// Displays a single chat message with appropriate styling
class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showThinking;

  const ChatBubble({
    super.key,
    required this.message,
    this.showThinking = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isUser = widget.message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          GestureDetector(
            onTap: () {
              if (widget.message.isDeepThinking && !isUser) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: isUser
                  ? AppDecorations.chatBubbleUserDecoration(colors: colors)
                  : AppDecorations.chatBubbleAIDecoration(colors: colors),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI badge for assistant messages
                  if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AI助手',
                          style: TextStyle(
                            color: AppColors.aiPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppColors.aiPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  // Message content
                  Text(
                    _getDisplayContent(),
                    style: TextStyle(
                      color: isUser ? Colors.white : colors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Deep thinking expansion (only for AI messages with deep thinking)
          if (!isUser &&
              widget.message.isDeepThinking &&
              widget.message.thinkingProcess != null)
            _buildDeepThinkingSection(colors),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              widget.message.formattedTime,
              style: TextStyle(
                color: colors.textSecondary.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayContent() {
    if (widget.message.isUser) {
      return widget.message.content;
    }

    // For AI messages, remove thinking tags from display
    String content = widget.message.content;
    final thinkingRegex = RegExp(r'<thinking>.*?</thinking>', dotAll: true);
    content = content.replaceAll(thinkingRegex, '').trim();

    return content;
  }

  Widget _buildDeepThinkingSection(ThemeColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.aiBadgeBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.aiBadgeText.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  size: 16,
                  color: AppColors.aiPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  '深度思考过程',
                  style: TextStyle(
                    color: AppColors.aiPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.aiPrimary,
                ),
              ],
            ),
          ),
          // Thinking content
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Text(
              _formatThinkingProcess(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatThinkingProcess() {
    if (widget.message.thinkingProcess != null) {
      return widget.message.thinkingProcess!;
    }

    // Extract thinking from content
    final thinkingRegex = RegExp(r'<thinking>(.*?)</thinking>', dotAll: true);
    final match = thinkingRegex.firstMatch(widget.message.content);

    if (match != null) {
      return match.group(1) ?? '';
    }

    return '思考过程未显示';
  }
}

/// Typing Indicator Widget
/// Shows when the other party is typing
class TypingIndicator extends StatefulWidget {
  final ThemeColors colors;

  const TypingIndicator({super.key, required this.colors});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) {
              final delay = index * 0.2;
              final animValue = ((_controller.value + delay) % 1.0);
              final opacity = 0.3 + 0.7 * animValue;

              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: widget.colors.textSecondary.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Message Status Indicator
/// Shows delivery/read status for user messages
class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final ThemeColors colors;

  const MessageStatusIndicator({
    super.key,
    required this.status,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        iconColor = colors.textSecondary.withOpacity(0.5);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        iconColor = colors.textSecondary.withOpacity(0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        iconColor = colors.textSecondary.withOpacity(0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        iconColor = colors.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        iconColor = colors.error;
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: iconColor,
    );
  }
}

/// Message Status Enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Attachment Preview Widget
/// Shows preview of attached files/images
class AttachmentPreview extends StatelessWidget {
  final String url;
  final String? type;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const AttachmentPreview({
    super.key,
    required this.url,
    this.type,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Stack(
          children: [
            // Preview
            Center(
              child: Icon(
                _getIconForType(),
                size: 32,
                color: colors.textSecondary,
              ),
            ),
            // Remove button
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType() {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.mic;
      case 'document':
        return Icons.description;
      default:
        return Icons.attach_file;
    }
  }
}
