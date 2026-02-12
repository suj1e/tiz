import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';

/// Dialect Learning Section within Language Tab
/// Provides phrase learning for dialects like Cantonese and Sichuanese
class DialectLearningSection extends StatefulWidget {
  const DialectLearningSection({super.key});

  @override
  State<DialectLearningSection> createState() => _DialectLearningSectionState();
}

class _DialectLearningSectionState extends State<DialectLearningSection> {
  int _selectedDialectIndex = 0;
  int _selectedCategoryIndex = 0;

  final List<String> _dialects = ['粤语', '四川话'];
  final List<String> _categories = ['日常用语', '数字', '时间', '颜色'];

  // Mock dialect data
  static const Map<String, Map<String, List<Phrase>>> _dialectData = {
    '粤语': {
      '日常用语': [
        Phrase(text: '你好', pronunciation: 'lei5 hou2', meaning: 'Hello', usage: 'Standard greeting'),
        Phrase(text: '谢谢', pronunciation: 'do1 ze6', meaning: 'Thank you', usage: 'Express gratitude'),
        Phrase(text: '再见', pronunciation: 'zoi3 gin3', meaning: 'Goodbye', usage: 'When parting'),
        Phrase(text: '早上好', pronunciation: 'zou2 sang6 hou2', meaning: 'Good morning', usage: 'Morning greeting'),
        Phrase(text: '晚安', pronunciation: 'maan5 on1', meaning: 'Good night', usage: 'Before sleeping'),
      ],
      '数字': [
        Phrase(text: '一', pronunciation: 'jat1', meaning: 'One', usage: 'Counting'),
        Phrase(text: '二', pronunciation: 'ji6', meaning: 'Two', usage: 'Counting'),
        Phrase(text: '三', pronunciation: 'saam1', meaning: 'Three', usage: 'Counting'),
        Phrase(text: '四', pronunciation: 'sei3', meaning: 'Four', usage: 'Counting'),
        Phrase(text: '五', pronunciation: 'ng5', meaning: 'Five', usage: 'Counting'),
      ],
      '时间': [
        Phrase(text: '今天', pronunciation: 'gam1 jat1', meaning: 'Today', usage: 'Current day'),
        Phrase(text: '明天', pronunciation: 'ming1 jat1', meaning: 'Tomorrow', usage: 'Next day'),
        Phrase(text: '昨天', pronunciation: 'kam5 jat1', meaning: 'Yesterday', usage: 'Previous day'),
        Phrase(text: '现在', pronunciation: 'ji5 gin3', meaning: 'Now', usage: 'Current time'),
      ],
      '颜色': [
        Phrase(text: '红色', pronunciation: 'hung4 sik1', meaning: 'Red', usage: 'Color description'),
        Phrase(text: '蓝色', pronunciation: 'laam4 sik1', meaning: 'Blue', usage: 'Color description'),
        Phrase(text: '绿色', pronunciation: 'luk6 sik1', meaning: 'Green', usage: 'Color description'),
        Phrase(text: '黄色', pronunciation: 'wong4 sik1', meaning: 'Yellow', usage: 'Color description'),
      ],
    },
    '四川话': {
      '日常用语': [
        Phrase(text: '你好', pronunciation: 'ni3 hao3 sa', meaning: 'Hello', usage: 'Casual greeting'),
        Phrase(text: '谢谢', pronunciation: 'xie4 xie4 luo', meaning: 'Thank you', usage: 'Express gratitude'),
        Phrase(text: '再见', pronunciation: 'zou3 lou5', meaning: 'Goodbye', usage: 'When parting'),
        Phrase(text: '早上好', pronunciation: 'zao3 shang4 hao3', meaning: 'Good morning', usage: 'Morning greeting'),
        Phrase(text: '吃了吗', pronunciation: 'chi1 le2 ma3', meaning: 'Have you eaten?', usage: 'Friendly inquiry'),
      ],
      '数字': [
        Phrase(text: '一', pronunciation: 'yi2', meaning: 'One', usage: 'Counting'),
        Phrase(text: '二', pronunciation: 'er4', meaning: 'Two', usage: 'Counting'),
        Phrase(text: '三', pronunciation: 'san1', meaning: 'Three', usage: 'Counting'),
        Phrase(text: '四', pronunciation: 'si4', meaning: 'Four', usage: 'Counting'),
        Phrase(text: '五', pronunciation: 'wu3', meaning: 'Five', usage: 'Counting'),
      ],
      '时间': [
        Phrase(text: '今天', pronunciation: 'jin1 tian1', meaning: 'Today', usage: 'Current day'),
        Phrase(text: '明天', pronunciation: 'ming2 tian1', meaning: 'Tomorrow', usage: 'Next day'),
        Phrase(text: '昨天', pronunciation: 'zuo2 tian1', meaning: 'Yesterday', usage: 'Previous day'),
        Phrase(text: '这阵', pronunciation: 'zhe4 zhen4', meaning: 'Now', usage: 'Current time'),
      ],
      '颜色': [
        Phrase(text: '红色', pronunciation: 'hong2 se4', meaning: 'Red', usage: 'Color description'),
        Phrase(text: '蓝色', pronunciation: 'lan2 se4', meaning: 'Blue', usage: 'Color description'),
        Phrase(text: '绿色', pronunciation: 'lv4 se4', meaning: 'Green', usage: 'Color description'),
        Phrase(text: '黄色', pronunciation: 'huang2 se4', meaning: 'Yellow', usage: 'Color description'),
      ],
    },
  };

  // Audio playback state (mock)
  bool _isPlaying = false;
  String? _playingPhrase;

  /// Get current dialect data
  Map<String, List<Phrase>> get _currentDialectData {
    return _dialectData[_dialects[_selectedDialectIndex]] ?? {};
  }

  /// Get current category phrases
  List<Phrase> get _currentPhrases {
    final category = _categories[_selectedCategoryIndex];
    return _currentDialectData[category] ?? [];
  }

  /// Handle audio playback (mock)
  void _handlePlayback(String phraseText) {
    setState(() {
      if (_isPlaying && _playingPhrase == phraseText) {
        _isPlaying = false;
        _playingPhrase = null;
      } else {
        _isPlaying = true;
        _playingPhrase = phraseText;

        // Simulate playback duration
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _playingPhrase = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dialect Selector
        _buildDialectSelector(colors),

        const SizedBox(height: 16),

        // Category Selector
        _buildCategorySelector(colors),

        const SizedBox(height: 16),

        // Phrase List
        Expanded(
          child: _buildPhraseList(colors),
        ),
      ],
    );
  }

  /// Build Dialect Selector
  Widget _buildDialectSelector(ThemeColors colors) {
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
            '选择方言',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: List.generate(_dialects.length, (index) {
              final isSelected = index == _selectedDialectIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDialectIndex = index;
                    _selectedCategoryIndex = 0;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accent : colors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Text(
                    _dialects[index],
                    style: TextStyle(
                      color: isSelected ? colors.bg : colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Build Category Selector
  Widget _buildCategorySelector(ThemeColors colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colors.accent : colors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? colors.accent : colors.border,
                  width: 1,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? colors.bg : colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build Phrase List
  Widget _buildPhraseList(ThemeColors colors) {
    final phrases = _currentPhrases;

    if (phrases.isEmpty) {
      return Center(
        child: Text(
          '暂无内容',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: phrases.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final phrase = phrases[index];
        final isPlaying = _isPlaying && _playingPhrase == phrase.text;

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
              // Phrase text and audio button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      phrase.text,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _handlePlayback(phrase.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isPlaying ? colors.accent : colors.bg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.border, width: 1),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 18,
                        color: isPlaying ? colors.bg : colors.text,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Pronunciation
              Text(
                '发音: ${phrase.pronunciation}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              // Meaning
              Text(
                '含义: ${phrase.meaning}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),

              // Usage example
              if (phrase.usage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '用法: ${phrase.usage}',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Phrase data model
class Phrase {
  final String text;
  final String pronunciation;
  final String meaning;
  final String usage;

  const Phrase({
    required this.text,
    required this.pronunciation,
    required this.meaning,
    required this.usage,
  });
}
