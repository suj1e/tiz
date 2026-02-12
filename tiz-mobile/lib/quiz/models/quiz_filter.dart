/// Quiz filter model
/// Used for filtering questions in the question bank

import 'quiz_status.dart';
import 'quiz_category.dart';
import 'quiz_difficulty.dart';
import 'quiz_models.dart' show QuizQuestion;

/// Filter options for question bank
class QuizFilter {
  final QuizCategory? category;
  final QuizDifficulty? difficulty;
  final QuestionStatus? status;
  final String? tagFilter;

  const QuizFilter({
    this.category,
    this.difficulty,
    this.status,
    this.tagFilter,
  });

  /// Empty filter (show all)
  static const all = QuizFilter();

  /// Copy with modified values
  QuizFilter copyWith({
    QuizCategory? category,
    QuizDifficulty? difficulty,
    QuestionStatus? status,
    String? tagFilter,
    bool clearCategory = false,
    bool clearDifficulty = false,
    bool clearStatus = false,
    bool clearTag = false,
  }) {
    return QuizFilter(
      category: clearCategory ? null : (category ?? this.category),
      difficulty:
          clearDifficulty ? null : (difficulty ?? this.difficulty),
      status: clearStatus ? null : (status ?? this.status),
      tagFilter: clearTag ? null : (tagFilter ?? this.tagFilter),
    );
  }

  /// Check if filter is active (any filter is set)
  bool get isActive =>
      category != null ||
      difficulty != null ||
      status != null ||
      (tagFilter != null && tagFilter!.isNotEmpty);

  /// Check if a question matches this filter
  bool matches(
    QuizQuestion question,
    QuestionStatus questionStatus,
  ) {
    if (category != null && question.category != category) {
      return false;
    }

    if (difficulty != null && question.difficulty != difficulty) {
      return false;
    }

    if (status != null && questionStatus != status) {
      return false;
    }

    if (tagFilter != null &&
        tagFilter!.isNotEmpty &&
        !(question.tags?.contains(tagFilter!) ?? false)) {
      return false;
    }

    return true;
  }

  /// Get filter description
  String get description {
    final parts = <String>[];

    if (category != null) {
      parts.add(_categoryLabel(category!));
    }

    if (difficulty != null) {
      parts.add(_difficultyLabel(difficulty!));
    }

    if (status != null) {
      parts.add(status!.label);
    }

    if (tagFilter != null && tagFilter!.isNotEmpty) {
      parts.add(tagFilter!);
    }

    return parts.isEmpty ? '全部' : parts.join(' · ');
  }

  String _categoryLabel(QuizCategory category) {
    switch (category) {
      case QuizCategory.english:
        return '英语';
      case QuizCategory.japanese:
        return '日本語';
      case QuizCategory.german:
        return '德语';
    }
  }

  String _difficultyLabel(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return '初级';
      case QuizDifficulty.intermediate:
        return '中级';
      case QuizDifficulty.advanced:
        return '高级';
    }
  }

  @override
  String toString() => description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizFilter &&
        other.category == category &&
        other.difficulty == difficulty &&
        other.status == status &&
        other.tagFilter == tagFilter;
  }

  @override
  int get hashCode =>
      category.hashCode ^
      difficulty.hashCode ^
      status.hashCode ^
      tagFilter.hashCode;
}
