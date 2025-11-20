import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/premium_theme.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  bool isDarkMode() => state == ThemeMode.dark;
}

/// Dark theme configuration for Material 3
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: PremiumTheme.primary,
    secondary: PremiumTheme.accent,
    tertiary: PremiumTheme.success,
    surface: const Color(0xFF1E1E2E),
    onSurface: const Color(0xFFF5F5F5),
    error: PremiumTheme.error,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1E1E2E),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF5F5F5),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFF5F5F5),
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFF5F5F5),
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFF5F5F5),
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF5F5F5),
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF5F5F5),
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF5F5F5),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFE5E7EB),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFD1D5DB),
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF9CA3AF),
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF5F5F5),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2E2E3E),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3E3E4E)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3E3E4E)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PremiumTheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PremiumTheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PremiumTheme.error, width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    errorStyle: const TextStyle(color: PremiumTheme.error),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: PremiumTheme.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: PremiumTheme.primary,
      side: const BorderSide(color: PremiumTheme.primary),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: PremiumTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E2E),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E2E),
    selectedItemColor: PremiumTheme.primary,
    unselectedItemColor: const Color(0xFF9CA3AF),
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF2E2E3E),
    selectedColor: PremiumTheme.primary.withValues(alpha: 0.2),
    labelStyle: const TextStyle(color: Color(0xFFF5F5F5)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: const BorderSide(color: Color(0xFF3E3E4E)),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: PremiumTheme.primary,
    inactiveTrackColor: const Color(0xFF3E3E4E),
    thumbColor: PremiumTheme.primary,
    overlayColor: PremiumTheme.primary.withValues(alpha: 0.2),
    trackHeight: 4,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return PremiumTheme.primary;
      }
      return const Color(0xFF9CA3AF);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return PremiumTheme.primary.withValues(alpha: 0.4);
      }
      return const Color(0xFF3E3E4E);
    }),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF3E3E4E),
    thickness: 1,
    space: 16,
  ),
);
