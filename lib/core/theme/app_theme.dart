import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Deep Space Glassmorphism theme
/// Primary: Electric indigo + cyan aurora
/// Glass: rgba layers with blur
/// Typography: Syne (display) + DM Sans (body)
class AppColors {
  // ── Core Background ─────────────────────────────────────────────────────
  static const Color bg0 = Color(0xFF040B1A); // deepest void
  static const Color bg1 = Color(0xFF070F23); // base background
  static const Color bg2 = Color(0xFF0C1530); // elevated surface

  // ── Glass Layers ────────────────────────────────────────────────────────
  static const Color glass1 = Color(0x14FFFFFF); // 8% white
  static const Color glass2 = Color(0x1AFFFFFF); // 10% white
  static const Color glass3 = Color(0x26FFFFFF); // 15% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white border
  static const Color glassBorderStrong = Color(0x55FFFFFF); // 33%

  // ── Neon Accents ────────────────────────────────────────────────────────
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonBlue = Color(0xFF2979FF);
  static const Color neonPurple = Color(0xFF7C4DFF);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonAmber = Color(0xFFFFAB00);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color neonPink = Color(0xFFFF4081);

  // ── Gradient Orbs ───────────────────────────────────────────────────────
  static const Color orb1 = Color(0xFF1A0533); // deep purple
  static const Color orb2 = Color(0xFF001A40); // deep blue
  static const Color orb3 = Color(0xFF00261A); // deep teal

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8899BB);
  static const Color textMuted = Color(0xFF445577);

  // ── Status ──────────────────────────────────────────────────────────────
  static const Color online = neonGreen;
  static const Color offline = neonRed;
  static const Color warning = neonAmber;
  static const Color info = neonCyan;

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonBlue, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bg0, bg1, bg2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.04),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg0,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonBlue,
        surface: AppColors.bg2,
        error: AppColors.neonRed,
        onPrimary: AppColors.bg0,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.syne(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glass2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonRed, width: 1),
        ),
        hintStyle: GoogleFonts.dmSans(
            color: AppColors.textMuted, fontSize: 14),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.syne(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
