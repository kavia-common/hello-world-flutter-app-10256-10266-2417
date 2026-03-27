import 'package:flutter/material.dart';

class AppTheme {
  // Kotlin screenshot tokens
  static const Color _purplePrimary = Color(0xFF5A2DFF);
  static const Color _tealFab = Color(0xFF18C6B8);

  static const Color _canvas = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFFFFFFF);

  static const Color _textPrimary = Color(0xFF111111);
  static const Color _textSecondary = Color(0xFF6B6B6B);

  static const Color _fieldBorder = Color(0xFFDADADA);
  static const Color _cardBorder = Color(0xFFE6E6E6);

  // PUBLIC_INTERFACE
  /// Theme aligned to the Kotlin Offline Notes app screenshots.
  ///
  /// Visual goals:
  /// - Purple AppBar + primary controls (#5A2DFF)
  /// - Teal FAB (#18C6B8)
  /// - White canvas + surfaces
  /// - Outlined text fields with small radius and light grey border
  /// - Flat "card" list items with subtle border and small radius
  static ThemeData kotlinNotesLight() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _purplePrimary,
      brightness: Brightness.light,
    );

    final scheme = baseScheme.copyWith(
      primary: _purplePrimary,
      onPrimary: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _fieldBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: _canvas,

      // Keep default platform font (Roboto on Android) to match the Kotlin feel.
      fontFamily: null,

      appBarTheme: const AppBarTheme(
        backgroundColor: _purplePrimary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _tealFab,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      textTheme: const TextTheme(
        // Used for list item title and screen section titles
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),

        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.25, color: _textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.25, color: _textPrimary),

        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _textSecondary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: _fieldBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: _fieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: _purplePrimary, width: 1.2),
        ),
      ),

      cardTheme: CardTheme(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: _cardBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: _cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
