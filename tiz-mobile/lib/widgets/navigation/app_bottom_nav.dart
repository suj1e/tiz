import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants.dart';

/// Minimalist Bottom Navigation Bar
/// 4 tabs: Bot, Explore, Inbox, Profile
class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabTapped;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy_rounded,
                label: AppStrings.navBot,
                isSelected: selectedIndex == 0,
                colors: colors,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: AppStrings.navExplore,
                isSelected: selectedIndex == 1,
                colors: colors,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.inbox_outlined,
                activeIcon: Icons.inbox_rounded,
                label: AppStrings.navInbox,
                isSelected: selectedIndex == 2,
                colors: colors,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: AppStrings.navProfile,
                isSelected: selectedIndex == 3,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required ThemeColors colors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? colors.text : colors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.text : colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
