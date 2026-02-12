import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Notification Type Enum
enum NotificationType {
  translationComplete,
  newFeature,
  learningReminder,
  system,
}

/// Notification Model
/// Represents a single notification
class Notification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final VoidCallback? onTap;

  Notification({
    String? id,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.isRead = false,
    required this.type,
    this.onTap,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  /// Create from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.system,
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
    };
  }

  /// Create translation complete notification
  factory Notification.translationComplete({
    String? sourceText,
    String? targetText,
    VoidCallback? onTap,
  }) {
    return Notification(
      title: '翻译完成',
      body: sourceText != null ? '已翻译: ${sourceText.substring(0, sourceText.length > 20 ? 20 : sourceText.length)}...' : '翻译已完成',
      type: NotificationType.translationComplete,
      onTap: onTap,
    );
  }

  /// Create new feature notification
  factory Notification.newFeature({
    required String featureName,
    String? description,
    VoidCallback? onTap,
  }) {
    return Notification(
      title: '新功能上线',
      body: description ?? '欢迎使用$featureName功能',
      type: NotificationType.newFeature,
      onTap: onTap,
    );
  }

  /// Create learning reminder notification
  factory Notification.learningReminder({
    String? subject,
    VoidCallback? onTap,
  }) {
    return Notification(
      title: '学习提醒',
      body: subject != null ? '该复习$subject了' : '坚持学习，每天进步一点点',
      type: NotificationType.learningReminder,
      onTap: onTap,
    );
  }

  /// Create system notification
  factory Notification.system({
    required String message,
    VoidCallback? onTap,
  }) {
    return Notification(
      title: '系统通知',
      body: message,
      type: NotificationType.system,
      onTap: onTap,
    );
  }

  /// Mark as read
  Notification markAsRead() {
    return Notification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: true,
      type: type,
      onTap: onTap,
    );
  }

  /// Mark as unread
  Notification markAsUnread() {
    return Notification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: false,
      type: type,
      onTap: onTap,
    );
  }

  /// Copy with method
  Notification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    VoidCallback? onTap,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      onTap: onTap ?? this.onTap,
    );
  }

  /// Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours < 24;
  }

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: ${type.name}, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Notification &&
        other.id == id &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^ isRead.hashCode;
  }
}

/// Notification Type Extension
extension NotificationTypeExtension on NotificationType {
  /// Get icon for notification type
  String get icon {
    switch (this) {
      case NotificationType.translationComplete:
        return 'translate';
      case NotificationType.newFeature:
        return 'stars';
      case NotificationType.learningReminder:
        return 'school';
      case NotificationType.system:
        return 'info_outline';
    }
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case NotificationType.translationComplete:
        return '翻译完成';
      case NotificationType.newFeature:
        return '新功能';
      case NotificationType.learningReminder:
        return '学习提醒';
      case NotificationType.system:
        return '系统通知';
    }
  }
}
