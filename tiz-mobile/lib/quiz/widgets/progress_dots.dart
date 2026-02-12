/// Progress Dots Widget
/// Horizontal progress indicator with clickable dots

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../models/quiz_status.dart';

/// Horizontal progress dots indicator
class ProgressDots extends StatelessWidget {
  final int total;
  final int current;
  final List<int?> userAnswers;
  final List<bool>? correctness;
  final Function(int)? onTap;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;

  const ProgressDots({
    super.key,
    required this.total,
    required this.current,
    required this.userAnswers,
    this.correctness,
    this.onTap,
    this.dotSize = 8,
    this.activeDotWidth = 24,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => _buildDot(index, colors),
      ),
    );
  }

  Widget _buildDot(int index, ThemeColors colors) {
    final isCurrent = index == current;
    final wasAnswered = index < userAnswers.length && userAnswers[index] != null;
    final correctnessList = correctness;
    final isCorrect = correctnessList != null && index < correctnessList.length
        ? correctnessList[index]
        : null;

    Color dotColor;
    double width = dotSize;

    if (isCurrent) {
      dotColor = colors.accent;
      width = activeDotWidth;
    } else if (wasAnswered) {
      if (isCorrect != null) {
        dotColor = isCorrect ? colors.accent : colors.error;
      } else {
        dotColor = colors.textSecondary;
      }
    } else {
      dotColor = colors.border;
    }

    final dot = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      width: width,
      height: dotSize,
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () => onTap!(index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: dot,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: dot,
    );
  }
}

/// Vertical progress indicator (for sidebar)
class VerticalProgressDots extends StatelessWidget {
  final int total;
  final int current;
  final List<bool> correctness;
  final Function(int)? onTap;

  const VerticalProgressDots({
    super.key,
    required this.total,
    required this.current,
    required this.correctness,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;

    return Column(
      children: List.generate(
        total,
        (index) => _buildDot(index, colors),
      ),
    );
  }

  Widget _buildDot(int index, ThemeColors colors) {
    final isCurrent = index == current;
    final isCorrect = index < correctness.length ? correctness[index] : false;
    final isPast = index < current;

    Color dotColor;
    double size = 8;

    if (isCurrent) {
      dotColor = colors.accent;
      size = 12;
    } else if (isPast) {
      dotColor = isCorrect ? colors.accent : colors.error;
    } else {
      dotColor = colors.border;
    }

    final dot = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () => onTap!(index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: dot,
        ),
      );
    }

    return dot;
  }
}

/// Mini progress dots (compact version)
class MiniProgressDots extends StatelessWidget {
  final int completed;
  final int total;
  final Color? activeColor;
  final Color? inactiveColor;

  const MiniProgressDots({
    super.key,
    required this.completed,
    required this.total,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context).colors;

    final active = activeColor ?? colors.accent;
    final inactive = inactiveColor ?? colors.border;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        total,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: index < completed ? active : inactive,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
