import 'package:flutter/material.dart';

/// رنگ‌های اصلی اپلیکیشن چراغ
class AppColors {
  AppColors._();

  // رنگ اصلی (Material 3 seed)
  static const Color primary = Color(0xFF1B5E20); // سبز تیره
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003300);

  // رنگ ثانویه طلایی
  static const Color secondary = Color(0xFFC9A227);
  static const Color secondaryLight = Color(0xFFFFD95A);
  static const Color secondaryDark = Color(0xFF97730A);

  // پس‌زمینه‌ها
  static const Color backgroundLight = Color(0xFFFFFDF7);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // متن
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // وضعیت‌ها
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1565C0);

  static const List<Color> goldGradient = [secondaryDark, secondary, secondaryLight];
}
