import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants.dart';

/// Translation Section within Language Tab
/// Supports standard and AI deep translation
class TranslationSection extends StatefulWidget {
  final bool aiDeepTranslate;

  const TranslationSection({
    super.key,
    required this.aiDeepTranslate,
  });

  @override
  State<TranslationSection> createState() => _TranslationSectionState();
}

class _TranslationSectionState extends State<TranslationSection> {
  final TextEditingController _controller = TextEditingController();
  int _sourceLangIndex = 0;
  int _targetLangIndex = 1;

  final List<String> _languages = [
    '中文',
    'English',
    '日本語',
    '粤语',
    '四川话'
  ];

  // Translation state
  bool _isTranslating = false;
  bool _isAiAnalyzing = false;
  String? _translationResult;
  String? _aiAnalysis;
  final List<Map<String, String>> _translationHistory = [];

  // Mock translations database
  static const Map<String, String> _mockTranslations = {
    '你好': 'Hello',
    '谢谢': 'Thank you',
    '再见': 'Goodbye',
    '早上好': 'Good morning',
    '晚上好': 'Good evening',
    '晚安': 'Good night',
    '请': 'Please',
    '对不起': 'Sorry',
    '没关系': "You're welcome",
    '是的': 'Yes',
    '不': 'No',
    '也许': 'Maybe',
    '我爱你': 'I love you',
    '很高兴见到你': 'Nice to meet you',
    '你好吗': 'How are you',
    '我很好': "I'm fine",
    '什么': 'What',
    '为什么': 'Why',
    '怎么': 'How',
    '哪里': 'Where',
    '什么时候': 'When',
    'Hello': '你好',
    'Thank you': '谢谢',
    'Goodbye': '再见',
    'Good morning': '早上好',
    'Good evening': '晚上好',
    'Good night': '晚安',
    'Please': '请',
    'Sorry': '对不起',
    'Yes': '是的',
    'No': '不',
    'I love you': '我爱你',
    'Nice to meet you': '很高兴见到你',
    'How are you': '你好吗',
    "I'm fine": '我很好',
    'こんにちは': 'Hello',
    'ありがとう': 'Thank you',
    'さようなら': 'Goodbye',
    'おはよう': 'Good morning',
    'こんばんは': 'Good evening',
    'おやすみ': 'Good night',
    'すみません': 'Sorry',
    'はい': 'Yes',
    'いいえ': 'No',
    '愛してる': 'I love you',
    'はじめまして': 'Nice to meet you',
  };

  // Mock dialect translations
  static const Map<String, Map<String, String>> _dialectTranslations = {
    '粤语': {
      '你好': 'lei5 hou2',
      '谢谢': 'do1 ze6',
      '再见': 'zoi3 gin3',
    },
    '四川话': {
      '你好': '你好撒',
      '谢谢': '谢咯',
      '再见': '走咯',
    },
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle translation action
  void _handleTranslate() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _isAiAnalyzing = widget.aiDeepTranslate;
      _translationResult = null;
      _aiAnalysis = null;
    });

    // Simulate API delay
    Future.delayed(
      Duration(milliseconds: widget.aiDeepTranslate ? 1500 : 500),
      () {
        if (!mounted) return;

        final result = _getTranslation(text);
        final analysis = widget.aiDeepTranslate ? _getAiAnalysis(text) : null;

        setState(() {
          _isTranslating = false;
          _isAiAnalyzing = false;
          _translationResult = result;
          _aiAnalysis = analysis;

          // Add to history (max 5 items)
          _translationHistory.insert(0, {
            'source': text,
            'target': result,
            'sourceLang': _languages[_sourceLangIndex],
            'targetLang': _languages[_targetLangIndex],
          });
          if (_translationHistory.length > 5) {
            _translationHistory.removeLast();
          }
        });
      },
    );
  }

  /// Get mock translation for input text
  String _getTranslation(String text) {
    final sourceLang = _languages[_sourceLangIndex];
    final targetLang = _languages[_targetLangIndex];

    // Check for dialect translations
    if (_dialectTranslations.containsKey(targetLang)) {
      final dialectMap = _dialectTranslations[targetLang]!;
      if (dialectMap.containsKey(text)) {
        return dialectMap[text]!;
      }
    }

    // Check for exact match in mock database
    if (_mockTranslations.containsKey(text)) {
      return _mockTranslations[text]!;
    }

    // Return mock result for unknown input
    return 'This is a mock translation. [$text]';
  }

  /// Get mock AI analysis
  String _getAiAnalysis(String text) {
    return '''深度分析结果:

• 语境: $text 是常见的日常用语
• 情感倾向: 积极/友好
• 适用场景: 非正式对话
• 文化注释: 在中文语境中，这是一个标准的问候语''';
  }

  /// Swap source and target languages
  void _swapLanguages() {
    setState(() {
      final temp = _sourceLangIndex;
      _sourceLangIndex = _targetLangIndex;
      _targetLangIndex = temp;
    });
  }

  /// Copy translation result to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Load history item into input
  void _loadHistoryItem(String sourceText, String targetText) {
    setState(() {
      _controller.text = sourceText;
      _translationResult = targetText;
      _aiAnalysis = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dual-pane layout with language selector
        _buildDualPaneLayout(colors),

        const SizedBox(height: 12),

        // Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isTranslating ? null : _handleTranslate,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.bg,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isTranslating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.bg),
                    ),
                  )
                : Text(
                    AppStrings.translateButton,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),

        // Translation History
        if (_translationHistory.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildHistorySection(colors),
        ],
      ],
    );
  }

  /// Build dual-pane layout with source and target areas side by side
  Widget _buildDualPaneLayout(ThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source Language Pane
        Expanded(
          child: _buildSourcePane(colors),
        ),

        const SizedBox(width: 12),

        // Middle Column: Language selectors and swap button
        _buildMiddleControls(colors),

        const SizedBox(width: 12),

        // Target Language Pane
        Expanded(
          child: _buildTargetPane(colors),
        ),
      ],
    );
  }

  /// Build source language pane (left side)
  Widget _buildSourcePane(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source language header
          Text(
            _languages[_sourceLangIndex],
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Text input field
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppStrings.translateHint,
              hintStyle: TextStyle(color: colors.textTertiary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              color: colors.text,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build target language pane (right side)
  Widget _buildTargetPane(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target language header with copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _languages[_targetLangIndex],
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_translationResult != null)
                GestureDetector(
                  onTap: () => _copyToClipboard(_translationResult!),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Result container
          SizedBox(
            height: 120,
            child: _isTranslating
                ? _buildLoadingIndicator(colors)
                : _translationResult != null
                    ? _buildTranslationContent(colors)
                    : Text(
                        '翻译结果将显示在这里',
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 15,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Build middle column with language selectors and swap button
  Widget _buildMiddleControls(ThemeColors colors) {
    return Column(
      children: [
        // Source language selector
        GestureDetector(
          onTap: () => _showLanguageSelector(colors, _sourceLangIndex, (index) {
            setState(() {
              if (index != _targetLangIndex) {
                _sourceLangIndex = index;
              }
            });
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Text(
              _languages[_sourceLangIndex],
              style: TextStyle(
                color: colors.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Swap button
        GestureDetector(
          onTap: _swapLanguages,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Icon(
              Icons.swap_vert,
              size: 18,
              color: colors.text,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Target language selector
        GestureDetector(
          onTap: () => _showLanguageSelector(colors, _targetLangIndex, (index) {
            setState(() {
              if (index != _sourceLangIndex) {
                _targetLangIndex = index;
              }
            });
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Text(
              _languages[_targetLangIndex],
              style: TextStyle(
                color: colors.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build translation content with AI analysis
  Widget _buildTranslationContent(ThemeColors colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Translated text
          Text(
            _translationResult!,
            style: TextStyle(
              color: colors.text,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          // AI Analysis
          if (_aiAnalysis != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Text(
                _aiAnalysis!,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show language selector bottom sheet
  void _showLanguageSelector(
    ThemeColors colors,
    int currentIndex,
    ValueChanged<int> onTap,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(_languages.length, (index) {
                final isSelected = index == currentIndex;
                return ListTile(
                  title: Text(
                    _languages[index],
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: colors.accent, size: 20) : null,
                  onTap: () {
                    onTap(index);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
            ),
          ),
          if (_isAiAnalyzing) ...[
            const SizedBox(height: 12),
            Text(
              'AI正在深度分析...',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build translation history section
  Widget _buildHistorySection(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '翻译历史',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Column(
            children: List.generate(_translationHistory.length, (index) {
              final entry = _translationHistory[index];
              final isLast = index == _translationHistory.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () => _loadHistoryItem(entry['source']!, entry['target']!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['source']!,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry['target']!,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: colors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.border,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
