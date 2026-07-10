import 'package:flutter/material.dart';

/// تبدیل رنگ به رشته Hex و برعکس، برای ذخیره رنگ‌های قابل تغییر برنامه
/// (تنظیمات پنل مدیریت) در Firestore.
class ColorUtils {
  ColorUtils._();

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color? fromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var clean = hex.replaceFirst('#', '').trim();
    if (clean.length == 6) clean = 'FF$clean';
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  /// چند رنگ پیش‌فرض که ادمین می‌تواند برای رنگ اصلی/ثانویه انتخاب کند
  static const List<Color> presetColors = [
    Color(0xFF1B5E20), // سبز تیره (پیش‌فرض)
    Color(0xFF0D47A1), // آبی تیره
    Color(0xFF4A148C), // بنفش تیره
    Color(0xFF3E2723), // قهوه‌ای تیره
    Color(0xFF004D40), // سبزآبی تیره
    Color(0xFFB71C1C), // قرمز تیره
    Color(0xFFC9A227), // طلایی (پیش‌فرض ثانویه)
    Color(0xFFFF6F00), // نارنجی تیره
  ];
}
