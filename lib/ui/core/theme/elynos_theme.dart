import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElyonsColors {
  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF1E242E);
  static const Color border = Color(0xFF262C36);
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color cardBg = Color(0xFF12161E);
}

class ElyonsTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ElyonsColors.background,
      primaryColor: ElyonsColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: ElyonsColors.accent,
        secondary: ElyonsColors.accentIndigo,
        surface: ElyonsColors.surface,
        background: ElyonsColors.background,
        onPrimary: Colors.black,
        onSurface: ElyonsColors.textPrimary,
        onBackground: ElyonsColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ElyonsColors.textPrimary,
            letterSpacing: -0.5,
          ),
          titleMedium: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ElyonsColors.textPrimary,
            letterSpacing: -0.3,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: ElyonsColors.textPrimary,
            height: 1.5,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: ElyonsColors.textSecondary,
            height: 1.4,
          ),
          labelSmall: const TextStyle(
            fontSize: 12,
            color: ElyonsColors.textMuted,
            fontWeight: FontWeight.w500,
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
}
