import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/language_selector.dart';
import '../../quiz/models.dart';
import '../../quiz/quiz_taking_page.dart';
import '../../quiz/quiz_conversation_page.dart';
import '../../quiz/quiz_voice_call_page.dart';
import 'quiz_bank_view.dart';

/// Quiz Tab - Tech-minimalist design (LeetCode/Codeforces style)
/// Data-dense layout with monospace fonts and status indicators
class QuizTab extends StatefulWidget {
  const QuizTab({super.key});

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> with SingleTickerProviderStateMixin {
  QuizCategory _selectedCategory = QuizCategory.english;
  late TabController _tabController;

  // Tech-minimalist colors
  static const successColor = Color(0xFF059669); // Emerald
  static const errorColor = Color(0xFFDC2626); // Red
  static const warningColor = Color(0xFFD97706); // Amber

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      children: [
        // Compact top bar with language selector
        _buildTopBar(colors),

        // Topic tabs (horizontal scroll)
        _buildTopicTabs(colors),

        // Content based on selected tab
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPracticeContent(colors),
              _buildVocabularyContent(colors),
              _buildListeningContent(colors),
              _buildSpeakingContent(colors),
              _buildCultureContent(colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Streak counter
          _buildStreakIndicator(colors),
          const Spacer(),
          // Compact language selector
          SizedBox(
            width: 140,
            child: LanguageSelector(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakIndicator(ThemeColors colors) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: warningColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '7天',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicTabs(ThemeColors colors) {
    final topics = ['练习', '词汇', '听力', '口语', '文化'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: colors.text,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'JetBrains Mono',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'JetBrains Mono',
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.text,
            width: 2,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 8),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        tabs: topics.map((topic) => Tab(text: topic)).toList(),
      ),
    );
  }

  Widget _buildPracticeContent(ThemeColors colors) {
    return Column(
      children: [
        // Stats row - compact tabular data
        _buildStatsRow(colors),

        // Question list
        Expanded(
          child: QuizBankView(initialCategory: _selectedCategory),
        ),

        // AI Generator button
        _buildAIGeneratorButton(colors),
      ],
    );
  }

  Widget _buildStatsRow(ThemeColors colors) {
    final questions = mockQuestions[_selectedCategory] ?? [];
    final total = questions.length;
    final solved = 0; // Mock solved count
    final accuracy = total > 0 ? (solved / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem('总计', total.toString(), colors),
          const SizedBox(width: 16),
          _buildStatItem('已解决', solved.toString(), colors, successColor),
          const SizedBox(width: 16),
          _buildStatItem('正确率', '$accuracy%', colors, warningColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeColors colors, [Color? valueColor]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 10,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'JetBrains Mono',
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularyContent(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            '词汇练习',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningContent(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.headphones_outlined,
            size: 48,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            '听力练习',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakingContent(ThemeColors colors) {
    return Column(
      children: [
        // Mode selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.borderLight, width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildModeButton('选择题', Icons.quiz, QuizMode.choice, colors),
              const SizedBox(width: 12),
              _buildModeButton('AI对话', Icons.chat_bubble_outline, QuizMode.conversation, colors),
              const SizedBox(width: 12),
              _buildModeButton('语音通话', Icons.phone_outlined, QuizMode.voiceCall, colors),
            ],
          ),
        ),
        // Quick start section
        Expanded(
          child: _buildQuickStartSection(colors),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, IconData icon, QuizMode mode, ThemeColors colors) {
    return GestureDetector(
      onTap: () => _onModeSelected(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.text),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.text,
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onModeSelected(QuizMode mode) {
    switch (mode) {
      case QuizMode.choice:
        // Navigate to choice quiz
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizTakingPage(
              category: _selectedCategory,
              mode: mode,
            ),
          ),
        );
        break;
      case QuizMode.conversation:
        // Navigate to conversation quiz
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizConversationPage(category: _selectedCategory),
          ),
        );
        break;
      case QuizMode.voiceCall:
        // Navigate to voice call quiz
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizVoiceCallPage(category: _selectedCategory),
          ),
        );
        break;
    }
  }

  Widget _buildQuickStartSection(ThemeColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick start title
          Text(
            '快速开始',
            style: TextStyle(
              color: colors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 12),
          // Quick action cards
          _buildQuickActionCard(
            icon: Icons.quiz,
            title: '选择题练习',
            subtitle: '完成5道选择题',
            onTap: () => _onModeSelected(QuizMode.choice),
            colors: colors,
          ),
          const SizedBox(height: 8),
          _buildQuickActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'AI对话练习',
            subtitle: '与AI进行实时对话',
            onTap: () => _onModeSelected(QuizMode.conversation),
            colors: colors,
          ),
          const SizedBox(height: 8),
          _buildQuickActionCard(
            icon: Icons.phone_outlined,
            title: '语音通话练习',
            subtitle: 'AI语音提问，你来回答',
            onTap: () => _onModeSelected(QuizMode.voiceCall),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Icon(icon, color: colors.text, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colors.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCultureContent(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.public_outlined,
            size: 48,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            '文化学习',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIGeneratorButton(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // AI Generate button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Show AI generator dialog
              },
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('AI生成题目'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                side: BorderSide(color: colors.border, width: 1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // AI Teacher button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to AI Teacher chat
              },
              icon: const Icon(Icons.psychology_outlined, size: 16),
              label: const Text('AI老师'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                side: BorderSide(color: colors.border, width: 1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status dot widget
class StatusDot extends StatelessWidget {
  final QuizStatus status;

  const StatusDot({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case QuizStatus.solved:
        color = const Color(0xFF059669);
        break;
      case QuizStatus.attempted:
        color = const Color(0xFFD97706);
        break;
      case QuizStatus.unsolved:
      default:
        color = const Color(0xFF9CA3AF);
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Quiz status enum
enum QuizStatus {
  solved,
  attempted,
  unsolved,
}
