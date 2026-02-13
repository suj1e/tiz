enum MessageType {
  aiReminder('AI 提醒'),
  webhook('Webhook 推送');

  final String label;
  const MessageType(this.label);
}
