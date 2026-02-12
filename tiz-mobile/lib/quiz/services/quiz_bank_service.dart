/// Quiz Bank Service
/// Manages question bank data access

import '../../features/quiz/models.dart';
import '../models/quiz_status.dart';

/// Service for managing question bank data
class QuizBankService {
  /// Get all questions from all categories
  List<QuizQuestion> getAllQuestions() {
    return mockQuestions.values.expand((list) => list).toList();
  }

  /// Get questions by category
  List<QuizQuestion> getQuestionsByCategory(QuizCategory category) {
    return mockQuestions[category] ?? [];
  }

  /// Get questions by difficulty
  List<QuizQuestion> getQuestionsByDifficulty(QuizDifficulty difficulty) {
    return getAllQuestions()
        .where((q) => q.difficulty == difficulty)
        .toList();
  }

  /// Get question by ID
  QuizQuestion? getQuestionById(String id) {
    try {
      return getAllQuestions().firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get questions by status
  List<QuizQuestion> getQuestionsByStatus(
    QuizCategory category,
    QuestionStatus status,
    Map<String, QuestionStatus> statuses,
  ) {
    final categoryQuestions = getQuestionsByCategory(category);
    return categoryQuestions.where((q) {
      final questionStatus = statuses[q.id] ?? QuestionStatus.notAttempted;
      return questionStatus == status;
    }).toList();
  }

  /// Search questions by text (question or explanation)
  List<QuizQuestion> searchQuestions(String query) {
    if (query.isEmpty) return getAllQuestions();

    final lowerQuery = query.toLowerCase();
    return getAllQuestions().where((q) {
      return q.question.toLowerCase().contains(lowerQuery) ||
          q.explanation.toLowerCase().contains(lowerQuery) ||
          (q.tags?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get all unique tags across all questions
  List<String> getAllTags() {
    final tagSet = <String>{};
    for (final question in getAllQuestions()) {
      if (question.tags != null) {
        tagSet.addAll(question.tagList);
      }
    }
    return tagSet.toList()..sort();
  }

  /// Get tags for a specific category
  List<String> getTagsForCategory(QuizCategory category) {
    final tagSet = <String>{};
    for (final question in getQuestionsByCategory(category)) {
      if (question.tags != null) {
        tagSet.addAll(question.tagList);
      }
    }
    return tagSet.toList()..sort();
  }

  /// Count questions by category
  int getCountByCategory(QuizCategory category) {
    return getQuestionsByCategory(category).length;
  }

  /// Count questions by difficulty
  Map<QuizDifficulty, int> getCountByDifficulty() {
    final counts = <QuizDifficulty, int>{};
    for (final difficulty in QuizDifficulty.values) {
      counts[difficulty] = getQuestionsByDifficulty(difficulty).length;
    }
    return counts;
  }
}
