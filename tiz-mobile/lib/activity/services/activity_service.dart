import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

/// Service for managing activity data with local persistence
class ActivityService {
  static const String _todosKey = 'tiz_todos';
  static const String _activitiesKey = 'tiz_activities';
  static const String _streakKey = 'tiz_streak_days';
  static const String _lastActiveKey = 'tiz_last_active_date';

  List<TodoItem> _todos = [];
  List<ActivityCard> _activities = [];
  int _streakDays = 0;

  // Getters
  List<TodoItem> get todos => _todos;
  List<ActivityCard> get activities => _activities;
  int get streakDays => _streakDays;

  /// Get today's statistics
  Map<String, int> get todayStats {
    final today = DateTime.now();
    final todayActivities = _activities.where((activity) {
      return activity.timestamp.year == today.year &&
          activity.timestamp.month == today.month &&
          activity.timestamp.day == today.day;
    }).toList();

    final stats = <String, int>{
      'translations': 0,
      'chats': 0,
      'goalsCompleted': 0,
    };

    for (final activity in todayActivities) {
      switch (activity.type) {
        case ActivityType.translation:
          stats['translations'] = (stats['translations'] ?? 0) + 1;
          break;
        case ActivityType.chat:
          stats['chats'] = (stats['chats'] ?? 0) + 1;
          break;
        case ActivityType.goalCompleted:
          stats['goalsCompleted'] = (stats['goalsCompleted'] ?? 0) + 1;
          break;
        default:
          break;
      }
    }

    return stats;
  }

  /// Initialize service and load data from storage
  Future<void> init() async {
    await _loadTodos();
    await _loadActivities();
    await _loadStreak();
    await _updateStreak();
  }

  /// Add a new todo item
  Future<void> addTodo(String text) async {
    final todo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
    );
    _todos.add(todo);
    await _saveTodos();
  }

  /// Toggle todo item completion status
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = _todos[index];
      final updatedTodo = todo.copyWith(isDone: !todo.isDone);
      _todos[index] = updatedTodo;

      // If newly completed, add activity card
      if (updatedTodo.isDone && !todo.isDone) {
        await addActivity(ActivityCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          icon: '🎯',
          title: '完成了一个小目标',
          description: updatedTodo.text,
          type: ActivityType.goalCompleted,
        ));
      }

      await _saveTodos();
    }
  }

  /// Delete a todo item
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await _saveTodos();
  }

  /// Add a new activity card
  Future<void> addActivity(ActivityCard activity) async {
    _activities.insert(0, activity);
    // Keep only last 50 activities
    if (_activities.length > 50) {
      _activities = _activities.sublist(0, 50);
    }
    await _saveActivities();
  }

  /// Record a translation activity
  Future<void> recordTranslation(String text) async {
    await addActivity(ActivityCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      icon: '📝',
      title: '刚翻译了一段文字',
      description: text.length > 50
          ? '${text.substring(0, 50)}...'
          : text,
      type: ActivityType.translation,
    ));
  }

  /// Record a chat activity
  Future<void> recordChat(String topic) async {
    await addActivity(ActivityCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      icon: '💬',
      title: '和AI聊了会天',
      description: topic,
      type: ActivityType.chat,
    ));
  }

  /// Record daily goal completion
  Future<void> recordDailyGoal(Map<String, int> stats) async {
    final parts = <String>[];
    if ((stats['translations'] ?? 0) > 0) {
      parts.add('翻译${stats['translations']}次');
    }
    if ((stats['chats'] ?? 0) > 0) {
      parts.add('对话${stats['chats']}次');
    }
    if ((stats['goalsCompleted'] ?? 0) > 0) {
      parts.add('完成${stats['goalsCompleted']}个目标');
    }

    if (parts.isNotEmpty) {
      await addActivity(ActivityCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        icon: '🎯',
        title: '完成了每日目标',
        description: parts.join(' · '),
        type: ActivityType.dailyGoal,
      ));
    }
  }

  /// Update streak based on daily activity
  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString(_lastActiveKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastActiveStr == null) {
      // First time
      _streakDays = 1;
    } else {
      final lastActive = DateTime.parse(lastActiveStr);
      final difference = today.difference(lastActive);

      if (difference.inDays == 0) {
        // Same day, keep streak
      } else if (difference.inDays == 1) {
        // Consecutive day, increment streak
        _streakDays++;
      } else {
        // Streak broken, reset to 1
        _streakDays = 1;
      }
    }

    await prefs.setInt(_streakKey, _streakDays);
    await prefs.setString(_lastActiveKey, today.toIso8601String());
  }

  // Private methods for persistence

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_todosKey);
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _todos = decoded
          .map((item) => TodoItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString(_todosKey, todosJson);
  }

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey);
    if (activitiesJson != null) {
      final List<dynamic> decoded = jsonDecode(activitiesJson);
      _activities = decoded
          .map((item) => ActivityCard.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson =
        jsonEncode(_activities.map((a) => a.toJson()).toList());
    await prefs.setString(_activitiesKey, activitiesJson);
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _streakDays = prefs.getInt(_streakKey) ?? 0;
  }
}
