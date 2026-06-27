import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // ☀️ الألوان المشتركة والقديمة (تمنع حدوث الأخطاء)
  // ==========================================
  static const Color primary      = Color(0xFF0F4C8A);
  static const Color primaryLight = Color(0xFFEEF4FC);
  static const Color primarySoft  = Color(0xFF6B9AC4);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color success      = Color(0xFF059669);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);

  // ألوان الوضع الفاتح الافتراضية القديمة
  static const Color background   = Color(0xFFF5F7FA);
  static const Color border       = Color(0xFFE8ECF1);
  static const Color textDark     = Color(0xFF444444);
  static const Color textGrey     = Color(0xFF888888);
  static const Color textLight    = Color(0xFFAAB2C0);

  // ==========================================
  // 🌙 ألوان الـ Dark Mode النيلية الجديدة
  // ==========================================
  static const Color darkBackground   = Color(0xFF0F1A2E); // الخلفية العامة
  static const Color topBottomBar     = Color(0xFF0A1628); // الشريط العلوي والسفلي
  static const Color cardBackground   = Color(0xFF162033); // الكروت والبطاقات
  static const Color inputFieldBg     = Color(0xFF1C2940); // حقول الإدخال وزر الرجوع

  static const Color accentBlue       = Color(0xFF4A8AE8); // اللون الأزرق للتنشيط والأيقونات
  static const Color selectedBorder   = Color(0xFF2A6BDB); // حواف الكارد المحدد

  static const Color textPrimary      = Color(0xFFFFFFFF); // النصوص الرئيسية البيضاء
  static const Color textSecondary    = Color(0xFF8A9BB5); // النصوص الثانوية والـ Placeholders
  static const Color iconUnselected   = Color(0xFF8A9BB5); // الأيقونات غير المحددة

  // ==========================================
  // 🛠️ دالتان لبناء الـ ThemeData الافتراضي
  // ==========================================

  // ثيم الوضع الفاتح (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: white,
      dividerColor: border,
    );
  }

  // ثيم الوضع المظلم النيلي (Dark Theme)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentBlue,
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardBackground,
      dividerColor: inputFieldBg,
    );
  }
}