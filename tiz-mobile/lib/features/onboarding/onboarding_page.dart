import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';

/// Onboarding Page
/// 3 pages of onboarding with swipeable dots
/// Page 1: Welcome to Tiz - Language learning made simple
/// Page 2: AI-Powered - Smart translation and quizzes
/// Page 3: Get Started - Button to go to registration
/// "Skip" button at top
/// Bottom dots indicator
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: '欢迎使用 Tiz',
      description: '语言学习从未如此简单。探索智能翻译、互动测验和 Bot。',
      icon: Icons.language_rounded,
    ),
    OnboardingItem(
      title: 'AI 驱动',
      description: '智能翻译和测验，让学习更高效。支持多语言对话和语音练习。',
      icon: Icons.psychology_rounded,
    ),
    OnboardingItem(
      title: '开始学习',
      description: '立即开启您的语言学习之旅，与 Tiz 一起探索世界。',
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skip() {
    // Navigate to login or home
    Navigator.pushReplacementNamed(context, '/');
  }

  void _next() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        actions: [
          if (_currentPage < _items.length - 1)
            TextButton(
              onPressed: _skip,
              child: Text(
                '跳过',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildPage(colors, _items[index]);
              },
            ),
          ),
          // Dots indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? colors.accent
                        : colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Next/Get Started button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.bg,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _currentPage == _items.length - 1 ? '开始使用' : '继续',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(ThemeColors colors, OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border.all(color: colors.border, width: 1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              item.icon,
              color: colors.text,
              size: 80,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            item.title,
            style: TextStyle(
              color: colors.text,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            item.description,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
