import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Detective / Hacker theme design tokens (World 8).
class DetectiveTokens {
  DetectiveTokens._();

  // ─── Color palette ──────────────────────────────────────────────────────────
  static const background = Color(0xFF0A0F0D); // Very dark green-tinted black
  static const surface = Color(0xFF121B17);
  static const surfaceVariant = Color(0xFF1D2E26);
  static const surfaceHighlight = Color(0xFF284034);

  static const primaryText = Color(0xFFE0F2E9);
  static const secondaryText = Color(0xFF8FA89B);
  static const disabledText = Color(0xFF536A5E);
  static const hintText = Color(0xFF42564C);

  static const accent = Color(0xFF00FF41); // Hacker Neon Green
  static const accentDim = Color(0xFF008020);
  static const accentGlow = Color(0x4000FF41); 

  static const secondaryAccent = Color(0xFF33FF77);
  
  static const success = Color(0xFF00FF41);
  static const successSurface = Color(0xFF00330D);
  static const error = Color(0xFFFF2E63);
  static const errorSurface = Color(0xFF4A0D1D);
  static const warning = Color(0xFFFFB800);
  static const warningSurface = Color(0xFF4A3800);
  static const info = Color(0xFF00E6FF);

  // Result table diff colors
  static const resultMatch = Color(0xFF004D1A);
  static const resultExtra = Color(0xFF4A3800);
  static const resultMissing = Color(0xFF4A0D1D);

  // ─── Typography ──────────────────────────────────────────────────────────────
  static String? get headerFontFamily => GoogleFonts.shareTechMono().fontFamily;
  static String? get codeFontFamily => GoogleFonts.firaCode().fontFamily;

  static TextStyle get displayLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 2.0,
    height: 1.2,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: 1.5,
    height: 1.3,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: 1.0,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryText,
    letterSpacing: 0.8,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 13,
    color: primaryText,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 11,
    color: secondaryText,
    height: 1.4,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 1.5,
  );

  static TextStyle get code => TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.6,
    letterSpacing: 0.3,
  );

  static TextStyle get codeSmall => TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 12,
    color: primaryText,
    height: 1.5,
  );

  // ─── Spacing ─────────────────────────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // ─── Border radius ───────────────────────────────────────────────────────────
  static const double radiusNone = 0.0;
  static const double radiusSm = 0.0; // Blocky hacker aesthetic
  static const double radiusMd = 2.0;

  static final BorderRadius borderRadiusNone = BorderRadius.circular(radiusNone);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  // ─── Border / divider ────────────────────────────────────────────────────────
  static final BorderSide borderSide = BorderSide(color: accentDim, width: 1);
  static final BorderSide borderSideAccent = BorderSide(color: accent, width: 1);
  static final BorderSide borderSideError = BorderSide(color: error, width: 1);

  // ─── Animation durations ─────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ─── Full MaterialTheme ───────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondaryAccent,
        surface: surface,
        error: error,
        onPrimary: background,
        onSecondary: primaryText,
        onSurface: primaryText,
        onError: background,
      ),
      fontFamily: codeFontFamily,
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: titleLarge,
        surfaceTintColor: Colors.transparent,
        shadowColor: accentGlow,
        shape: Border(bottom: BorderSide(color: accentDim, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusSm,
          side: BorderSide(color: accentDim, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentDim,
          foregroundColor: accent,
          textStyle: labelLarge,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusSm,
            side: BorderSide(color: accent, width: 1),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: surfaceVariant,
      ),
      iconTheme: const IconThemeData(color: accent, size: 18),
      useMaterial3: true,
    );
  }
}
