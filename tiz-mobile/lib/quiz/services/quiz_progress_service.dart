/// Quiz Progress Service
/// Handles persistence of quiz progress using SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_progress.dart';

/// Service for persisting quiz progress
class QuizProgressService {
  static const String _storageKey = 'quiz_progress';

  /// Save progress to storage
  Future<void> saveProgress(QuizProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(progress.toMap());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      // Silently fail - in production would log this
      print('Error saving quiz progress: $e');
    }
  }

  /// Load progress from storage
  Future<QuizProgress?> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json == null) return null;

      final map = jsonDecode(json) as Map<String, dynamic>;
      return QuizProgress.fromMap(map);
    } catch (e) {
      // Return null on error - start fresh
      print('Error loading quiz progress: $e');
      return null;
    }
  }

  /// Clear all progress
  Future<void> clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing quiz progress: $e');
    }
  }

  /// Export progress as JSON string
  String exportProgress(QuizProgress progress) {
    return jsonEncode(progress.toMap());
  }

  /// Import progress from JSON string
  QuizProgress? importProgress(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return QuizProgress.fromMap(map);
    } catch (e) {
      print('Error importing quiz progress: $e');
      return null;
    }
  }

  /// Check if progress exists
  Future<bool> hasProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_storageKey);
  }
}
