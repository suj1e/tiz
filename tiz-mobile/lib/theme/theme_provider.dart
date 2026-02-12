import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// Minimalist Theme Provider
/// Manages theme state with only Light/Dark themes
class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;
  static const String _themeKey = 'tiz_theme';

  ThemeProvider() {
    _loadTheme();
  }

  /// Get current theme type
  AppTheme get currentThemeType => _currentTheme;

  /// Get current theme data
  ThemeData get currentTheme => AppThemeBuilder.getThemeData(_currentTheme);

  /// Get current theme colors
  ThemeColors get colors => _currentTheme.colors;

  /// Check if current theme is dark
  bool get isDarkMode => _currentTheme.brightness == Brightness.dark;

  /// Set theme and save to storage
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    notifyListeners();

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null && themeIndex >= 0 && themeIndex < AppTheme.values.length) {
      _currentTheme = AppTheme.values[themeIndex];
      notifyListeners();
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final newTheme = isDarkMode ? AppTheme.light : AppTheme.dark;
    await setTheme(newTheme);
  }

  /// Get list of all available themes
  static List<AppTheme> get allThemes => AppTheme.values;
}

/// Minimalist Theme Selector Widget
/// Displays a 2-column grid for Light/Dark theme selection
class ThemeSelector extends StatelessWidget {
  final ValueChanged<AppTheme>? onThemeChanged;

  const ThemeSelector({
    super.key,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: AppTheme.values.map((appTheme) {
        final isSelected = themeProvider.currentThemeType == appTheme;
        final themeColors = appTheme.colors;

        return GestureDetector(
          onTap: () async {
            await themeProvider.setTheme(appTheme);
            onThemeChanged?.call(appTheme);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? themeColors.accent : themeColors.bgSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? themeColors.accent : themeColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Theme Icon
                _buildThemeIcon(appTheme, isSelected ? themeColors.bg : themeColors.text),
                const SizedBox(height: 8),
                // Theme Name
                Text(
                  appTheme.displayName,
                  style: TextStyle(
                    color: isSelected ? themeColors.bg : themeColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemeIcon(AppTheme theme, Color color) {
    switch (theme) {
      case AppTheme.light:
        return Icon(Icons.wb_sunny_outlined, color: color, size: 24);
      case AppTheme.dark:
        return Icon(Icons.nights_stay_outlined, color: color, size: 24);
    }
  }
}
