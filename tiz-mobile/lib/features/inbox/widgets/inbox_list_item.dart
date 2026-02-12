import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../inbox_page.dart';

/// Minimalist Inbox List Item Redesign
/// Clean list item with improved visual hierarchy
class InboxListItem extends StatelessWidget {
  final ConversationItem conversation;
  final VoidCallback onTap;
  final ThemeColors colors;

  const InboxListItem({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread ? colors.bgSecondary : colors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasUnread ? colors.border : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with icon
            _buildAvatar(),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      if (conversation.isPinned) ...[
                        Icon(
                          Icons.push_pin_rounded,
                          size: 12,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation.title,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.time,
                        style: TextStyle(
                          color: hasUnread ? colors.textSecondary : colors.textTertiary,
                          fontSize: 12,
                          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Last message
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      color: hasUnread ? colors.text : colors.textSecondary,
                      fontSize: 13,
                      fontWeight: hasUnread ? FontWeight.w400 : FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Unread indicator
            if (hasUnread) _buildUnreadDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final (icon, iconColor) = _getAvatarIcon();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colors.text,
        shape: BoxShape.circle,
      ),
    );
  }

  (IconData, Color) _getAvatarIcon() {
    switch (conversation.title) {
      case 'Bot':
        return (Icons.smart_toy_rounded, AppColors.aiPrimary);
      case '翻译历史':
        return (Icons.translate_rounded, AppColors.aiSecondary);
      case '测验提醒':
        return (Icons.quiz_rounded, colors.text);
      case '系统通知':
        return (Icons.notifications_rounded, colors.textSecondary);
      default:
        return (Icons.chat_rounded, colors.text);
    }
  }
}
