/// Activity card model for the activity feed
enum ActivityType {
  achievement, // 今日小成就
  streak, // 连续学习
  translation, // 翻译记录
  chat, // AI对话
  goalCompleted, // 完成目标
  dailyGoal, // 每日目标
}

class ActivityCard {
  final String id;
  final String icon; // Emoji icon
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  ActivityCard({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    DateTime? timestamp,
    required this.type,
  }) : timestamp = timestamp ?? DateTime.now();

  ActivityCard copyWith({
    String? id,
    String? icon,
    String? title,
    String? description,
    DateTime? timestamp,
    ActivityType? type,
  }) {
    return ActivityCard(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
    };
  }

  factory ActivityCard.fromJson(Map<String, dynamic> json) {
    return ActivityCard(
      id: json['id'] as String,
      icon: json['icon'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      type: ActivityType.values[json['type'] as int? ?? 0],
    );
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }
}
