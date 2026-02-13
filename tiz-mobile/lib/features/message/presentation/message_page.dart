import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/message.dart';
import '../message_provider.dart';
import 'message_list_item.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  @override
  void initState() {
    super.initState();
    // Load read message IDs on init
    Future.microtask(() {
      ref.read(readMessageIdsProvider.notifier).loadReadMessageIds();
    });
  }

  Future<void> _refreshMessages() async {
    ref.invalidate(messagesProvider);
    await ref.read(messagesProvider.future);
    await ref.read(readMessageIdsProvider.notifier).loadReadMessageIds();
  }

  void _onMessageTap(Message message) {
    // Mark as read
    ref.read(readMessageIdsProvider.notifier).markAsRead(message.id);
    // Navigate to detail
    context.push('/messages/${message.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messagesAsync = ref.watch(messagesProvider);
    final readIds = ref.watch(readMessageIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        centerTitle: true,
        actions: [
          // Unread count badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ref.watch(unreadCountProvider) > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ref.watch(unreadCountProvider)}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
        child: messagesAsync.when(
          data: (messages) {
            if (messages.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '暂无消息',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isRead = readIds.contains(message.id);
                return MessageListItem(
                  message: message,
                  isRead: isRead,
                  onTap: () => _onMessageTap(message),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _refreshMessages,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
