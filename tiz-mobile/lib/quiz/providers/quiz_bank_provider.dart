/// Quiz Bank Provider
/// Manages question bank state and filtering

import 'package:flutter/foundation.dart';
import '../../features/quiz/models.dart';
import '../models/quiz_filter.dart';
import '../models/quiz_status.dart';
import '../services/quiz_bank_service.dart';
import 'quiz_progress_provider.dart';

/// Manages question bank state
class QuizBankProvider with ChangeNotifier {
  final QuizBankService _service;
  final QuizProgressProvider _progressProvider;

  QuizFilter _filter = const QuizFilter();
  List<QuizQuestion> _filteredQuestions = [];
  bool _isLoading = false;
  String? _selectedCategory;

  QuizBankProvider(this._service, this._progressProvider) {
    _selectedCategory = null; // Show all categories by default
    _loadQuestions();
  }

  // Getters
  List<QuizQuestion> get filteredQuestions => _filteredQuestions;
  QuizFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;

  /// Get question status
  QuestionStatus getQuestionStatus(String questionId) {
    return _progressProvider.getQuestionStatus(questionId);
  }

  /// Update filter and refresh list
  void updateFilter(QuizFilter newFilter) {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filter = const QuizFilter();
    _applyFilter();
    notifyListeners();
  }

  /// Set category filter
  void setCategory(QuizCategory? category) {
    _selectedCategory = category?.name;
    _filter = _filter.copyWith(category: category);
    _applyFilter();
    notifyListeners();
  }

  /// Set difficulty filter
  void setDifficulty(QuizDifficulty? difficulty) {
    _filter = _filter.copyWith(difficulty: difficulty);
    _applyFilter();
    notifyListeners();
  }

  /// Set status filter
  void setStatus(QuestionStatus? status) {
    _filter = _filter.copyWith(status: status);
    _applyFilter();
    notifyListeners();
  }

  /// Get questions by status for a category
  List<QuizQuestion> getQuestionsByStatus(
    QuizCategory category,
    QuestionStatus status,
  ) {
    return _service
        .getQuestionsByCategory(category)
        .where((q) => getQuestionStatus(q.id) == status)
        .toList();
  }

  /// Get all questions for a category
  List<QuizQuestion> getQuestionsForCategory(QuizCategory category) {
    return _service.getQuestionsByCategory(category);
  }

  /// Get question by ID
  QuizQuestion? getQuestionById(String id) {
    return _service.getQuestionById(id);
  }

  void _loadQuestions() {
    _isLoading = true;
    notifyListeners();

    // Load from service (synchronous for mock data)
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  void _applyFilter() {
    var questions = _service.getAllQuestions();

    // Apply category filter
    if (_filter.category != null) {
      questions = _service.getQuestionsByCategory(_filter.category!);
    }

    // Apply difficulty filter
    if (_filter.difficulty != null) {
      questions =
          questions.where((q) => q.difficulty == _filter.difficulty).toList();
    }

    // Apply status filter
    if (_filter.status != null) {
      questions = questions.where((q) {
        final status = getQuestionStatus(q.id);
        return status == _filter.status;
      }).toList();
    }

    // Apply tag filter
    if (_filter.tagFilter != null && _filter.tagFilter!.isNotEmpty) {
      questions = questions
          .where((q) => q.tags?.contains(_filter.tagFilter!) ?? false)
          .toList();
    }

    // Sort by orderIndex
    questions.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

    _filteredQuestions = questions;
  }

  /// Get category statistics
  Map<QuizCategory, CategoryStats> getCategoryStats() {
    return _progressProvider.getAllCategoryStats();
  }

  /// Get total question count across all categories
  int get totalQuestionCount {
    return QuizCategory.values.fold(
      0,
      (sum, category) => sum + _service.getCountByCategory(category),
    );
  }

  /// Get attempted question count
  int get attemptedQuestionCount {
    final allQuestions = _service.getAllQuestions();
    return allQuestions
        .where((q) => getQuestionStatus(q.id).isAttempted)
        .length;
  }

  /// Get correct answer count
  int get correctAnswerCount {
    final allQuestions = _service.getAllQuestions();
    return allQuestions
        .where((q) => getQuestionStatus(q.id) == QuestionStatus.correct)
        .length;
  }
}
