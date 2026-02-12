import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/activity_service.dart';

/// Provider for activity state management
class ActivityProvider extends ChangeNotifier {
  final ActivityService _service = ActivityService();

  List<TodoItem> get todos => _service.todos;
  List<ActivityCard> get activities => _service.activities;
  int get streakDays => _service.streakDays;
  Map<String, int> get todayStats => _service.todayStats;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Initialize the provider
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _service.init();

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new todo item
  Future<void> addTodo(String text) async {
    await _service.addTodo(text);
    notifyListeners();
  }

  /// Toggle todo item completion status
  Future<void> toggleTodo(String id) async {
    await _service.toggleTodo(id);
    notifyListeners();
  }

  /// Delete a todo item
  Future<void> deleteTodo(String id) async {
    await _service.deleteTodo(id);
    notifyListeners();
  }

  /// Add a new activity card
  Future<void> addActivity(ActivityCard activity) async {
    await _service.addActivity(activity);
    notifyListeners();
  }

  /// Record a translation activity
  Future<void> recordTranslation(String text) async {
    await _service.recordTranslation(text);
    notifyListeners();
  }

  /// Record a chat activity
  Future<void> recordChat(String topic) async {
    await _service.recordChat(topic);
    notifyListeners();
  }

  /// Record daily goal completion
  Future<void> recordDailyGoal() async {
    await _service.recordDailyGoal(todayStats);
    notifyListeners();
  }
}
