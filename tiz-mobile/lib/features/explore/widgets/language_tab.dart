import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants.dart';
import 'translation_section.dart';
import 'language_learning_section.dart';

/// Minimalist Language Tab
/// Combines translation and language learning features
class LanguageTab extends StatefulWidget {
  const LanguageTab({super.key});

  @override
  State<LanguageTab> createState() => _LanguageTabState();
}

class _LanguageTabState extends State<LanguageTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _aiDeepTranslate = false;

  // Track selected language in learning section for dynamic feature name
  int _selectedLanguageIndex = 0;

  // Get dynamic feature name based on tab and language selection
  String get _featureName {
    if (_tabController.index == 0) {
      // Translation tab
      return AppStrings.aiEnhancedTranslation;
    }
    // Learning tab - simple name based on selected language
    switch (_selectedLanguageIndex) {
      case 0:
        return '英语学习'; // English
      case 1:
        return '粤语学习'; // Cantonese
      case 2:
        return '川普学习'; // Sichuanese
      default:
        return '语言学习';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _onLanguageChanged(int index) {
    setState(() {
      _selectedLanguageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '语言',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // AI Feature Toggle
          _buildAiToggle(colors),

          const SizedBox(height: 16),

          // Tab Bar
          _buildTabBar(colors),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TranslationSection(aiDeepTranslate: _aiDeepTranslate),
                LanguageLearningSection(
                  onLanguageChanged: _onLanguageChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build AI Feature Toggle (only for translation tab)
  Widget _buildAiToggle(ThemeColors colors) {
    // Only show toggle for translation tab
    if (_tabController.index == 1) {
      // Learning tab - show simple title only
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          children: [
            Text(
              _featureName,
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Translation tab - show toggle
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _featureName,
            style: TextStyle(
              color: colors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _aiDeepTranslate = !_aiDeepTranslate;
              });
            },
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: _aiDeepTranslate ? colors.accent : colors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: _aiDeepTranslate
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Tab Bar
  Widget _buildTabBar(ThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.text,
            width: 2,
          ),
          insets: const EdgeInsets.all(0),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colors.text,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: (_) {
          setState(() {});
        },
        tabs: const [
          Tab(text: AppStrings.translation),
          Tab(text: AppStrings.languageLearning),
        ],
      ),
    );
  }
}
