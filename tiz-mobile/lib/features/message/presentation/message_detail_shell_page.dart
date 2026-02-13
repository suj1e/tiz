import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../message_provider.dart';
import 'message_detail_page.dart';

/// Shell page that extracts message ID from route and renders MessageDetailPage
class MessageDetailShellPage extends ConsumerWidget {
  const MessageDetailShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageId = GoRouterState.of(context).pathParameters['messageId'];

    if (messageId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('消息详情')),
        body: const Center(
          child: Text('消息不存在'),
        ),
      );
    }

    final messageAsync = ref.watch(messagesProvider);

    return messageAsync.when(
      data: (messages) {
        final message = messages.where((m) => m.id == messageId).firstOrNull;

        if (message == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('消息详情')),
            body: const Center(
              child: Text('消息不存在'),
            ),
          );
        }

        return MessageDetailPage(message: message);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('消息详情')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('消息详情')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('加载失败'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(messagesProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
