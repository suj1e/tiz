import 'package:flutter/foundation.dart';

import '../mock_data/chat_mock_data.dart';
import 'chat_repository.dart';

class MockChatRepository implements ChatRepository {
  @override
  Future<List<Conversation>> getConversations() async {
    debugPrint('[MockChatRepository] getConversations');
    return ChatMockData.conversations;
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    debugPrint('[MockChatRepository] getMessages: $conversationId');
    return ChatMockData.messages[conversationId] ?? [];
  }
}
