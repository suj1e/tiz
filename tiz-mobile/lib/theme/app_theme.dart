import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app_colors.dart';

/// Minimalist App Theme Data
/// Pure flat design with no shadows, following Tiz minimalist principles
class AppThemeBuilder {
  /// Get ThemeData for a specific theme
  static ThemeData getThemeData(AppTheme theme) {
    final colors = theme.colors;

    return ThemeData(
      useMaterial3: true,
      brightness: theme.brightness,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: theme.brightness,
        primary: colors.accent,
        onPrimary: colors.bg,
        secondary: colors.text,
        onSecondary: colors.bg,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        background: colors.bg,
        onBackground: colors.text,
        surface: colors.bg,
        onSurface: colors.text,
        surfaceVariant: colors.bgSecondary,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.border,
        outlineVariant: colors.border,
      ),

      // Scaffold
      scaffoldBackgroundColor: colors.bg,

      // AppBar - Minimalist, no elevation
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.text,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(
          color: colors.text,
          size: 20,
        ),
      ),

      // Bottom Navigation Bar - No elevation, flat design
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bg,
        selectedItemColor: colors.text,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Card - Minimalist, no shadow, 1px border
      cardTheme: CardThemeData(
        color: colors.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button - Flat, no shadow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.bg,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.text,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button - Minimalist
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.text,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          side: BorderSide(color: colors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration - Minimalist
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgSecondary,
        hintStyle: TextStyle(
          color: colors.textTertiary,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.textTertiary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colors.text,
        size: 20,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      // Dialog - Minimalist
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 14,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.bg,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colors.bgSecondary,
        selectedColor: colors.bg,
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: colors.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Switch - Minimalist
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.bg;
          }
          return colors.bg;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.accent;
          }
          return colors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.border,
        thumbColor: colors.accent,
        overlayColor: colors.accent.withOpacity(0.1),
        trackHeight: 2,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.bgSecondary,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.bg,
        contentTextStyle: TextStyle(
          color: colors.text,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colors.border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Tab Bar - Minimalist
      tabBarTheme: TabBarThemeData(
        labelColor: colors.text,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: colors.text,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Light theme
  static ThemeData get lightTheme => getThemeData(AppTheme.light);

  /// Dark theme
  static ThemeData get darkTheme => getThemeData(AppTheme.dark);
}
