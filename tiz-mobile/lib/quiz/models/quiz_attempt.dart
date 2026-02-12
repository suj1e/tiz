/// Quiz attempt record model
/// Tracks individual question attempts for statistics

import '../../features/quiz/models.dart';

/// Record of a single question attempt
class QuizAttempt {
  /// Unique identifier for this attempt
  final String id;

  /// ID of the question attempted
  final String questionId;

  /// The answer option selected by user (0-3)
  final int selectedAnswer;

  /// Whether the answer was correct
  final bool isCorrect;

  /// When this attempt was made
  final DateTime timestamp;

  /// Time spent on this question in seconds
  final int timeSpent;

  /// Category of the question
  final QuizCategory category;

  QuizAttempt({
    required this.id,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timestamp,
    required this.timeSpent,
    required this.category,
  });

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'timeSpent': timeSpent,
      'category': category.name,
    };
  }

  /// Create from map
  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'] as String,
      questionId: map['questionId'] as String,
      selectedAnswer: map['selectedAnswer'] as int,
      isCorrect: map['isCorrect'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      timeSpent: map['timeSpent'] as int,
      category: QuizCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => QuizCategory.english,
      ),
    );
  }

  /// Create a copy with modified fields
  QuizAttempt copyWith({
    String? id,
    String? questionId,
    int? selectedAnswer,
    bool? isCorrect,
    DateTime? timestamp,
    int? timeSpent,
    QuizCategory? category,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      timestamp: timestamp ?? this.timestamp,
      timeSpent: timeSpent ?? this.timeSpent,
      category: category ?? this.category,
    );
  }

  /// Calculate XP earned from this attempt
  int get earnedXP {
    if (!isCorrect) return 0;

    // Base XP
    int xp = 10;

    // Speed bonus
    if (timeSpent < 10) {
      xp += 5; // Fast answer bonus
    } else if (timeSpent < 30) {
      xp += 2; // Quick answer bonus
    }

    return xp;
  }

  /// Get formatted time spent
  String get formattedTime {
    if (timeSpent < 60) {
      return '${timeSpent}s';
    }
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    return '${minutes}m ${seconds}s';
  }
}
