import '../domain/message.dart';
import '../domain/message_type.dart';
import 'message_repository.dart';

/// Mock implementation of MessageRepository for development
class MockMessageRepository implements MessageRepository {
  final Set<String> _readMessageIds = {};

  static final List<Message> _mockMessages = [
    Message(
      id: 'msg-001',
      type: MessageType.aiReminder,
      title: '会议提醒',
      summary: '您有一个下午3点的团队会议即将开始，请准时参加。',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Message(
      id: 'msg-002',
      type: MessageType.webhook,
      title: '部署完成通知',
      summary: '生产环境 v2.1.0 版本部署成功，所有服务运行正常。',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      actionUrl: 'https://dashboard.example.com/deployments/123',
    ),
    Message(
      id: 'msg-003',
      type: MessageType.aiReminder,
      title: '待办事项提醒',
      summary: '您有3个待办事项即将到期，请及时处理。',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Message(
      id: 'msg-004',
      type: MessageType.webhook,
      title: '新用户注册',
      summary: '今日新增用户 128 人，较昨日增长 15%。',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      actionUrl: 'https://dashboard.example.com/users',
    ),
    Message(
      id: 'msg-005',
      type: MessageType.aiReminder,
      title: '周报提醒',
      summary: '本周周报截止时间为周五下午5点，请及时提交。',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Message>> getMessages() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMessages;
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _readMessageIds.add(messageId);
  }

  @override
  Future<bool> isRead(String messageId) async {
    return _readMessageIds.contains(messageId);
  }

  @override
  Future<Set<String>> getReadMessageIds() async {
    return Set.from(_readMessageIds);
  }
}
