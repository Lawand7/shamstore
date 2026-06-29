import 'package:flutter/material.dart';

class AppTheme {

  static const Color primary      = Color(0xFF0F4C8A);
  static const Color primaryLight = Color(0xFFEEF4FC);
  static const Color primarySoft  = Color(0xFF6B9AC4);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color success      = Color(0xFF059669);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);

  static const Color background   = Color(0xFFF5F7FA);
  static const Color border       = Color(0xFFE8ECF1);
  static const Color textDark     = Color(0xFF444444);
  static const Color textGrey     = Color(0xFF888888);
  static const Color textLight    = Color(0xFFAAB2C0);


  static const Color darkBackground   = Color(0xFF0F1A2E);
  static const Color topBottomBar     = Color(0xFF0A1628);
  static const Color cardBackground   = Color(0xFF162033);
  static const Color inputFieldBg     = Color(0xFF1C2940);

  static const Color accentBlue       = Color(0xFF4A8AE8);
  static const Color selectedBorder   = Color(0xFF2A6BDB);

  static const Color textPrimary      = Color(0xFFFFFFFF);
  static const Color textSecondary    = Color(0xFF8A9BB5);
  static const Color iconUnselected   = Color(0xFF8A9BB5);


  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: white,
      dividerColor: border,
    );
  }

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