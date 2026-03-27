import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seed = Color(0xFF7C4DFF);
  static const Color _bg = Color(0xFFF2F4F7);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surface2 = Color(0xFFE9EDF3);

  // PUBLIC_INTERFACE
  /// Light grey Material 3 theme used by the app.
  static ThemeData lightGrey() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ).copyWith(
      surface: _surface,
      surfaceContainerHighest: _surface2,
      onSurface: const Color(0xFF111827),
      onSurfaceVariant: const Color(0xFF374151),
      outline: const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _bg,
      fontFamily: '.SF Pro Text',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.25),
        bodyMedium: TextStyle(fontSize: 14, height: 1.25),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withAlpha(150)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withAlpha(200)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withAlpha(200)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withAlpha(230), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withAlpha(160),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
