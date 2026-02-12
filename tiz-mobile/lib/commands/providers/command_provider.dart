import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Command Status Enum
enum CommandStatus {
  pending,
  running,
  completed,
  failed,
}

/// Command Task Model
/// Represents a command execution task
class CommandTask {
  final String id;
  final String command;
  final CommandStatus status;
  final String? currentStep;
  final double progress;
  final String? result;
  final DateTime createdAt;
  final DateTime? completedAt;

  CommandTask({
    String? id,
    required this.command,
    this.status = CommandStatus.pending,
    this.currentStep,
    this.progress = 0.0,
    this.result,
    DateTime? createdAt,
    this.completedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory CommandTask.fromJson(Map<String, dynamic> json) {
    return CommandTask(
      id: json['id'] as String,
      command: json['command'] as String,
      status: CommandStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CommandStatus.pending,
      ),
      currentStep: json['currentStep'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      result: json['result'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'command': command,
      'status': status.name,
      'currentStep': currentStep,
      'progress': progress,
      'result': result,
      'createdAt': createdAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  /// Copy with method
  CommandTask copyWith({
    String? id,
    String? command,
    CommandStatus? status,
    String? currentStep,
    double? progress,
    String? result,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return CommandTask(
      id: id ?? this.id,
      command: command ?? this.command,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if task is active
  bool get isActive => status == CommandStatus.pending || status == CommandStatus.running;

  /// Get status text
  String get statusText {
    switch (status) {
      case CommandStatus.pending:
        return '等待中';
      case CommandStatus.running:
        return '执行中';
      case CommandStatus.completed:
        return '完成';
      case CommandStatus.failed:
        return '失败';
    }
  }

  @override
  String toString() {
    return 'CommandTask(id: $id, command: $command, status: ${status.name}, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommandTask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Command Provider
/// Manages command execution state across the app
class CommandProvider extends ChangeNotifier {
  // All command tasks
  final List<CommandTask> _tasks = [];

  // Active command (currently executing)
  CommandTask? _activeTask;

  /// Get all tasks
  List<CommandTask> get tasks => List.unmodifiable(_tasks);

  /// Get active tasks (pending or running)
  List<CommandTask> get activeTasks => _tasks.where((t) => t.isActive).toList();

  /// Get completed tasks
  List<CommandTask> get completedTasks => _tasks.where((t) => t.status == CommandStatus.completed).toList();

  /// Get failed tasks
  List<CommandTask> get failedTasks => _tasks.where((t) => t.status == CommandStatus.failed).toList();

  /// Get currently active task
  CommandTask? get activeTask => _activeTask;

  /// Get recent tasks (last 5)
  List<CommandTask> get recentTasks {
    final sorted = List<CommandTask>.from(_tasks);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  /// Add a new command task
  CommandTask addCommand(String command) {
    final task = CommandTask(
      command: command,
      status: CommandStatus.pending,
      progress: 0.0,
    );

    _tasks.add(task);
    notifyListeners();
    return task;
  }

  /// Start executing a command
  void startCommand(String command) {
    final task = addCommand(command);
    _activeTask = task.copyWith(status: CommandStatus.running);
    _updateTask(task);
  }

  /// Update task progress
  void updateProgress(String taskId, double progress, String? currentStep) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        progress: progress.clamp(0.0, 1.0),
        currentStep: currentStep,
      );

      // Update active task if matches
      if (_activeTask?.id == taskId) {
        _activeTask = _tasks[index];
      }

      notifyListeners();
    }
  }

  /// Complete a command
  void completeCommand(String taskId, {String? result}) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(
        status: CommandStatus.completed,
        progress: 1.0,
        result: result,
        completedAt: DateTime.now(),
      );

      // Clear active task if matches
      if (_activeTask?.id == taskId) {
        _activeTask = null;
      }

      notifyListeners();
    }
  }

  /// Fail a command
  void failCommand(String taskId, {String? error}) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(
        status: CommandStatus.failed,
        result: error ?? '执行失败',
        completedAt: DateTime.now(),
      );

      // Clear active task if matches
      if (_activeTask?.id == taskId) {
        _activeTask = null;
      }

      notifyListeners();
    }
  }

  /// Retry a failed command
  void retryCommand(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        status: CommandStatus.pending,
        progress: 0.0,
        result: null,
        completedAt: null,
      );
      notifyListeners();
    }
  }

  /// Clear completed tasks
  void clearCompleted() {
    _tasks.removeWhere((t) => t.status == CommandStatus.completed);
    notifyListeners();
  }

  /// Clear all tasks
  void clearAll() {
    _tasks.clear();
    _activeTask = null;
    notifyListeners();
  }

  /// Remove a specific task
  void removeTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_activeTask?.id == taskId) {
      _activeTask = null;
    }
    notifyListeners();
  }

  /// Get task by ID
  CommandTask? getTask(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Update task internally
  void _updateTask(CommandTask updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index >= 0) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }
}
