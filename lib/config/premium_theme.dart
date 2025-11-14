import 'package:flutter/material.dart';

/// Premium Theme Configuration with Modern Design System
class PremiumTheme {
  // ============================================
  // PREMIUM COLOR PALETTE - Vibrant & Bold
  // ============================================
  
  // Primary Colors - Deep Purple/Indigo
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLighter = Color(0xFFA5B4FC);
  
  // Secondary Colors - Hot Pink/Magenta
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xFFDB2777);
  
  // Accent Colors - Teal/Cyan
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentLight = Color(0xFF22D3EE);
  static const Color accentDark = Color(0xFF0891B2);
  
  // Premium Tier Colors
  static const Color gold = Color(0xFFFBBF24);
  static const Color goldLight = Color(0xFFFDE047);
  static const Color goldDark = Color(0xFFF59E0B);
  
  static const Color platinum = Color(0xFFE5E7EB);
  static const Color platinumLight = Color(0xFFF9FAFB);
  static const Color platinumDark = Color(0xFFD1D5DB);
  
  static const Color diamond = Color(0xFF8B5CF6);
  static const Color diamondLight = Color(0xFFA78BFA);
  static const Color diamondDark = Color(0xFF7C3AED);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);
  
  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);
  
  // ============================================
  // PREMIUM GRADIENTS - Stunning Effects
  // ============================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFEAB308)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient diamondGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFFC084FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEC4899), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFFF59E0B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Glassmorphism Gradient
  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.7),
      Colors.white.withValues(alpha: 0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================
  // SPACING SYSTEM
  // ============================================
  
  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 40.0;
  static const double space3xl = 48.0;
  static const double space4xl = 64.0;
  
  // ============================================
  // BORDER RADIUS
  // ============================================
  
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radius3xl = 32.0;
  static const double radiusFull = 9999.0;
  
  // ============================================
  // SHADOWS - Elevation System
  // ============================================
  
  static final BoxShadow shadowXs = BoxShadow(
    color: Colors.black.withValues(alpha: 0.03),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );
  
  static final BoxShadow shadowSm = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  static final BoxShadow shadowMd = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  static final BoxShadow shadowLg = BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
  
  static final BoxShadow shadowXl = BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 24,
    offset: const Offset(0, 12),
  );
  
  static final BoxShadow shadow2xl = BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 32,
    offset: const Offset(0, 16),
  );
  
  // Colored Shadows for Premium Effect
  static final BoxShadow shadowPrimary = BoxShadow(
    color: primary.withValues(alpha: 0.3),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
  
  static final BoxShadow shadowSecondary = BoxShadow(
    color: secondary.withValues(alpha: 0.3),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
  
  static final BoxShadow shadowGold = BoxShadow(
    color: gold.withValues(alpha: 0.3),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
  
  // Glassmorphism Shadow
  static final List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.5),
      blurRadius: 10,
      offset: const Offset(-5, -5),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(5, 5),
    ),
  ];
  
  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ============================================
  // TYPOGRAPHY STYLES
  // ============================================
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: textPrimary,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: textPrimary,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
    color: textPrimary,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
    color: textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: textPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: textPrimary,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: textSecondary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
    color: textSecondary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
    color: textTertiary,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: textSecondary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: textTertiary,
  );
  
  // ============================================
  // MATERIAL 3 THEME DATA
  // ============================================
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: textOnPrimary,
      primaryContainer: primaryLight,
      secondary: secondary,
      onSecondary: textOnPrimary,
      secondaryContainer: secondaryLight,
      tertiary: accent,
      onTertiary: textOnPrimary,
      error: error,
      onError: textOnPrimary,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariant,
      outline: border,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'SF Pro Display',
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: headlineMedium,
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      color: surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      selectedColor: primary,
      labelStyle: labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
      ),
    ),
  );
  
  // ============================================
  // DARK THEME
  // ============================================
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      onPrimary: backgroundDark,
      primaryContainer: primaryDark,
      secondary: secondaryLight,
      onSecondary: backgroundDark,
      secondaryContainer: secondaryDark,
      tertiary: accentLight,
      onTertiary: backgroundDark,
      error: errorLight,
      onError: backgroundDark,
      surface: Color(0xFF1E293B),
      onSurface: textOnDark,
      surfaceContainerHighest: Color(0xFF334155),
      outline: Color(0xFF475569),
    ),
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'SF Pro Display',
    textTheme: TextTheme(
      displayLarge: displayLarge.copyWith(color: textOnDark),
      displayMedium: displayMedium.copyWith(color: textOnDark),
      displaySmall: displaySmall.copyWith(color: textOnDark),
      headlineLarge: headlineLarge.copyWith(color: textOnDark),
      headlineMedium: headlineMedium.copyWith(color: textOnDark),
      headlineSmall: headlineSmall.copyWith(color: textOnDark),
      titleLarge: titleLarge.copyWith(color: textOnDark),
      titleMedium: titleMedium.copyWith(color: textOnDark),
      titleSmall: titleSmall.copyWith(color: Color(0xFF94A3B8)),
      bodyLarge: bodyLarge.copyWith(color: textOnDark),
      bodyMedium: bodyMedium.copyWith(color: Color(0xFF94A3B8)),
      bodySmall: bodySmall.copyWith(color: Color(0xFF64748B)),
      labelLarge: labelLarge.copyWith(color: textOnDark),
      labelMedium: labelMedium.copyWith(color: Color(0xFF94A3B8)),
      labelSmall: labelSmall.copyWith(color: Color(0xFF64748B)),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textOnDark,
      titleTextStyle: headlineMedium.copyWith(color: textOnDark),
      iconTheme: const IconThemeData(color: textOnDark),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      color: const Color(0xFF1E293B),
    ),
  );
}
