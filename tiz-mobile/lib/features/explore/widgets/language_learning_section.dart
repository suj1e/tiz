import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants.dart';

/// Language Learning Section within Language Tab
/// Provides phrase learning for languages like English, Cantonese and Sichuanese
class LanguageLearningSection extends StatefulWidget {
  final ValueChanged<int>? onLanguageChanged;

  const LanguageLearningSection({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<LanguageLearningSection> createState() => _LanguageLearningSectionState();
}

class _LanguageLearningSectionState extends State<LanguageLearningSection> {
  int _selectedLanguageIndex = 0;
  int _selectedCategoryIndex = 0;

  final List<String> _languages = ['英语', '粤语', '四川话'];
  final List<String> _categories = ['日常用语', '数字', '时间', '颜色'];

  // Learning progress for each language (mock data)
  final Map<String, double> _learningProgress = {
    '英语': 0.65,
    '粤语': 0.40,
    '四川话': 0.25,
  };

  // Mastered phrases count for each language (mock data)
  final Map<String, int> _masteredPhrases = {
    '英语': 13,
    '粤语': 8,
    '四川话': 5,
  };

  // Today's learning time for each language (in minutes)
  final Map<String, int> _todayLearningTime = {
    '英语': 25,
    '粤语': 15,
    '四川话': 10,
  };

  // Learning streak (days)
  final Map<String, int> _learningStreak = {
    '英语': 7,
    '粤语': 5,
    '四川话': 3,
  };

  // Total phrases per category
  final Map<String, int> _totalPhrasesPerCategory = {
    '日常用语': 10,
    '数字': 8,
    '时间': 6,
    '颜色': 6,
  };

  // Get feature name based on selected language
  String get _featureName {
    switch (_selectedLanguageIndex) {
      case 0:
        return 'AI深度翻译';
      case 1:
        return '粤语学习助手';
      case 2:
        return '川普学习助手';
      default:
        return 'AI学习助手';
    }
  }

  // Mock language data
  static const Map<String, Map<String, List<Phrase>>> _languageData = {
    '英语': {
      '日常用语': [
        Phrase(text: 'Hello', pronunciation: '/həˈloʊ/', meaning: '你好', usage: 'Standard greeting'),
        Phrase(text: 'Thank you', pronunciation: '/θæŋk juː/', meaning: '谢谢', usage: 'Express gratitude'),
        Phrase(text: 'Goodbye', pronunciation: '/ɡʊdˈbaɪ/', meaning: '再见', usage: 'When parting'),
        Phrase(text: 'Good morning', pronunciation: '/ɡʊd ˈmɔːrnɪŋ/', meaning: '早上好', usage: 'Morning greeting'),
        Phrase(text: 'Good night', pronunciation: '/ɡʊd naɪt/', meaning: '晚安', usage: 'Before sleeping'),
        Phrase(text: 'How are you?', pronunciation: '/haʊ ɑːr juː/', meaning: '你好吗', usage: 'Asking about wellbeing'),
        Phrase(text: 'Nice to meet you', pronunciation: '/naɪs tuː miːt juː/', meaning: '很高兴见到你', usage: 'First introduction'),
        Phrase(text: 'See you later', pronunciation: '/siː juː ˈleɪtər/', meaning: '回头见', usage: 'Casual farewell'),
        Phrase(text: 'Excuse me', pronunciation: '/ɪkˈskjuːz miː/', meaning: '打扰一下', usage: 'Getting attention'),
        Phrase(text: 'I\'m sorry', pronunciation: '/aɪm ˈsɑːri/', meaning: '对不起', usage: 'Apologizing'),
      ],
      '数字': [
        Phrase(text: 'One', pronunciation: '/wʌn/', meaning: '一', usage: 'Counting'),
        Phrase(text: 'Two', pronunciation: '/tuː/', meaning: '二', usage: 'Counting'),
        Phrase(text: 'Three', pronunciation: '/θriː/', meaning: '三', usage: 'Counting'),
        Phrase(text: 'Four', pronunciation: '/fɔːr/', meaning: '四', usage: 'Counting'),
        Phrase(text: 'Five', pronunciation: '/faɪv/', meaning: '五', usage: 'Counting'),
        Phrase(text: 'Six', pronunciation: '/sɪks/', meaning: '六', usage: 'Counting'),
        Phrase(text: 'Seven', pronunciation: '/ˈsevən/', meaning: '七', usage: 'Counting'),
        Phrase(text: 'Eight', pronunciation: '/eɪt/', meaning: '八', usage: 'Counting'),
      ],
      '时间': [
        Phrase(text: 'Today', pronunciation: '/təˈdeɪ/', meaning: '今天', usage: 'Current day'),
        Phrase(text: 'Tomorrow', pronunciation: '/təˈmɑːroʊ/', meaning: '明天', usage: 'Next day'),
        Phrase(text: 'Yesterday', pronunciation: '/ˈjestərdeɪ/', meaning: '昨天', usage: 'Previous day'),
        Phrase(text: 'Now', pronunciation: '/naʊ/', meaning: '现在', usage: 'Current time'),
        Phrase(text: 'Later', pronunciation: '/ˈleɪtər/', meaning: '稍后', usage: 'Future time'),
        Phrase(text: 'Soon', pronunciation: '/suːn/', meaning: '很快', usage: 'Near future'),
      ],
      '颜色': [
        Phrase(text: 'Red', pronunciation: '/red/', meaning: '红色', usage: 'Color description'),
        Phrase(text: 'Blue', pronunciation: '/bluː/', meaning: '蓝色', usage: 'Color description'),
        Phrase(text: 'Green', pronunciation: '/ɡriːn/', meaning: '绿色', usage: 'Color description'),
        Phrase(text: 'Yellow', pronunciation: '/ˈjeloʊ/', meaning: '黄色', usage: 'Color description'),
        Phrase(text: 'Black', pronunciation: '/blæk/', meaning: '黑色', usage: 'Color description'),
        Phrase(text: 'White', pronunciation: '/waɪt/', meaning: '白色', usage: 'Color description'),
      ],
    },
    '粤语': {
      '日常用语': [
        Phrase(text: '你好', pronunciation: 'lei5 hou2', meaning: 'Hello', usage: 'Standard greeting'),
        Phrase(text: '谢谢', pronunciation: 'do1 ze6', meaning: 'Thank you', usage: 'Express gratitude'),
        Phrase(text: '再见', pronunciation: 'zoi3 gin3', meaning: 'Goodbye', usage: 'When parting'),
        Phrase(text: '早上好', pronunciation: 'zou2 sang6 hou2', meaning: 'Good morning', usage: 'Morning greeting'),
        Phrase(text: '晚安', pronunciation: 'maan5 on1', meaning: 'Good night', usage: 'Before sleeping'),
        Phrase(text: '你好吗', pronunciation: 'lei5 hou2 maa3', meaning: 'How are you', usage: 'Asking about wellbeing'),
        Phrase(text: '唔该', pronunciation: 'm4 goi1', meaning: 'Excuse me/Thanks', usage: 'Getting attention or expressing thanks'),
        Phrase(text: '對唔住', pronunciation: 'deoi3 m4 zyu6', meaning: 'Sorry', usage: 'Apologizing'),
        Phrase(text: '食咗飯未', pronunciation: 'sik6 zo2 faan6 mei6', meaning: 'Have you eaten?', usage: 'Friendly greeting'),
        Phrase(text: '返工', pronunciation: 'faan1 gung1', meaning: 'Go to work', usage: 'Daily activity'),
      ],
      '数字': [
        Phrase(text: '一', pronunciation: 'jat1', meaning: 'One', usage: 'Counting'),
        Phrase(text: '二', pronunciation: 'ji6', meaning: 'Two', usage: 'Counting'),
        Phrase(text: '三', pronunciation: 'saam1', meaning: 'Three', usage: 'Counting'),
        Phrase(text: '四', pronunciation: 'sei3', meaning: 'Four', usage: 'Counting'),
        Phrase(text: '五', pronunciation: 'ng5', meaning: 'Five', usage: 'Counting'),
        Phrase(text: '六', pronunciation: 'luk6', meaning: 'Six', usage: 'Counting'),
        Phrase(text: '七', pronunciation: 'cat1', meaning: 'Seven', usage: 'Counting'),
        Phrase(text: '八', pronunciation: 'baat3', meaning: 'Eight', usage: 'Counting'),
      ],
      '时间': [
        Phrase(text: '今天', pronunciation: 'gam1 jat1', meaning: 'Today', usage: 'Current day'),
        Phrase(text: '明天', pronunciation: 'ming1 jat1', meaning: 'Tomorrow', usage: 'Next day'),
        Phrase(text: '琴日', pronunciation: 'kam4 jat1', meaning: 'Yesterday', usage: 'Previous day'),
        Phrase(text: '而家', pronunciation: 'ji4 gaa1', meaning: 'Now', usage: 'Current time'),
        Phrase(text: '陣間', pronunciation: 'zan6 gaan1', meaning: 'Later', usage: 'Future time'),
        Phrase(text: '已經', pronunciation: 'ji5 ging1', meaning: 'Already', usage: 'Past time'),
      ],
      '颜色': [
        Phrase(text: '红色', pronunciation: 'hung4 sik1', meaning: 'Red', usage: 'Color description'),
        Phrase(text: '蓝色', pronunciation: 'laam4 sik1', meaning: 'Blue', usage: 'Color description'),
        Phrase(text: '绿色', pronunciation: 'luk6 sik1', meaning: 'Green', usage: 'Color description'),
        Phrase(text: '黄色', pronunciation: 'wong4 sik1', meaning: 'Yellow', usage: 'Color description'),
        Phrase(text: '黑色', pronunciation: 'hak1 sik1', meaning: 'Black', usage: 'Color description'),
        Phrase(text: '白色', pronunciation: 'baak6 sik1', meaning: 'White', usage: 'Color description'),
      ],
    },
    '四川话': {
      '日常用语': [
        Phrase(text: '你好', pronunciation: 'ni3 hao3 sa', meaning: 'Hello', usage: 'Casual greeting'),
        Phrase(text: '谢谢', pronunciation: 'xie4 xie4 luo', meaning: 'Thank you', usage: 'Express gratitude'),
        Phrase(text: '再见', pronunciation: 'zou3 lou5', meaning: 'Goodbye', usage: 'When parting'),
        Phrase(text: '早上好', pronunciation: 'zao3 shang4 hao3', meaning: 'Good morning', usage: 'Morning greeting'),
        Phrase(text: '吃了吗', pronunciation: 'chi1 le2 ma3', meaning: 'Have you eaten?', usage: 'Friendly inquiry'),
        Phrase(text: '要得', pronunciation: 'yao4 de2', meaning: 'Okay/Good', usage: 'Agreement'),
        Phrase(text: '晓得', pronunciation: 'xiao3 de2', meaning: 'Know/Understand', usage: 'Understanding'),
        Phrase(text: '不存在', pronunciation: 'bu4 cun2 zai4', meaning: 'No problem/You\'re welcome', usage: 'Response to thanks'),
        Phrase(text: '巴适', pronunciation: 'ba1 shi4', meaning: 'Comfortable/Good', usage: 'Expressing satisfaction'),
        Phrase(text: '瓜娃子', pronunciation: 'gua1 wa2 zi3', meaning: 'Naive person', usage: 'Playful teasing'),
      ],
      '数字': [
        Phrase(text: '一', pronunciation: 'yi2', meaning: 'One', usage: 'Counting'),
        Phrase(text: '二', pronunciation: 'er4', meaning: 'Two', usage: 'Counting'),
        Phrase(text: '三', pronunciation: 'san1', meaning: 'Three', usage: 'Counting'),
        Phrase(text: '四', pronunciation: 'si4', meaning: 'Four', usage: 'Counting'),
        Phrase(text: '五', pronunciation: 'wu3', meaning: 'Five', usage: 'Counting'),
        Phrase(text: '六', pronunciation: 'liu4', meaning: 'Six', usage: 'Counting'),
        Phrase(text: '七', pronunciation: 'qi1', meaning: 'Seven', usage: 'Counting'),
        Phrase(text: '八', pronunciation: 'ba1', meaning: 'Eight', usage: 'Counting'),
      ],
      '时间': [
        Phrase(text: '今天', pronunciation: 'jin1 tian1', meaning: 'Today', usage: 'Current day'),
        Phrase(text: '明天', pronunciation: 'ming2 tian1', meaning: 'Tomorrow', usage: 'Next day'),
        Phrase(text: '昨天', pronunciation: 'zuo2 tian1', meaning: 'Yesterday', usage: 'Previous day'),
        Phrase(text: '这阵', pronunciation: 'zhe4 zhen4', meaning: 'Now', usage: 'Current time'),
        Phrase(text: '一会儿', pronunciation: 'yi4 hui4 er3', meaning: 'Later', usage: 'Future time'),
        Phrase(text: '马上', pronunciation: 'ma3 shang4', meaning: 'Immediately', usage: 'Very soon'),
      ],
      '颜色': [
        Phrase(text: '红色', pronunciation: 'hong2 se4', meaning: 'Red', usage: 'Color description'),
        Phrase(text: '蓝色', pronunciation: 'lan2 se4', meaning: 'Blue', usage: 'Color description'),
        Phrase(text: '绿色', pronunciation: 'lv4 se4', meaning: 'Green', usage: 'Color description'),
        Phrase(text: '黄色', pronunciation: 'huang2 se4', meaning: 'Yellow', usage: 'Color description'),
        Phrase(text: '黑色', pronunciation: 'hei1 se4', meaning: 'Black', usage: 'Color description'),
        Phrase(text: '白色', pronunciation: 'bai2 se4', meaning: 'White', usage: 'Color description'),
      ],
    },
  };

  // Audio playback state (mock)
  bool _isPlaying = false;
  String? _playingPhrase;

  /// Get current language data
  Map<String, List<Phrase>> get _currentLanguageData {
    return _languageData[_languages[_selectedLanguageIndex]] ?? {};
  }

  /// Get current category phrases
  List<Phrase> get _currentPhrases {
    final category = _categories[_selectedCategoryIndex];
    return _currentLanguageData[category] ?? [];
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
    final currentLanguage = _languages[_selectedLanguageIndex];
    final progress = _learningProgress[currentLanguage] ?? 0.0;
    final mastered = _masteredPhrases[currentLanguage] ?? 0;
    final todayTime = _todayLearningTime[currentLanguage] ?? 0;
    final streak = _learningStreak[currentLanguage] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Learning Progress Card
        _buildTodayProgressCard(colors, todayTime, streak, mastered),

        const SizedBox(height: 16),

        // Language Selector with Progress
        _buildLanguageSelector(colors, progress, mastered),

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

  /// Build Today's Learning Progress Card
  Widget _buildTodayProgressCard(
    ThemeColors colors,
    int todayTime,
    int streak,
    int mastered,
  ) {
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
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.todayLearning,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colors.accent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak${AppStrings.daysUnit}',
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats Grid
          Row(
            children: [
              // Learning Time
              Expanded(
                child: _buildStatItem(
                  colors,
                  Icons.schedule_outlined,
                  '$todayTime${AppStrings.minutesUnit}',
                  AppStrings.learningTime,
                ),
              ),

              const SizedBox(width: 12),

              // Mastered Phrases
              Expanded(
                child: _buildStatItem(
                  colors,
                  Icons.check_circle_outline,
                  '$mastered',
                  '${AppStrings.masteredPhrases}${AppStrings.phrasesUnit}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Stat Item
  Widget _buildStatItem(
    ThemeColors colors,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Language Selector with Progress Display
  Widget _buildLanguageSelector(ThemeColors colors, double progress, int mastered) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        children: [
          // Language Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.selectLanguage,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: List.generate(_languages.length, (index) {
                  final isSelected = index == _selectedLanguageIndex;
                  final language = _languages[index];
                  final langProgress = _learningProgress[language] ?? 0.0;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguageIndex = index;
                        _selectedCategoryIndex = 0;
                      });
                      widget.onLanguageChanged?.call(index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.accent : colors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            language,
                            style: TextStyle(
                              color: isSelected ? colors.bg : colors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (langProgress > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${(langProgress * 100).toInt()}%',
                              style: TextStyle(
                                color: isSelected ? colors.bg.withOpacity(0.7) : colors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          // Progress Bar
          if (progress > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.learningProgress,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${AppStrings.masteredPhrases} $mastered ${AppStrings.phrasesUnit}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.bg,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
          final category = _categories[index];
          final totalPhrases = _totalPhrasesPerCategory[category] ?? 0;

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? colors.bg : colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (totalPhrases > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.bg.withOpacity(0.2) : colors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$totalPhrases',
                        style: TextStyle(
                          color: isSelected ? colors.bg : colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
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
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
