import 'package:flutter/material.dart';

class SorotTheme {
  static const Color primary = Color(0xFF2C6E49);
  static const Color background = Color(0xFFDEF2C8);
  static const Color card = Color(0xFFC5DAC1);
  static const Color surface = Color(0xFFBCD0C7);
  static const Color secondary = Color(0xFFA9B2AC);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
      ),
    );
  }
}
