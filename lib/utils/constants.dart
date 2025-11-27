import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  // Primary colors - Modern soft blue
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF5A6ACF);
  static const Color primaryLight = Color(0xFFE8ECFF);

  // Accent colors - Soft purple
  static const Color accent = Color(0xFF764BA2);
  static const Color accentDark = Color(0xFF667EEA);

  // Semantic colors - Soft and pleasing
  static const Color income = Color(0xFF10B981);  // Soft emerald
  static const Color incomeDark = Color(0xFF059669);
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color expense = Color(0xFFEF4444);  // Soft red
  static const Color expenseDark = Color(0xFFDC2626);
  static const Color expenseLight = Color(0xFFFEE2E2);

  // Status colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral colors - Modern grays
  static const Color background = Color(0xFFFAFAFB);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);
  
  // Card and component colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF334155);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF475569);
}

/// Category color options - Modern soft palette
class CategoryColors {
  static const List<Color> colors = [
    Color(0xFFEF4444), // Soft Red
    Color(0xFFEC4899), // Soft Pink 
    Color(0xFFA855F7), // Soft Purple
    Color(0xFF8B5CF6), // Soft Violet
    Color(0xFF6366F1), // Soft Indigo
    Color(0xFF3B82F6), // Soft Blue
    Color(0xFF06B6D4), // Soft Cyan
    Color(0xFF14B8A6), // Soft Teal
    Color(0xFF10B981), // Soft Emerald
    Color(0xFF22C55E), // Soft Green
    Color(0xFF84CC16), // Soft Lime
    Color(0xFFEAB308), // Soft Yellow
    Color(0xFFF97316), // Soft Orange
    Color(0xFF92400E), // Soft Brown
    Color(0xFF64748B), // Soft Slate
    Color(0xFF78716C), // Soft Stone
    Color(0xFF6B7280), // Soft Gray
    Color(0xFF059669), // Dark Emerald
  ];
  
  /// Get soft background colors for category chips
  static const List<Color> backgroundColors = [
    Color(0xFFFEE2E2), // Soft Red bg
    Color(0xFFFDF2F8), // Soft Pink bg
    Color(0xFFFAF5FF), // Soft Purple bg
    Color(0xFFF5F3FF), // Soft Violet bg
    Color(0xFFEEF2FF), // Soft Indigo bg
    Color(0xFFDBEAFE), // Soft Blue bg
    Color(0xFFCFFAFE), // Soft Cyan bg
    Color(0xFFF0FDFA), // Soft Teal bg
    Color(0xFFD1FAE5), // Soft Emerald bg
    Color(0xFFDCFCE7), // Soft Green bg
    Color(0xFFECFDF5), // Soft Lime bg
    Color(0xFFFEF3C7), // Soft Yellow bg
    Color(0xFFFED7AA), // Soft Orange bg
    Color(0xFFFDF6E3), // Soft Brown bg
    Color(0xFFF1F5F9), // Soft Slate bg
    Color(0xFFF5F5F4), // Soft Stone bg
    Color(0xFFF9FAFB), // Soft Gray bg
    Color(0xFFECFDF5), // Dark Emerald bg
  ];
}

/// App theme data
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary.withOpacity(0.1),
        disabledColor: AppColors.textTertiary.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackgroundDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        selectedColor: AppColors.primary.withOpacity(0.1),
        disabledColor: AppColors.textSecondaryDark.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
        elevation: 0,
      ),
    );
  }
}
