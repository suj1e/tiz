import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../features/quiz/models.dart';

/// Language Card Data Model
class LanguageCardData {
  final QuizCategory category;
  final String name;
  final String flag;
  final String description;

  const LanguageCardData({
    required this.category,
    required this.name,
    required this.flag,
    required this.description,
  });
}

/// Minimalist Card-based Language Selector
/// Horizontal scrollable card list inspired by Duolingo
class LanguageSelector extends StatefulWidget {
  final QuizCategory selectedCategory;
  final ValueChanged<QuizCategory> onCategoryChanged;
  final ThemeColors colors;

  const LanguageSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.colors,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  // Language data with flag emojis and descriptions
  static const List<LanguageCardData> _languages = [
    LanguageCardData(
      category: QuizCategory.english,
      name: '英语',
      flag: '\uD83C\uDDEC\uD83C\uDDE7',
      description: '全球通用语言',
    ),
    LanguageCardData(
      category: QuizCategory.japanese,
      name: '日语',
      flag: '\uD83C\uDDEF\uD83C\uDFF5',
      description: '动漫与文化交流',
    ),
    LanguageCardData(
      category: QuizCategory.german,
      name: '德语',
      flag: '\uD83C\uDDE9\uD83C\uDDEA',
      description: '欧洲文化精髓',
    ),
  ];

  int _tappedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _languages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = widget.selectedCategory == language.category;
          final isTapped = _tappedIndex == index;

          return _LanguageCard(
            data: language,
            isSelected: isSelected,
            isTapped: isTapped,
            colors: widget.colors,
            onTap: () {
              setState(() {
                _tappedIndex = index;
              });
              widget.onCategoryChanged(language.category);
              // Reset tapped state after animation
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  setState(() {
                    _tappedIndex = -1;
                  });
                }
              });
            },
          );
        },
      ),
    );
  }
}

/// Individual Language Card Widget
class _LanguageCard extends StatefulWidget {
  final LanguageCardData data;
  final bool isSelected;
  final bool isTapped;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.data,
    required this.isSelected,
    required this.isTapped,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_LanguageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTapped && !oldWidget.isTapped) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.colors.bgSecondary.withOpacity(0.8)
                : widget.colors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? widget.colors.accent
                  : widget.colors.border,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flag and Name Row
              Row(
                children: [
                  Text(
                    widget.data.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.data.name,
                      style: TextStyle(
                        color: widget.isSelected
                            ? widget.colors.accent
                            : widget.colors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Description
              Text(
                widget.data.description,
                style: TextStyle(
                  color: widget.colors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
