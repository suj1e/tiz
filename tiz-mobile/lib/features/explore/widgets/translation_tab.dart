import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../translation/providers/favorites_provider.dart';
import '../../translation/models/favorite_translation.dart';

/// Translation Tab - Redesigned with Favorites
/// Card-based interface with focus on utility and favorites management
class TranslationTab extends StatefulWidget {
  const TranslationTab({super.key});

  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab> {
  final TextEditingController _sourceController = TextEditingController();
  int _sourceLangIndex = 0;
  int _targetLangIndex = 1;

  final List<LanguageOption> _languages = [
    LanguageOption(name: '中文', code: 'zh', flag: '🇨🇳'),
    LanguageOption(name: 'English', code: 'en', flag: '🇺🇸'),
    LanguageOption(name: '日本語', code: 'ja', flag: '🇯🇵'),
  ];

  bool _isTranslating = false;
  String? _translationResult;
  final List<TranslationHistoryItem> _history = [];

  // Favorites state
  bool _showFavoritesOnly = false;
  String _selectedCategory = '全部';

  static const int _maxCharacters = 500;

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
    'Hello': '你好',
    'Thank you': '谢谢',
    'Goodbye': '再见',
    'Good morning': '早上好',
    'I love you': '我爱你',
    'How are you': '你好吗',
    'こんにちは': 'Hello',
    'ありがとう': 'Thank you',
    'さようなら': 'Goodbye',
  };

  @override
  void initState() {
    super.initState();
    // Initialize favorites listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().addListener(_onFavoritesChanged);
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    context.read<FavoritesProvider>().removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  int get _characterCount => _sourceController.text.length;

  void _handleTranslate() {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translationResult = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final result = _getTranslation(text);

      setState(() {
        _isTranslating = false;
        _translationResult = result;
        _history.insert(0, TranslationHistoryItem(
          sourceText: text,
          translatedText: result,
          sourceLang: _languages[_sourceLangIndex].name,
          targetLang: _languages[_targetLangIndex].name,
          timestamp: DateTime.now(),
        ));
        if (_history.length > 10) _history.removeLast();
      });
    });
  }

  String _getTranslation(String text) {
    if (_mockTranslations.containsKey(text)) {
      return _mockTranslations[text]!;
    }
    return 'This is a mock translation. [$text]';
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLangIndex;
      _sourceLangIndex = _targetLangIndex;
      _targetLangIndex = temp;

      if (_translationResult != null) {
        _sourceController.text = _translationResult!;
        _translationResult = null;
      }
    });
  }

  void _copyResult() {
    if (_translationResult == null) return;
    Clipboard.setData(ClipboardData(text: _translationResult!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: colors.bg),
            const SizedBox(width: 8),
            Text('已复制'),
          ],
        ),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.accent,
      ),
    );
  }

  void _toggleFavorite() {
    if (_translationResult == null) return;

    final favoritesProvider = context.read<FavoritesProvider>();
    final sourceText = _sourceController.text.trim();
    final translatedText = _translationResult!;

    if (favoritesProvider.isFavorited(sourceText, translatedText)) {
      favoritesProvider.removeByText(sourceText, translatedText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.star_border_rounded, size: 16, color: colors.bg),
              const SizedBox(width: 8),
              Text('已取消收藏'),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.accent,
        ),
      );
    } else {
      _showCategoryDialog(sourceText, translatedText);
    }
  }

  void _showCategoryDialog(String sourceText, String translatedText) {
    final colors = context.read<ThemeProvider>().colors;
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '添加到收藏',
          style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择分类 (可选)',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FavoritesProvider.defaultCategories.map((cat) {
                if (cat == '全部') return const SizedBox.shrink();
                return ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 13)),
                  selected: selectedCategory == cat,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = selected ? cat : null;
                    });
                    Navigator.pop(context);
                    _addToFavorite(sourceText, translatedText, selected ? cat : null);
                  },
                  selectedColor: colors.accent,
                  backgroundColor: colors.bgSecondary,
                  labelStyle: TextStyle(
                    color: selectedCategory == cat ? colors.bg : colors.text,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colors.border),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addToFavorite(sourceText, translatedText, null);
            },
            child: Text('不分类', style: TextStyle(color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _addToFavorite(String sourceText, String translatedText, String? category) {
    final favoritesProvider = context.read<FavoritesProvider>();
    favoritesProvider.addFavorite(
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLanguage: _languages[_sourceLangIndex].name,
      targetLanguage: _languages[_targetLangIndex].name,
      category: category,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.star_rounded, size: 16, color: colors.bg),
            const SizedBox(width: 8),
            Text('已添加到收藏'),
          ],
        ),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.accent,
      ),
    );
  }

  void _showExportOptions() {
    final colors = context.read<ThemeProvider>().colors;
    final favoritesProvider = context.read<FavoritesProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.table_chart, color: colors.text),
              title: Text('导出为 CSV', style: TextStyle(color: colors.text)),
              onTap: () {
                Navigator.pop(context);
                _exportToClipboard(favoritesProvider.exportToCsv(), 'CSV');
              },
            ),
            ListTile(
              leading: Icon(Icons.code, color: colors.text),
              title: Text('导出为 JSON', style: TextStyle(color: colors.text)),
              onTap: () {
                Navigator.pop(context);
                _exportToClipboard(favoritesProvider.exportToJson(), 'JSON');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportToClipboard(String data, String format) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: colors.bg),
            const SizedBox(width: 8),
            Text('$format 已复制到剪贴板'),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.accent,
      ),
    );
  }

  ThemeColors get colors => context.read<ThemeProvider>().colors;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      children: [
        // Language selector header
        _buildLanguageHeader(colors),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Input card
                _buildInputCard(colors),

                const SizedBox(height: 12),

                // Swap button
                _buildSwapButton(colors),

                const SizedBox(height: 12),

                // Result card with star button
                _buildResultCard(colors),

                // Favorites section
                _buildFavoritesSection(colors),

                // History section
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildHistorySection(colors),
                ],
              ],
            ),
          ),
        ),

        // Translate button
        _buildTranslateButton(colors),
      ],
    );
  }

  Widget _buildLanguageHeader(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          _buildLanguageChip(
            colors,
            _languages[_sourceLangIndex],
            true,
            () => _showLanguageSelector(true),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 16, color: colors.textTertiary),
          const SizedBox(width: 8),
          _buildLanguageChip(
            colors,
            _languages[_targetLangIndex],
            false,
            () => _showLanguageSelector(false),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(
    ThemeColors colors,
    LanguageOption lang,
    bool isSource,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              lang.name,
              style: TextStyle(
                color: colors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 16, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '输入',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_characterCount > 0)
                Text(
                  '$_characterCount',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sourceController,
            maxLines: 5,
            maxLength: _maxCharacters,
            decoration: InputDecoration(
              hintText: '输入要翻译的文本...',
              hintStyle: TextStyle(color: colors.textTertiary, fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
            style: TextStyle(
              color: colors.text,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (_characterCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _sourceController.clear();
                      setState(() {
                        _translationResult = null;
                      });
                    },
                    child: Text(
                      '清空',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwapButton(ThemeColors colors) {
    return GestureDetector(
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
          Icons.swap_vert_rounded,
          size: 18,
          color: colors.text,
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeColors colors) {
    final hasResult = _translationResult != null;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorited = hasResult &&
        favoritesProvider.isFavorited(_sourceController.text.trim(), _translationResult!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasResult ? colors.bgSecondary : colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasResult ? colors.border : colors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '翻译结果',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasResult) ...[
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Icon(
                    isFavorited ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 18,
                    color: isFavorited ? colors.accent : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyResult,
                  child: Icon(Icons.copy_rounded, size: 16, color: colors.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (_isTranslating)
            Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (hasResult)
            Text(
              _translationResult!,
              style: TextStyle(
                color: colors.text,
                fontSize: 15,
                height: 1.5,
              ),
            )
          else
            Text(
              '翻译结果将显示在这里',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(ThemeColors colors) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favorites = favoritesProvider.favorites;

    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.star_rounded, size: 16, color: colors.accent),
                const SizedBox(width: 6),
                Text(
                  '收藏 (${favorites.length})',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _showExportOptions,
              child: Icon(Icons.more_vert, size: 18, color: colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Category filter chips
        if (FavoritesProvider.defaultCategories.any((cat) =>
            favorites.any((f) => f.category == cat || cat == '全部')))
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: FavoritesProvider.defaultCategories.map((cat) {
                final hasItems = cat == '全部' ||
                    favorites.any((f) => f.category == cat);
                if (!hasItems) return const SizedBox.shrink();

                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat, style: TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                        favoritesProvider.setCategory(cat);
                      });
                    },
                    selectedColor: colors.bgSecondary,
                    backgroundColor: colors.bg,
                    checkmarkColor: colors.accent,
                    labelStyle: TextStyle(
                      color: isSelected ? colors.text : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? colors.border : colors.borderLight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 8),
        // Favorites list
        ...List.generate(favorites.take(3).length, (index) {
          final item = favorites[index];
          return _buildFavoriteItem(item, colors);
        }),
      ],
    );
  }

  Widget _buildFavoriteItem(FavoriteTranslation item, ThemeColors colors) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<FavoritesProvider>().removeFavorite(item.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.borderLight, width: 1),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete_outline, color: colors.textSecondary),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _sourceController.text = item.sourceText;
            _translationResult = item.translatedText;
          });
        },
        onLongPress: () => _showItemCategoryOptions(item, colors),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.borderLight, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, size: 14, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.sourceText,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.translatedText,
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
              if (item.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.borderLight, width: 1),
                  ),
                  child: Text(
                    item.category!,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemCategoryOptions(FavoriteTranslation item, ThemeColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.folder_outlined, color: colors.text),
              title: Text('移动到分类', style: TextStyle(color: colors.text)),
              onTap: () {
                Navigator.pop(context);
                _showMoveToCategoryDialog(item);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colors.text),
              title: Text('删除', style: TextStyle(color: colors.text)),
              onTap: () {
                Navigator.pop(context);
                context.read<FavoritesProvider>().removeFavorite(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveToCategoryDialog(FavoriteTranslation item) {
    final colors = context.read<ThemeProvider>().colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '移动到分类',
          style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FavoritesProvider.defaultCategories.map((cat) {
            if (cat == '全部') return const SizedBox.shrink();
            final isSelected = item.category == cat;
            return ChoiceChip(
              label: Text(cat, style: TextStyle(fontSize: 13)),
              selected: isSelected,
              onSelected: (selected) {
                context.read<FavoritesProvider>().updateCategory(
                  item.id,
                  selected ? cat : null,
                );
                Navigator.pop(context);
              },
              selectedColor: colors.accent,
              backgroundColor: colors.bgSecondary,
              labelStyle: TextStyle(
                color: isSelected ? colors.bg : colors.text,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors.border),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistorySection(ThemeColors colors) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '历史记录',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _showFavoritesOnly ? Icons.filter_list_off : Icons.filter_list,
                      size: 14,
                      color: _showFavoritesOnly ? colors.accent : colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showFavoritesOnly ? '全部' : '仅收藏',
                      style: TextStyle(
                        color: _showFavoritesOnly ? colors.accent : colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_history.take(3).length, (index) {
          final item = _history[index];
          final isFav = favoritesProvider.isFavorited(item.sourceText, item.translatedText);
          if (_showFavoritesOnly && !isFav) return const SizedBox.shrink();
          return _buildHistoryItem(item, colors, isFav);
        }),
      ],
    );
  }

  Widget _buildHistoryItem(TranslationHistoryItem item, ThemeColors colors, bool isFavorited) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _sourceController.text = item.sourceText;
          _translationResult = item.translatedText;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.borderLight, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.sourceText,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.translatedText,
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
            if (isFavorited)
              Icon(Icons.star_rounded, size: 14, color: colors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateButton(ThemeColors colors) {
    final hasText = _sourceController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderLight, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: hasText && !_isTranslating ? _handleTranslate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.bg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isTranslating
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(colors.bg)))
              : Text('翻译', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  void _showLanguageSelector(bool isSource) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(_languages.length, (index) {
                final lang = _languages[index];
                final isSelected = isSource
                    ? index == _sourceLangIndex
                    : index == _targetLangIndex;

                return ListTile(
                  leading: Text(lang.flag, style: TextStyle(fontSize: 20)),
                  title: Text(lang.name, style: TextStyle(color: colors.text)),
                  trailing: isSelected ? Icon(Icons.check, color: colors.accent, size: 20) : null,
                  onTap: () {
                    setState(() {
                      if (isSource) {
                        if (index != _targetLangIndex) _sourceLangIndex = index;
                      } else {
                        if (index != _sourceLangIndex) _targetLangIndex = index;
                      }
                    });
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
}

class LanguageOption {
  final String name;
  final String code;
  final String flag;

  const LanguageOption({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class TranslationHistoryItem {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;

  TranslationHistoryItem({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
  });
}
