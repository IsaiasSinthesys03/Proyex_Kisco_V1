import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Mode Colors (Basado en el verde Proyex)
  static const Color primaryLight = Color(0xFF1B5E20); // Verde bosque profundo
  static const Color primaryContainerLight = Color(0xFFC8E6C9);
  static const Color secondaryLight = Color(0xFF388E3C);
  static const Color backgroundLight = Color(0xFFF8FBF8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF1A1C19);
  static const Color textSecondaryLight = Color(0xFF424940);
  static const Color borderLight = Color(0xFFC2C9BD);

  // Dark Mode Colors (OLED friendly y Premium)
  static const Color primaryDark = Color(0xFF81C784); // Verde suave vibrante
  static const Color primaryContainerDark = Color(0xFF0D3311);
  static const Color secondaryDark = Color(0xFFC8E6C9);
  static const Color backgroundDark = Color(0xFF0A0C0A); // Negro casi total
  static const Color surfaceDark = Color(0xFF141A14); // Superficie ligeramente verde oscura
  static const Color textMainDark = Color(0xFFE2E3DE);
  static const Color textSecondaryDark = Color(0xFFC2C9BD);
  static const Color borderDark = Color(0xFF3F493F);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        onSurface: AppColors.textMainLight,
        outlineVariant: AppColors.borderLight,
        surfaceVariant: AppColors.primaryContainerLight.withOpacity(0.3),
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textMainLight,
        displayColor: AppColors.textMainLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textMainLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryContainerLight,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        onSurface: AppColors.textMainDark,
        outlineVariant: AppColors.borderDark,
        surfaceVariant: AppColors.primaryContainerDark.withOpacity(0.5),
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textMainDark,
        displayColor: AppColors.textMainDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textMainDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryContainerDark,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMainDark),
        ),
      ),
    );
  }
}
