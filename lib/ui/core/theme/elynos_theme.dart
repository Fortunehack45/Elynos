import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElyonsColors {
  // Grok Clean Sovereign Palette (Exact 1:1 match to Grok Screenshots)
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F8);
  static const Color surfaceElevated = Color(0xFFEEEEF0);
  static const Color border = Color(0xFFE5E7EB);
  static const Color accent = Color(0xFF000000);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color cardBg = Color(0xFFF9FAFB);
  static const Color userBubble = Color(0xFFF2F2F4);
  static const Color pillBg = Color(0xFFEAEAEB);
  static const Color actionIcon = Color(0xFF757575);
}

class ElyonsTheme {
  static ThemeData get grokTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ElyonsColors.background,
      primaryColor: ElyonsColors.accent,
      colorScheme: const ColorScheme.light(
        primary: ElyonsColors.accent,
        secondary: ElyonsColors.accentIndigo,
        surface: ElyonsColors.surface,
        background: ElyonsColors.background,
        onPrimary: Colors.white,
        onSurface: ElyonsColors.textPrimary,
        onBackground: ElyonsColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ElyonsColors.textPrimary,
            letterSpacing: -0.5,
          ),
          titleMedium: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ElyonsColors.textPrimary,
            letterSpacing: -0.3,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            color: ElyonsColors.textPrimary,
            height: 1.45,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14.5,
            color: ElyonsColors.textSecondary,
            height: 1.4,
          ),
          labelSmall: const TextStyle(
            fontSize: 12,
            color: ElyonsColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: ElyonsColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ElyonsColors.border, width: 1),
        ),
      ),
      dividerColor: ElyonsColors.border,
      useMaterial3: true,
    );
  }

  // Backward compatibility alias
  static ThemeData get darkTheme => grokTheme;
}
