/// Option Button Widget
/// Displays a single multiple choice option

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../features/quiz/models.dart';

/// Single option button for quiz questions
class OptionButton extends StatelessWidget {
  final String option;
  final int index;
  final int? selectedIndex;
  final int? correctIndex;
  final bool showResult;
  final VoidCallback onTap;
  final bool isCompact;
  final bool showLetter;

  const OptionButton({
    super.key,
    required this.option,
    required this.index,
    required this.onTap,
    this.selectedIndex,
    this.correctIndex,
    this.showResult = false,
    this.isCompact = false,
    this.showLetter = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    final isSelected = selectedIndex == index;
    final isCorrect = correctIndex == index;
    final showWrong = showResult && isSelected && !isCorrect;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (!showResult) {
      // Before showing result
      backgroundColor = isSelected ? colors.accent : colors.bgSecondary;
      borderColor = isSelected ? colors.accent : colors.border;
      textColor = isSelected ? colors.bg : colors.text;
    } else {
      // After showing result
      if (isCorrect) {
        backgroundColor = colors.accent;
        borderColor = colors.accent;
        textColor = colors.bg;
      } else if (showWrong) {
        backgroundColor = colors.error;
        borderColor = colors.error;
        textColor = colors.bg;
      } else {
        backgroundColor = colors.bgSecondary;
        borderColor = colors.border;
        textColor = colors.textTertiary;
      }
    }

    final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
    final optionText = option.length > 3 && option[2] == '.'
        ? option.substring(3)
        : option;

    final button = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 12 : 20,
          horizontal: isCompact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: showResult ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (showLetter) ...[
              Container(
                width: isCompact ? 28 : 36,
                alignment: Alignment.center,
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    color: textColor,
                    fontSize: isCompact ? 20 : 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isCompact) const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  color: textColor,
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Result icon
            if (showResult && isCorrect) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: textColor,
                size: isCompact ? 18 : 20,
              ),
            ],
            if (showResult && showWrong) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.cancel,
                color: textColor,
                size: isCompact ? 18 : 20,
              ),
            ],
          ],
        ),
      ),
    );

    return button;
  }
}

/// Option button in grid layout
class OptionButtonGrid extends StatelessWidget {
  final List<String> options;
  final int? selectedIndex;
  final int? correctIndex;
  final bool showResult;
  final Function(int) onOptionTap;
  final bool isCompact;

  const OptionButtonGrid({
    super.key,
    required this.options,
    required this.onOptionTap,
    this.selectedIndex,
    this.correctIndex,
    this.showResult = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OptionButton(
                option: options[0],
                index: 0,
                selectedIndex: selectedIndex,
                correctIndex: correctIndex,
                showResult: showResult,
                onTap: () => onOptionTap(0),
                isCompact: isCompact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OptionButton(
                option: options[1],
                index: 1,
                selectedIndex: selectedIndex,
                correctIndex: correctIndex,
                showResult: showResult,
                onTap: () => onOptionTap(1),
                isCompact: isCompact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OptionButton(
                option: options[2],
                index: 2,
                selectedIndex: selectedIndex,
                correctIndex: correctIndex,
                showResult: showResult,
                onTap: () => onOptionTap(2),
                isCompact: isCompact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OptionButton(
                option: options[3],
                index: 3,
                selectedIndex: selectedIndex,
                correctIndex: correctIndex,
                showResult: showResult,
                onTap: () => onOptionTap(3),
                isCompact: isCompact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
