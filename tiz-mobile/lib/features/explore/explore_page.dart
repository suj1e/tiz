import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';
import 'widgets/translation_tab.dart';
import 'widgets/quiz_tab.dart';

/// Minimalist Explore Page with Tab Switching
/// Two tabs: 翻译 (Translation), 测验 (Quiz)
class ExplorePage extends StatefulWidget {
  final int? initialTab;

  const ExplorePage({super.key, this.initialTab});

  @override
  State<ExplorePage> createState() => ExplorePageState();
}

/// Expose state type for external access (e.g., from MainNavigation)
class ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Set initial tab index if provided
    if (widget.initialTab != null && widget.initialTab! >= 0 && widget.initialTab! < 2) {
      _tabController.index = widget.initialTab!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Bar
            _buildTabBar(colors),

            // Tab Content - Full screen without card containers
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TranslationTab(),
                  QuizTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Minimalist Tab Bar
  Widget _buildTabBar(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.bg,
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
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: '翻译'),
          Tab(text: '测验'),
        ],
      ),
    );
  }
}
