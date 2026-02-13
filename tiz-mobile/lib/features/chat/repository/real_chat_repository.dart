import 'package:flutter/foundation.dart';

import 'chat_repository.dart';

class RealChatRepository implements ChatRepository {
  @override
  Future<List<Conversation>> getConversations() async {
    debugPrint('[RealChatRepository] getConversations - not implemented');
    return [];
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    debugPrint('[RealChatRepository] getMessages - not implemented');
    return [];
  }
}
