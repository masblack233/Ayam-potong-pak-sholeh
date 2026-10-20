import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Warna utama ───────────────────────────────────────────
  static const Color primary = Color(0xFFE8521A);
  static const Color primaryDark = Color(0xFFC43D0A);
  static const Color primaryLight = Color(0xFFFF7043);

  static const Color secondary = Color(0xFF1A1A2E);
  static const Color secondaryLight = Color(0xFF16213E);

  static const Color accent = Color(0xFFF4C430);
  static const Color accentDark = Color(0xFFD4A820);

  static const Color surface = Color(0xFF0F0F23);
  static const Color surfaceCard = Color(0xFF1C1C35);
  static const Color surfaceElevated = Color(0xFF252545);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF707090);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  static const Color divider = Color(0xFF2A2A4A);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [surface, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceCard, surfaceElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Theme Data ────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w400, color: textMuted,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceCard,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primary.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.outfit(fontSize: 13, color: textPrimary),
        side: const BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.outfit(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
    );
  }
}
