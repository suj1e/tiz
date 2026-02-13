import '../repository/chat_repository.dart';

class ChatMockData {
  ChatMockData._();

  static final List<Conversation> conversations = [
    Conversation(
      id: 'conv_001',
      name: 'Spanish Study Group',
      avatar: null,
      lastMessage: 'Anyone want to practice Spanish?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 3,
    ),
    Conversation(
      id: 'conv_002',
      name: 'French Learning Circle',
      avatar: null,
      lastMessage: 'Great session today!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
    ),
    Conversation(
      id: 'conv_003',
      name: 'Language Exchange',
      avatar: null,
      lastMessage: 'See you tomorrow!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
  ];

  static final Map<String, List<Message>> messages = {
    'conv_001': [
      Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        content: 'Hola! How is everyone doing?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: 'msg_002',
        conversationId: 'conv_001',
        content: 'Doing great! Learning a lot.',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Message(
        id: 'msg_003',
        conversationId: 'conv_001',
        content: 'Anyone want to practice Spanish?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
    'conv_002': [
      Message(
        id: 'msg_004',
        conversationId: 'conv_002',
        content: 'Bonjour!',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'msg_005',
        conversationId: 'conv_002',
        content: 'Great session today!',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  };
}
