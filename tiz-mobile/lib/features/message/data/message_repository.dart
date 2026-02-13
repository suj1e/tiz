import '../domain/message.dart';

/// Abstract repository for message operations
abstract class MessageRepository {
  /// Fetch all messages
  Future<List<Message>> getMessages();

  /// Mark a message as read
  Future<void> markAsRead(String messageId);

  /// Check if a message has been read
  Future<bool> isRead(String messageId);

  /// Get all read message IDs
  Future<Set<String>> getReadMessageIds();
}
