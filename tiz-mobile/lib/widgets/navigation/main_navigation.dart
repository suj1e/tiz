import 'package:flutter/material.dart';

import '../../features/bot/bot_page.dart';
import '../../features/explore/explore_page.dart';
import '../../features/inbox/inbox_page.dart';
import '../../features/profile/profile_page.dart';
import 'app_bottom_nav.dart';

/// Minimalist Main Navigation Widget
/// Bottom tab navigation with 4 tabs: Bot, Explore, Inbox, Profile
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  /// Access the navigation state from child pages
  static _MainNavigationState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainNavigationState>();
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Page controller for page switching
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  // List of pages - 4 tabs (Bot, Explore, Inbox, Profile)
  // Using static list to avoid recreating on every setState
  final List<Widget> _pages = [
    const BotPage(),
    const ExplorePage(),
    const InboxPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return; // Don't rebuild if same tab
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  /// Navigate to bot page
  void navigateToBot() {
    _onTabTapped(0);
  }

  /// Navigate to explore page with optional tab index
  void navigateToExplore([int? tabIndex]) {
    if (tabIndex != null) {
      // Navigate to explore with specific tab
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      // Just navigate to explore page
      _onTabTapped(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
