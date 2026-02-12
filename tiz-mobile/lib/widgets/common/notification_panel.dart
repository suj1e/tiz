import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/notification.dart' as app_model;
import '../../providers/notification_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';

/// Notification Panel Controller
/// Controls the notification panel open/close state
class NotificationPanelController extends ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }
}

/// Notification Panel Widget
/// Slide-down panel from top-right with notification list
/// Pure flat design, no shadows (minimalist style)
class NotificationPanel extends StatefulWidget {
  final VoidCallback? onOutsideTap;
  final NotificationPanelController? controller;

  const NotificationPanel({
    super.key,
    this.onOutsideTap,
    this.controller,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late NotificationPanelController _controller;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _controller = widget.controller ?? NotificationPanelController();
    _controller.addListener(_onControllerChanged);

    if (_controller.isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  bool get _isOpen => _controller.isOpen;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, NotificationProvider>(
      builder: (context, themeProvider, notificationProvider, child) {
        final colors = themeProvider.colors;
        final notifications = notificationProvider.notifications;
        final unreadCount = notificationProvider.unreadCount;

        return Stack(
          children: [
            // Panel
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: !_isOpen,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: child,
                  ),
                );
              },
              child: _buildPanel(colors, notifications, unreadCount, notificationProvider),
            ),
            // Overlay
            if (_isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _controller.close();
                    widget.onOutsideTap?.call();
                  },
                  child: Container(
                    color: colors.text.withValues(alpha: 0.05),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPanel(
    ThemeColors colors,
    List<app_model.Notification> notifications,
    int unreadCount,
    NotificationProvider notificationProvider,
  ) {
    final sortedNotifications = [...notifications]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 12),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(colors, unreadCount, notificationProvider),

            // Notification List
            Flexible(
              child: Container(
                height: 420,
                child: sortedNotifications.isEmpty
                    ? _buildEmptyState(colors)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: sortedNotifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return NotificationItemCard(
                            notification: sortedNotifications[index],
                            onTap: () {
                              notificationProvider.markAsRead(sortedNotifications[index].id);
                              _controller.close();
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeColors colors,
    int unreadCount,
    NotificationProvider notificationProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.notificationTitle,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.text,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: TextStyle(
                      color: colors.bg,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: () {
                    notificationProvider.markAllAsRead();
                    _controller.close();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    AppStrings.markAllRead,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _controller.close(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 14,
                  ),
                ),
              ),
            ],
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
          Icon(
            Icons.notifications_none_outlined,
            size: 48,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.notificationEmpty,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Item Card Widget
/// Single notification item in the panel
class NotificationItemCard extends StatelessWidget {
  final app_model.Notification notification;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () {
        onTap?.call();
        notification.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? colors.bgSecondary : colors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUnread ? colors.border : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            _buildNotificationIcon(colors),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Body
                  Text(
                    notification.body,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Time
                  Text(
                    notification.formattedTime,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.text,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(ThemeColors colors) {
    final (icon, iconColor) = _getIconForType(colors);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 16,
      ),
    );
  }

  (IconData, Color) _getIconForType(ThemeColors colors) {
    switch (notification.type) {
      case app_model.NotificationType.translationComplete:
        return (Icons.translate_rounded, AppColors.aiSecondary);
      case app_model.NotificationType.newFeature:
        return (Icons.auto_awesome_rounded, AppColors.aiPrimary);
      case app_model.NotificationType.learningReminder:
        return (Icons.school_rounded, colors.text);
      case app_model.NotificationType.system:
        return (Icons.info_outline_rounded, colors.textSecondary);
    }
  }
}

/// Notification Button Widget
/// Button to open notification panel with badge
class NotificationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border.all(color: colors.border, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: colors.text,
                    size: 18,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.text,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: TextStyle(
                            color: colors.bg,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
