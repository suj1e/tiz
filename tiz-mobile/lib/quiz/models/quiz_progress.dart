/// Quiz progress tracking model
/// Manages user's overall quiz progress and statistics

import '../../features/quiz/models.dart';
import 'quiz_status.dart';
import 'quiz_attempt.dart';

/// User's overall quiz progress
class QuizProgress {
  /// Map of question ID to its status
  final Map<String, QuestionStatus> questionStatuses;

  /// List of all attempts made
  final List<QuizAttempt> attempts;

  /// Current consecutive days of practice
  final int currentStreak;

  /// Best streak achieved
  final int bestStreak;

  /// Total XP earned
  final int totalXP;

  /// Last practice date
  final DateTime lastPracticeDate;

  /// Daily XP (resets each day)
  final int dailyXP;

  /// Last daily XP reset date
  final DateTime? lastDailyReset;

  QuizProgress({
    required this.questionStatuses,
    required this.attempts,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalXP = 0,
    required this.lastPracticeDate,
    this.dailyXP = 0,
    this.lastDailyReset,
  });

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'questionStatuses': questionStatuses.map(
        (key, value) => MapEntry(key, value.name),
      ),
      'attempts': attempts.map((a) => a.toMap()).toList(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalXP': totalXP,
      'lastPracticeDate': lastPracticeDate.millisecondsSinceEpoch,
      'dailyXP': dailyXP,
      'lastDailyReset': lastDailyReset?.millisecondsSinceEpoch,
    };
  }

  /// Create from map
  factory QuizProgress.fromMap(Map<String, dynamic> map) {
    return QuizProgress(
      questionStatuses: Map<String, String>.from(
        map['questionStatuses'] as Map,
      ).map(
        (key, value) => MapEntry(
          key,
          QuestionStatus.values.firstWhere(
            (e) => e.name == value,
            orElse: () => QuestionStatus.notAttempted,
          ),
        ),
      ),
      attempts: (map['attempts'] as List)
          .map((e) => QuizAttempt.fromMap(e as Map<String, dynamic>))
          .toList(),
      currentStreak: map['currentStreak as int?'] ?? 0,
      bestStreak: map['bestStreak as int?'] ?? 0,
      totalXP: map['totalXP as int?'] ?? 0,
      lastPracticeDate:
          DateTime.fromMillisecondsSinceEpoch(map['lastPracticeDate'] as int),
      dailyXP: map['dailyXP as int?'] ?? 0,
      lastDailyReset: map['lastDailyReset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastDailyReset'] as int)
          : null,
    );
  }

  /// Create empty progress
  factory QuizProgress.empty() {
    return QuizProgress(
      questionStatuses: {},
      attempts: [],
      lastPracticeDate: DateTime.now(),
    );
  }

  /// Get statistics for a specific category
  CategoryStats getCategoryStats(QuizCategory category) {
    final prefix = _getCategoryPrefix(category);
    final categoryQuestions = questionStatuses.entries
        .where((e) => e.key.startsWith(prefix))
        .toList();

    final total = categoryQuestions.length;
    final attempted = categoryQuestions
        .where((e) => e.value.isAttempted)
        .length;
    final correct = categoryQuestions
        .where((e) => e.value == QuestionStatus.correct)
        .length;
    final wrong = categoryQuestions
        .where((e) => e.value == QuestionStatus.wrong)
        .length;
    final skipped = categoryQuestions
        .where((e) => e.value == QuestionStatus.skipped)
        .length;

    return CategoryStats(
      category: category,
      total: total,
      attempted: attempted,
      correct: correct,
      wrong: wrong,
      skipped: skipped,
      unattempted: total - attempted,
    );
  }

  /// Get status for a specific question
  QuestionStatus getQuestionStatus(String questionId) {
    return questionStatuses[questionId] ?? QuestionStatus.notAttempted;
  }

  /// Check if daily XP needs reset
  bool needsDailyReset() {
    if (lastDailyReset == null) return true;
    final now = DateTime.now();
    final lastReset = lastDailyReset!;
    return now.day != lastReset.day ||
        now.month != lastReset.month ||
        now.year != lastReset.year;
  }

  /// Get formatted total XP
  String get formattedTotalXP {
    if (totalXP >= 1000) {
      return '${(totalXP / 1000).toStringAsFixed(1)}k';
    }
    return totalXP.toString();
  }

  String _getCategoryPrefix(QuizCategory category) {
    switch (category) {
      case QuizCategory.english:
        return 'en';
      case QuizCategory.japanese:
        return 'jp';
      case QuizCategory.german:
        return 'de';
    }
  }

  /// Create a copy with updated fields
  QuizProgress copyWith({
    Map<String, QuestionStatus>? questionStatuses,
    List<QuizAttempt>? attempts,
    int? currentStreak,
    int? bestStreak,
    int? totalXP,
    DateTime? lastPracticeDate,
    int? dailyXP,
    DateTime? lastDailyReset,
  }) {
    return QuizProgress(
      questionStatuses: questionStatuses ?? this.questionStatuses,
      attempts: attempts ?? this.attempts,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalXP: totalXP ?? this.totalXP,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      dailyXP: dailyXP ?? this.dailyXP,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
    );
  }
}

/// Category statistics
class CategoryStats {
  final QuizCategory category;
  final int total;
  final int attempted;
  final int correct;
  final int wrong;
  final int skipped;
  final int unattempted;

  CategoryStats({
    required this.category,
    required this.total,
    required this.attempted,
    required this.correct,
    this.wrong = 0,
    this.skipped = 0,
    this.unattempted = 0,
  });

  /// Calculate accuracy (0.0 to 1.0)
  double get accuracy => attempted > 0 ? correct / attempted : 0.0;

  /// Calculate progress (0.0 to 1.0)
  double get progress => total > 0 ? attempted / total : 0.0;

  /// Get accuracy percentage
  int get accuracyPercentage => (accuracy * 100).round();

  /// Get progress percentage
  int get progressPercentage => (progress * 100).round();

  /// Get category label
  String get categoryLabel {
    switch (category) {
      case QuizCategory.english:
        return '英语';
      case QuizCategory.japanese:
        return '日本語';
      case QuizCategory.german:
        return '德语';
    }
  }
}
