import 'package:flutter/material.dart';

abstract final class VoidTheme {
  static const background = Color(0xFF0B0B14);
  static const surface = Color(0xFF171725);
  static const accent = Color(0xFFA78BFA);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: surface,
    ),
  );
}
