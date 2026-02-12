import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

/// Quiz question status enum and extension
/// Tracks the state of each question attempt

/// Status of a question attempt
enum QuestionStatus {
  /// Never tried this question
  notAttempted,
  /// Last attempt was correct
  correct,
  /// Last attempt was wrong
  wrong,
  /// Question was skipped
  skipped,
}

/// Extension for QuestionStatus with display helpers
extension QuestionStatusExtension on QuestionStatus {
  /// Get the display label in Chinese
  String get label {
    switch (this) {
      case QuestionStatus.notAttempted:
        return '未做';
      case QuestionStatus.correct:
        return '正确';
      case QuestionStatus.wrong:
        return '错误';
      case QuestionStatus.skipped:
        return '跳过';
    }
  }

  /// Get the icon character
  String get icon {
    switch (this) {
      case QuestionStatus.notAttempted:
        return '○';
      case QuestionStatus.correct:
        return '✓';
      case QuestionStatus.wrong:
        return '✕';
      case QuestionStatus.skipped:
        return '→';
    }
  }

  /// Get the Material icon
  /// Use for Icon() widget
  IconData get materialIcon {
    switch (this) {
      case QuestionStatus.notAttempted:
        return Icons.radio_button_unchecked;
      case QuestionStatus.correct:
        return Icons.check_circle;
      case QuestionStatus.wrong:
        return Icons.cancel;
      case QuestionStatus.skipped:
        return Icons.skip_next;
    }
  }

  /// Check if status indicates a completed attempt
  bool get isAttempted =>
      this == QuestionStatus.correct || this == QuestionStatus.wrong;

  /// Check if status indicates success
  bool get isSuccess => this == QuestionStatus.correct;

  /// Check if status needs retry
  bool get needsRetry => this == QuestionStatus.wrong || this == QuestionStatus.skipped;
}
