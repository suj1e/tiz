import 'message_type.dart';

class Message {
  final String id;
  final MessageType type;
  final String title;
  final String summary;
  final DateTime createdAt;
  final String? actionUrl;

  const Message({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.createdAt,
    this.actionUrl,
  });
}
