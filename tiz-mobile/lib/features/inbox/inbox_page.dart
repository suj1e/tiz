import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';
import 'widgets/chat_conversation_page.dart';
import 'widgets/inbox_list_item.dart';

/// Minimalist Inbox Page Redesign
/// Full-screen message list with tab filtering and swipe actions
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock conversation data
  final List<ConversationItem> _conversations = [
    ConversationItem(
      id: '1',
      title: 'Bot',
      lastMessage: '建议使用 AI 增强翻译模式，它可以理解上下文和语境。',
      time: '10:30',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 2,
      isPinned: true,
    ),
    ConversationItem(
      id: '2',
      title: '翻译历史',
      lastMessage: 'Hello - 你好',
      time: '昨天',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isPinned: false,
    ),
    ConversationItem(
      id: '3',
      title: '测验提醒',
      lastMessage: '今日英语测验已完成，得分 85/100',
      time: '昨天',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      isPinned: false,
    ),
    ConversationItem(
      id: '4',
      title: '系统通知',
      lastMessage: '欢迎使用 Tiz！开始你的学习之旅吧。',
      time: '周一',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
      isPinned: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ConversationItem> get _filteredConversations {
    switch (_tabController.index) {
      case 1:
        return _conversations.where((c) => c.unreadCount > 0).toList();
      case 2:
        return _conversations.where((c) => c.isPinned).toList();
      default:
        return _conversations;
    }
  }

  int get _totalUnread {
    return _conversations.where((c) => c.unreadCount > 0).fold(0, (sum, c) => sum + c.unreadCount);
  }

  void _openConversation(ConversationItem conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(
          conversationId: conversation.id,
          title: conversation.title,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _markAsRead(ConversationItem conversation) {
    setState(() {
      conversation.unreadCount = 0;
    });
  }

  void _deleteConversation(ConversationItem conversation) {
    setState(() {
      _conversations.removeWhere((c) => c.id == conversation.id);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var conversation in _conversations) {
        conversation.unreadCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(colors),

            // Tab Bar
            _buildTabBar(colors),

            // Message List
            Expanded(
              child: _filteredConversations.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildConversationList(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.inboxTitle,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.02,
                ),
              ),
              const Spacer(),
              if (_totalUnread > 0)
                _buildUnreadBadge(colors),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$_totalUnread 条未读消息',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (_totalUnread > 0)
                TextButton(
                  onPressed: _markAllAsRead,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    AppStrings.inboxMarkAllRead,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.text,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$_totalUnread',
        style: TextStyle(
          color: colors.bg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeColors colors) {
    final tabs = ['全部', '未读', '已置顶'];

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.text, width: 2),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          color: colors.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelColor: colors.textSecondary,
        labelColor: colors.text,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildConversationList(ThemeColors colors) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _filteredConversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final conversation = _filteredConversations[index];
        return Dismissible(
          key: Key(conversation.id),
          background: _buildSwipeBackground(colors, isLeft: true),
          secondaryBackground: _buildSwipeBackground(colors, isLeft: false),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              _deleteConversation(conversation);
              return false;
            }
            return false;
          },
          child: InboxListItem(
            conversation: conversation,
            onTap: () => _openConversation(conversation),
            colors: colors,
          ),
        );
      },
    );
  }

  Widget _buildSwipeBackground(ThemeColors colors, {required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isLeft)
            Icon(
              Icons.done_all_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
          if (!isLeft)
            Icon(
              Icons.delete_outline_rounded,
              color: colors.textSecondary,
              size: 20,
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
            Icons.inbox_outlined,
            size: 56,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _tabController.index == 1
                ? '暂无未读消息'
                : _tabController.index == 2
                    ? '暂无已置顶消息'
                    : AppStrings.inboxEmpty,
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

/// Conversation Item Model
class ConversationItem {
  String id;
  String title;
  String lastMessage;
  String time;
  DateTime timestamp;
  int unreadCount;
  bool isPinned;

  ConversationItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.timestamp,
    required this.unreadCount,
    this.isPinned = false,
  });
}
