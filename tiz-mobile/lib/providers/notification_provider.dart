import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/notification.dart' as app_model;

/// Notification Provider
/// Manages notification state with persistence using Hive
class NotificationProvider extends ChangeNotifier {
  List<app_model.Notification> _notifications = [];
  bool _isLoading = false;

  /// Get all notifications
  List<app_model.Notification> get notifications => _notifications;

  /// Get unread notifications
  List<app_model.Notification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Get unread count
  int get unreadCount => unreadNotifications.length;

  /// Get total count
  int get totalCount => _notifications.length;

  /// Check if loading
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _loadNotifications();
  }

  /// Load notifications from storage
  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Load from Hive storage
      // For now, initialize with sample notifications
      await Future.delayed(const Duration(milliseconds: 500));

      _notifications = [
        app_model.Notification.newFeature(
          featureName: 'AI深度思考模式',
          description: '体验AI深度思考功能，获得更详细的分析和解答',
          onTap: () {
            debugPrint('Navigate to deep thinking settings');
          },
        ),
        app_model.Notification.translationComplete(
          sourceText: 'Hello, how are you?',
          targetText: '你好，你好吗？',
          onTap: () {
            debugPrint('View translation history');
          },
        ),
        app_model.Notification.learningReminder(
          subject: '英语词汇',
          onTap: () {
            debugPrint('Start vocabulary practice');
          },
        ),
      ];
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a notification
  void addNotification(app_model.Notification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
    _saveNotifications();
  }

  /// Add translation complete notification
  void addTranslationNotification({
    String? sourceText,
    String? targetText,
    VoidCallback? onTap,
  }) {
    addNotification(
      app_model.Notification.translationComplete(
        sourceText: sourceText,
        targetText: targetText,
        onTap: onTap,
      ),
    );
  }

  /// Add new feature notification
  void addFeatureNotification({
    required String featureName,
    String? description,
    VoidCallback? onTap,
  }) {
    addNotification(
      app_model.Notification.newFeature(
        featureName: featureName,
        description: description,
        onTap: onTap,
      ),
    );
  }

  /// Add learning reminder notification
  void addLearningReminder({
    String? subject,
    VoidCallback? onTap,
  }) {
    addNotification(
      app_model.Notification.learningReminder(
        subject: subject,
        onTap: onTap,
      ),
    );
  }

  /// Add system notification
  void addSystemNotification({
    required String message,
    VoidCallback? onTap,
  }) {
    addNotification(
      app_model.Notification.system(
        message: message,
        onTap: onTap,
      ),
    );
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].markAsRead();
      notifyListeners();
      _saveNotifications();
    }
  }

  /// Mark notification as unread
  void markAsUnread(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].markAsUnread();
      notifyListeners();
      _saveNotifications();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.markAsRead()).toList();
    notifyListeners();
    _saveNotifications();
  }

  /// Delete a notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    _saveNotifications();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
    _saveNotifications();
  }

  /// Clear only read notifications
  void clearRead() {
    _notifications = _notifications.where((n) => !n.isRead).toList();
    notifyListeners();
    _saveNotifications();
  }

  /// Get notifications by type
  List<app_model.Notification> getNotificationsByType(
    app_model.NotificationType type,
  ) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get recent notifications (within last 24 hours)
  List<app_model.Notification> getRecentNotifications() {
    return _notifications.where((n) => n.isRecent).toList();
  }

  /// Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      // TODO: Save to Hive storage
      // For now, just log
      if (kDebugMode) {
        debugPrint('Saving ${_notifications.length} notifications');
      }
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Refresh notifications (reload from storage)
  Future<void> refresh() async {
    await _loadNotifications();
  }
}
