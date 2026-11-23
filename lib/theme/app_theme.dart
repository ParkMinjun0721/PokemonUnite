import 'package:flutter/material.dart';

class AppTheme {
  static final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xff504397),
    primary: const Color(0xff51429a),
    secondary: const Color(0xff96401e),
    secondaryContainer: const Color(0xffffe2cf),
    onSecondaryContainer: const Color(0xff482511),
    surface: const Color(0xfffaf9f6),
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      centerTitle: false,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
