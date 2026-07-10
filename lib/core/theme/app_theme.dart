import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color color) {
    return GoogleFonts.vazirmatnTextTheme().apply(
      bodyColor: color,
      displayColor: color,
    );
  }

  /// [seedColor] و [secondaryColor] در صورت تعیین از پنل مدیریت (تنظیمات
  /// سراسری برنامه) می‌آیند؛ در غیر این صورت رنگ‌های پیش‌فرض چراغ استفاده می‌شود.
  static ThemeData lightTheme({Color? seedColor, Color? secondaryColor}) {
    final primary = seedColor ?? AppColors.primary;
    final secondary = secondaryColor ?? AppColors.secondary;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      textTheme: _textTheme(AppColors.textPrimaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData darkTheme({Color? seedColor, Color? secondaryColor}) {
    final primary = seedColor ?? AppColors.primary;
    final secondary = secondaryColor ?? AppColors.secondary;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      textTheme: _textTheme(AppColors.textPrimaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: secondary,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.surfaceDark,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
