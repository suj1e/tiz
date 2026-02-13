/// Explore page data repository
abstract class ExploreRepository {
  /// Get learning progress list
  Future<List<LearningProgress>> getLearningProgress();

  /// Get popular quiz list
  Future<List<QuizItem>> getPopularQuizzes();

  /// Get supported languages list
  Future<List<Language>> getLanguages();
}

/// Learning progress model
class LearningProgress {
  final String language;
  final String level;
  final double progress;
  final int lessonsLeft;

  const LearningProgress({
    required this.language,
    required this.level,
    required this.progress,
    required this.lessonsLeft,
  });
}

/// Quiz item model
class QuizItem {
  final String id;
  final String title;
  final int questions;
  final String difficulty;
  final String color;

  const QuizItem({
    required this.id,
    required this.title,
    required this.questions,
    required this.difficulty,
    required this.color,
  });
}

/// Language model
class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}
