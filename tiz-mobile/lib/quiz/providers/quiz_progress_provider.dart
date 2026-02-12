/// Quiz Progress Provider
/// Manages user quiz progress state

import 'package:flutter/foundation.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_status.dart';
import '../models/quiz_attempt.dart';
import '../services/quiz_progress_service.dart';
import '../../features/quiz/models.dart';

/// Manages user quiz progress
class QuizProgressProvider extends ChangeNotifier {
  final QuizProgressService _service;

  QuizProgress _progress = QuizProgress.empty();

  QuizProgressProvider(this._service) {
    _loadProgress();
  }

  // Getters
  QuizProgress get progress => _progress;
  int get currentStreak => _progress.currentStreak;
  int get bestStreak => _progress.bestStreak;
  int get totalXP => _progress.totalXP;
  int get dailyXP => _progress.dailyXP;

  /// Get status for a specific question
  QuestionStatus getQuestionStatus(String questionId) {
    return _progress.getQuestionStatus(questionId);
  }

  /// Load progress from storage
  Future<void> _loadProgress() async {
    final loaded = await _service.loadProgress();
    if (loaded != null) {
      _progress = loaded;
      _checkDailyReset();
    }
    notifyListeners();
  }

  /// Check if daily XP needs reset
  void _checkDailyReset() {
    if (_progress.needsDailyReset()) {
      _progress = QuizProgress(
        questionStatuses: _progress.questionStatuses,
        attempts: _progress.attempts,
        currentStreak: _progress.currentStreak,
        bestStreak: _progress.bestStreak,
        totalXP: _progress.totalXP,
        lastPracticeDate: _progress.lastPracticeDate,
        dailyXP: 0,
        lastDailyReset: DateTime.now(),
      );
    }
  }

  /// Record an attempt
  Future<void> recordAttempt({
    required String questionId,
    required int selectedAnswer,
    required bool isCorrect,
    required int timeSpent,
    required QuizCategory category,
  }) async {
    final attempt = QuizAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      questionId: questionId,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
      timeSpent: timeSpent,
      category: category,
    );

    // Update progress
    final newStatus = isCorrect ? QuestionStatus.correct : QuestionStatus.wrong;
    final updatedQuestionStatuses = Map<String, QuestionStatus>.from(_progress.questionStatuses)
      ..[questionId] = newStatus;
    final updatedAttempts = List<QuizAttempt>.from(_progress.attempts)..add(attempt);

    // Update XP and streak
    int newTotalXP = _progress.totalXP;
    int newDailyXP = _progress.dailyXP;
    int newCurrentStreak = _progress.currentStreak;
    int newBestStreak = _progress.bestStreak;

    if (isCorrect) {
      final earnedXP = _calculateXP(timeSpent);
      newTotalXP += earnedXP;
      newDailyXP += earnedXP;
      newCurrentStreak++;
      if (newCurrentStreak > newBestStreak) {
        newBestStreak = newCurrentStreak;
      }
    } else {
      newCurrentStreak = 0;
    }

    _progress = _progress.copyWith(
      questionStatuses: updatedQuestionStatuses,
      attempts: updatedAttempts,
      totalXP: newTotalXP,
      dailyXP: newDailyXP,
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
      lastPracticeDate: DateTime.now(),
    );

    // Save to storage
    await _service.saveProgress(_progress);
    notifyListeners();
  }

  /// Record skip
  Future<void> recordSkip(String questionId) async {
    final updatedQuestionStatuses = Map<String, QuestionStatus>.from(_progress.questionStatuses)
      ..[questionId] = QuestionStatus.skipped;

    _progress = _progress.copyWith(
      questionStatuses: updatedQuestionStatuses,
      lastPracticeDate: DateTime.now(),
    );
    await _service.saveProgress(_progress);
    notifyListeners();
  }

  /// Get category statistics
  CategoryStats getCategoryStats(QuizCategory category) {
    return _progress.getCategoryStats(category);
  }

  /// Get all category statistics
  Map<QuizCategory, CategoryStats> getAllCategoryStats() {
    return {
      for (final category in QuizCategory.values)
        category: getCategoryStats(category),
    };
  }

  /// Clear all progress
  Future<void> clearProgress() async {
    _progress = QuizProgress.empty();
    await _service.clearProgress();
    notifyListeners();
  }

  int _calculateXP(int timeSpent) {
    // Base 10 XP, bonus for fast answers
    if (timeSpent < 10) return 15;
    if (timeSpent < 30) return 12;
    return 10;
  }

  /// Get formatted total XP
  String get formattedTotalXP {
    if (_progress.totalXP >= 1000) {
      return '${(_progress.totalXP / 1000).toStringAsFixed(1)}k';
    }
    return _progress.totalXP.toString();
  }

  /// Get daily XP progress (0.0 to 1.0)
  double get dailyProgress {
    return (_progress.dailyXP / 100).clamp(0.0, 1.0);
  }
}
