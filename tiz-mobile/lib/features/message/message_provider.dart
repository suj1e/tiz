import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/message_repository.dart';
import 'data/mock_message_repository.dart';
import 'domain/message.dart';

/// Provider for the message repository
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MockMessageRepository();
});

/// Provider for all messages
final messagesProvider = FutureProvider<List<Message>>((ref) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getMessages();
});

/// Provider for a single message by ID
final messageByIdProvider = Provider.family<Message?, String>((ref, messageId) {
  final messagesAsync = ref.watch(messagesProvider);
  return messagesAsync.when(
    data: (messages) => messages.where((m) => m.id == messageId).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for read message IDs
final readMessageIdsProvider = StateNotifierProvider<ReadMessageIdsNotifier, Set<String>>((ref) {
  return ReadMessageIdsNotifier(ref);
});

/// Notifier for managing read message IDs
class ReadMessageIdsNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  ReadMessageIdsNotifier(this._ref) : super({});

  Future<void> loadReadMessageIds() async {
    final repository = _ref.read(messageRepositoryProvider);
    state = await repository.getReadMessageIds();
  }

  Future<void> markAsRead(String messageId) async {
    final repository = _ref.read(messageRepositoryProvider);
    await repository.markAsRead(messageId);
    state = {...state, messageId};
  }

  bool isRead(String messageId) {
    return state.contains(messageId);
  }
}

/// Provider for unread message count
final unreadCountProvider = Provider<int>((ref) {
  final messagesAsync = ref.watch(messagesProvider);
  final readIds = ref.watch(readMessageIdsProvider);

  return messagesAsync.when(
    data: (messages) => messages.where((m) => !readIds.contains(m.id)).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
