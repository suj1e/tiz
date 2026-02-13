/// Chat page data repository
abstract class ChatRepository {
  /// Get conversations list
  Future<List<Conversation>> getConversations();

  /// Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId);
}

/// Conversation model
class Conversation {
  final String id;
  final String name;
  final String? avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.name,
    this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

/// Message model
class Message {
  final String id;
  final String conversationId;
  final String content;
  final bool isMe;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.isMe,
    required this.timestamp,
  });
}
