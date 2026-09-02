import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Sci-Fi URP theme design tokens (Translated from Unity/URP Plan).
///
/// Aesthetic: Stylized near-future sci-fi / technological realism
/// - Base — deep space `#0A0E1A`
/// - Base — panel surface `#141B2E`
/// - Primary accent — signal cyan `#00D9FF`
/// - Secondary — warning amber `#FFB800`
class SciFiTokens {
  SciFiTokens._();

  // ─── Color palette ──────────────────────────────────────────────────────────
  static const background = Color(0xFF0A0E1A);
  static const surface = Color(0xFF141B2E);
  static const surfaceVariant = Color(0xFF1D2743);
  static const surfaceHighlight = Color(0xFF263359);

  static const primaryText = Color(0xFFE8F4FF);
  static const secondaryText = Color(0xFF7C8AA3);
  static const disabledText = Color(0xFF4C5870);
  static const hintText = Color(0xFF5A6985);

  static const accent = Color(0xFF00D9FF); // Signal cyan
  static const accentDim = Color(0xFF008299);
  static const accentGlow = Color(0x4000D9FF); 

  static const success = Color(0xFF39FF9E);
  static const successSurface = Color(0xFF0D3320);
  static const error = Color(0xFFFF3B5C);
  static const errorSurface = Color(0xFF330C12);
  static const warning = Color(0xFFFFB800);
  static const warningSurface = Color(0xFF332500);
  static const info = Color(0xFF00D9FF);
  static const rare = Color(0xFFFF2E9A); // Rare magenta

  // Result table diff colors
  static const resultMatch = Color(0xFF0D3320);
  static const resultExtra = Color(0xFF332500);
  static const resultMissing = Color(0xFF330C12);

  // ─── Typography ──────────────────────────────────────────────────────────────
  static String? get headerFontFamily => GoogleFonts.exo2().fontFamily;
  static String? get bodyFontFamily => GoogleFonts.rajdhani().fontFamily;

  static TextStyle get displayLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 2.0,
    height: 1.2,
    shadows: const [Shadow(color: accentGlow, blurRadius: 10)],
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
    fontFamily: bodyFontFamily,
    fontSize: 16,
    color: primaryText,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
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
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.6,
    letterSpacing: 0.3,
  );

  static TextStyle get codeSmall => TextStyle(
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
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
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;

  static final BorderRadius borderRadiusNone = BorderRadius.circular(radiusNone);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  // ─── Border / divider ────────────────────────────────────────────────────────
  static final BorderSide borderSide = BorderSide(color: accentDim, width: 1);
  static final BorderSide borderSideAccent = BorderSide(color: accent, width: 1);
  static final BorderSide borderSideError = BorderSide(color: error, width: 1);

  // ─── Animation durations ─────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationNormal = Duration(milliseconds: 220);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationCelebration = Duration(milliseconds: 800);
  static const Duration cursorBlinkDuration = Duration(milliseconds: 530);

  // ─── Elevation / shadows ─────────────────────────────────────────────────────
  static final List<BoxShadow> holoShadow = [
    const BoxShadow(
      color: accentGlow,
      blurRadius: 15,
      spreadRadius: 1,
    ),
  ];

  static final List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: accentGlow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> accentGlowShadow = [
    const BoxShadow(
      color: accentGlow,
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // ─── Full MaterialTheme ───────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentDim,
        surface: surface,
        error: error,
        onPrimary: background,
        onSecondary: primaryText,
        onSurface: primaryText,
        onError: background,
      ),
      fontFamily: bodyFontFamily,
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
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusSm,
            side: const BorderSide(color: accent, width: 1),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          textStyle: labelLarge,
          side: BorderSide(color: accentDim, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusSm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        labelStyle: bodyMedium.copyWith(color: secondaryText),
        hintStyle: bodyMedium.copyWith(color: hintText),
        border: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: BorderSide(color: accentDim, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: BorderSide(color: accentDim, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceSm,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: accentDim,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusSm,
          side: BorderSide(color: accentDim, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: surfaceVariant,
      ),
      iconTheme: const IconThemeData(color: secondaryText, size: 18),
      useMaterial3: true,
    );
  }
}
