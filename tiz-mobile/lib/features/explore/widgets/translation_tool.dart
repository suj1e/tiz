import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../ai/providers/ai_config_provider.dart';
import '../../../widgets/common/app_card.dart';
import '../../../core/constants.dart';

/// Translation Tool Widget
/// AI-enhanced translation tool with language selection
class TranslationTool extends StatefulWidget {
  const TranslationTool({super.key});

  @override
  State<TranslationTool> createState() => _TranslationToolState();
}

class _TranslationToolState extends State<TranslationTool> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  String _sourceLang = 'English';
  String _targetLang = 'Chinese';
  bool _isTranslating = false;
  bool _isEnhanced = true;

  // Available languages
  final List<String> _languages = [
    'English',
    'Chinese',
    'Japanese',
    'Korean',
    'French',
    'German',
    'Spanish',
    'Russian',
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final aiProvider = context.read<AiConfigProvider>();

      // Simulate translation (replace with actual API call)
      await Future.delayed(
        Duration(
          milliseconds: aiProvider.deepThinkingMode ? 1500 : 500,
        ),
      );

      // Mock translation result
      String translated;
      if (_sourceLang == 'English' && _targetLang == 'Chinese') {
        translated = '[$_sourceLang → $_targetLang] ${_sourceController.text}';
      } else {
        translated = '[$_sourceLang → $_targetLang] ${_sourceController.text} (已翻译)';
      }

      setState(() {
        _targetController.text = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('翻译失败: $e')),
        );
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;

      // Also swap text
      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final aiProvider = context.watch<AiConfigProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Enhancement Toggle
          if (aiProvider.enhanceTranslation)
            _buildEnhancementToggle(colors, aiProvider),

          const SizedBox(height: 16),

          // Language Selector
          _buildLanguageSelector(colors),

          const SizedBox(height: 16),

          // Source Text Card
          _buildSourceCard(colors),

          const SizedBox(height: 12),

          // Action Buttons
          _buildActionButtons(colors, aiProvider),

          const SizedBox(height: 12),

          // Target Text Card
          _buildTargetCard(colors),

          const SizedBox(height: 16),

          // History Section
          _buildHistorySection(colors),
        ],
      ),
    );
  }

  /// Build Enhancement Toggle
  Widget _buildEnhancementToggle(ThemeColors colors, AiConfigProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.aiBadgeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.aiBadgeText.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text('✨', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI增强翻译',
                  style: TextStyle(
                    color: AppColors.aiBadgeText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '使用AI提升翻译准确性',
                  style: TextStyle(
                    color: AppColors.aiBadgeText.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnhanced,
            onChanged: (value) {
              setState(() {
                _isEnhanced = value;
              });
            },
            activeColor: AppColors.aiBadgeText,
          ),
        ],
      ),
    );
  }

  /// Build Language Selector
  Widget _buildLanguageSelector(ThemeColors colors) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _LanguageDropdown(
              value: _sourceLang,
              languages: _languages,
              onChanged: (lang) {
                setState(() {
                  _sourceLang = lang;
                });
              },
              colors: colors,
            ),
          ),
          // Swap Button
          GestureDetector(
            onTap: _swapLanguages,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: _LanguageDropdown(
              value: _targetLang,
              languages: _languages,
              onChanged: (lang) {
                setState(() {
                  _targetLang = lang;
                });
              },
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Source Card
  Widget _buildSourceCard(ThemeColors colors) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _sourceLang,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_sourceController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _sourceController.clear();
                    _targetController.clear();
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sourceController,
            maxLines: 5,
            minLines: 3,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '输入要翻译的文本...',
              hintStyle: TextStyle(
                color: colors.textSecondary,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  /// Build Action Buttons
  Widget _buildActionButtons(ThemeColors colors, AiConfigProvider aiProvider) {
    return Row(
      children: [
        // Translate Button
        Expanded(
          child: GestureDetector(
            onTap: _isTranslating ? null : _translate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isEnhanced
                      ? [
                          AppColors.aiPrimary,
                          AppColors.aiSecondary,
                        ]
                      : [
                          colors.primary,
                          colors.secondary,
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isTranslating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.surface,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isEnhanced) ...[
                            Text('✨', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            aiProvider.deepThinkingMode ? '深度翻译' : '翻译',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Target Card
  Widget _buildTargetCard(ThemeColors colors) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _targetLang,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_targetController.text.isNotEmpty)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Copy to clipboard
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // Speak text
                      },
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _targetController.text.isEmpty
                ? '翻译结果将显示在这里'
                : _targetController.text,
            style: TextStyle(
              color: _targetController.text.isEmpty
                  ? colors.textSecondary
                  : colors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build History Section
  Widget _buildHistorySection(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '翻译历史',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '清空',
              style: TextStyle(
                color: colors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // History items would go here
        _HistoryItem(
          source: 'Hello, how are you?',
          target: '你好，你好吗？',
          sourceLang: 'English',
          targetLang: 'Chinese',
          colors: colors,
        ),
      ],
    );
  }
}

/// Language Dropdown Widget
class _LanguageDropdown extends StatelessWidget {
  final String value;
  final List<String> languages;
  final ValueChanged<String> onChanged;
  final ThemeColors colors;

  const _LanguageDropdown({
    required this.value,
    required this.languages,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show language selection dialog
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// History Item Widget
class _HistoryItem extends StatelessWidget {
  final String source;
  final String target;
  final String sourceLang;
  final String targetLang;
  final ThemeColors colors;

  const _HistoryItem({
    required this.source,
    required this.target,
    required this.sourceLang,
    required this.targetLang,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.glassBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sourceLang,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, size: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.glassBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  targetLang,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            source,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            target,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
