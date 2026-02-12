/// Quiz Practice Provider
/// Manages active practice session state

import 'package:flutter/foundation.dart';
import '../../features/quiz/models.dart';
import '../models/quiz_status.dart';
import '../services/quiz_bank_service.dart';
import 'quiz_progress_provider.dart';

/// Practice mode enum
enum PracticeMode {
  /// All questions in sequence
  continuous,

  /// Only previously wrong answers
  wrongAnswers,

  /// Only unattempted questions
  unattempted,

  /// Random selection
  random,
}

/// Manages active practice session
class QuizPracticeProvider extends ChangeNotifier {
  final QuizBankService _bankService;
  final QuizProgressProvider _progressProvider;

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _hasSubmitted = false;
  bool _isCompleted = false;
  DateTime? _startTime;
  int _elapsedSeconds = 0;

  // Practice configuration
  PracticeMode _mode = PracticeMode.continuous;
  bool _allowSkip = true;
  bool _instantFeedback = true;

  QuizPracticeProvider(
    this._bankService,
    this._progressProvider,
  );

  // Getters
  QuizQuestion? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  bool get hasSubmitted => _hasSubmitted;
  bool get isCompleted => _isCompleted;
  bool get canGoBack => _currentIndex > 0;
  bool get canGoNext => _currentIndex < _questions.length - 1;
  double get progress =>
      _questions.isEmpty ? 0 : _currentIndex / _questions.length;
  int get elapsedSeconds => _elapsedSeconds;
  int? get selectedAnswer => _selectedAnswer;

  /// Session statistics
  int get correctCount {
    return _questions
        .take(_currentIndex)
        .where((q) => _progressProvider.getQuestionStatus(q.id) == QuestionStatus.correct)
        .length;
  }

  int get wrongCount {
    return _questions
        .take(_currentIndex)
        .where((q) => _progressProvider.getQuestionStatus(q.id) == QuestionStatus.wrong)
        .length;
  }

  /// Initialize practice session
  void initialize({
    required QuizCategory category,
    PracticeMode mode = PracticeMode.continuous,
    List<QuizDifficulty>? difficulties,
    int? questionLimit,
  }) {
    _mode = mode;
    _startTime = DateTime.now();
    _elapsedSeconds = 0;
    _currentIndex = 0;
    _isCompleted = false;
    _hasSubmitted = false;
    _selectedAnswer = null;

    // Load questions based on mode
    _questions = _loadQuestions(category, difficulties, questionLimit);

    notifyListeners();
  }

  /// Load questions based on mode
  List<QuizQuestion> _loadQuestions(
    QuizCategory category,
    List<QuizDifficulty>? difficulties,
    int? limit,
  ) {
    var questions = _bankService.getQuestionsByCategory(category);

    if (difficulties != null && difficulties.isNotEmpty) {
      questions =
          questions.where((q) => difficulties.contains(q.difficulty)).toList();
    }

    switch (_mode) {
      case PracticeMode.wrongAnswers:
        // Get only wrong answers
        questions = questions
            .where((q) =>
                _progressProvider.getQuestionStatus(q.id) == QuestionStatus.wrong)
            .toList();
        break;
      case PracticeMode.unattempted:
        // Get only unattempted
        questions = questions
            .where((q) =>
                _progressProvider.getQuestionStatus(q.id) == QuestionStatus.notAttempted)
            .toList();
        break;
      case PracticeMode.random:
        // Shuffle all questions
        questions = List.from(questions)..shuffle();
        break;
      case PracticeMode.continuous:
      default:
        // Keep original order
        break;
    }

    if (limit != null && questions.length > limit) {
      questions = questions.sublist(0, limit);
    }

    return questions;
  }

  /// Select an answer
  void selectAnswer(int index) {
    _selectedAnswer = index;
    notifyListeners();
  }

  /// Submit current answer
  Future<void> submitAnswer() async {
    if (_selectedAnswer == null || currentQuestion == null) return;

    final question = currentQuestion!;
    final isCorrect = _selectedAnswer == question.correctAnswer;

    await _progressProvider.recordAttempt(
      questionId: question.id,
      selectedAnswer: _selectedAnswer!,
      isCorrect: isCorrect,
      timeSpent: _elapsedSeconds,
      category: question.category,
    );

    _hasSubmitted = true;
    notifyListeners();

    if (_instantFeedback) {
      // Auto-advance after delay if correct
      await Future.delayed(const Duration(milliseconds: 1500));
      if (isCorrect && !isCompleted) {
        nextQuestion();
      }
    }
  }

  /// Skip current question
  Future<void> skipQuestion() async {
    if (currentQuestion == null) return;

    await _progressProvider.recordSkip(currentQuestion!.id);
    nextQuestion();
  }

  /// Move to next question
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _resetQuestion();
    } else {
      _isCompleted = true;
    }
    notifyListeners();
  }

  /// Move to previous question
  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetQuestion();
      notifyListeners();
    }
  }

  /// Jump to specific question
  void jumpToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      _resetQuestion();
      notifyListeners();
    }
  }

  void _resetQuestion() {
    _selectedAnswer = null;
    _hasSubmitted = false;
  }

  /// Update elapsed time
  void updateElapsedTime(int seconds) {
    _elapsedSeconds = seconds;
    // Don't notifyListeners here to avoid unnecessary rebuilds
  }

  /// End practice session
  void endSession() {
    _isCompleted = true;
    notifyListeners();
  }

  /// Check if question was already answered before this session
  bool wasAnsweredBefore(String questionId) {
    final status = _progressProvider.getQuestionStatus(questionId);
    return status.isAttempted;
  }

  /// Get result statistics
  PracticeResult getResults() {
    return PracticeResult(
      totalQuestions: _questions.length,
      correctCount: correctCount,
      wrongCount: wrongCount,
      skippedCount: _questions.length - correctCount - wrongCount,
      timeSpent: _elapsedSeconds,
    );
  }
}

/// Practice session result
class PracticeResult {
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int timeSpent;

  PracticeResult({
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.timeSpent,
  });

  int get attemptedCount => correctCount + wrongCount;
  double get accuracy =>
      attemptedCount > 0 ? correctCount / attemptedCount : 0.0;
  int get accuracyPercentage => (accuracy * 100).round();
  double get percentage =>
      totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
  bool get passed => percentage >= 0.6;

  String get formattedTime {
    if (timeSpent < 60) return '${timeSpent}s';
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    return '${minutes}m ${seconds}s';
  }

  int get earnedXP {
    return correctCount * 10 + (passed ? 50 : 0);
  }
}
