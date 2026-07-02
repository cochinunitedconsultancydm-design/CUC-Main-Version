import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Gold & White Palette
  static const primaryColor = Color(0xFFC5A028); // Rich Gold
  static const accentColor = Color(0xFFD4AF37); // Metallic Gold
  static const backgroundColor = Color(0xFFFFFFFF); // Pure White
  static const surfaceColor = Color(0xFFFDFDFD); // Off White
  static const textColor = Color(0xFF1A1A1A); // Deep Charcoal
  static const mutedTextColor = Color(0xFF71717A); // Zinc 400

  static final fallbackFonts = [
    'Nirmala UI',
    'Malayalam MN',
    'Kartika',
    'AnjaliOldLipi',
  ];

  static TextTheme _applyFallback(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontFamilyFallback: fallbackFonts),
      displayMedium: base.displayMedium?.copyWith(fontFamilyFallback: fallbackFonts),
      displaySmall: base.displaySmall?.copyWith(fontFamilyFallback: fallbackFonts),
      headlineLarge: base.headlineLarge?.copyWith(fontFamilyFallback: fallbackFonts),
      headlineMedium: base.headlineMedium?.copyWith(fontFamilyFallback: fallbackFonts),
      headlineSmall: base.headlineSmall?.copyWith(fontFamilyFallback: fallbackFonts),
      titleLarge: base.titleLarge?.copyWith(fontFamilyFallback: fallbackFonts),
      titleMedium: base.titleMedium?.copyWith(fontFamilyFallback: fallbackFonts),
      titleSmall: base.titleSmall?.copyWith(fontFamilyFallback: fallbackFonts),
      bodyLarge: base.bodyLarge?.copyWith(fontFamilyFallback: fallbackFonts),
      bodyMedium: base.bodyMedium?.copyWith(fontFamilyFallback: fallbackFonts),
      bodySmall: base.bodySmall?.copyWith(fontFamilyFallback: fallbackFonts),
      labelLarge: base.labelLarge?.copyWith(fontFamilyFallback: fallbackFonts),
      labelMedium: base.labelMedium?.copyWith(fontFamilyFallback: fallbackFonts),
      labelSmall: base.labelSmall?.copyWith(fontFamilyFallback: fallbackFonts),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onSurface: textColor,
        onPrimary: Colors.white,
      ),
      textTheme: _applyFallback(
        GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.1), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.05),
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
    );
  }
}
