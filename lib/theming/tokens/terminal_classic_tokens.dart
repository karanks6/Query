import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Terminal/Classic theme design tokens (Section 6.2).
///
/// Retro CRT hacker-terminal aesthetic:
/// - Near-black background with green cast
/// - JetBrains Mono throughout (UI chrome + code)
/// - Monoline glyph icons
/// - Cursor-blink accents
/// - Mechanical keyboard click sounds
class TerminalClassicTokens {
  TerminalClassicTokens._();

  // ─── Color palette ──────────────────────────────────────────────────────────
  static const background = Color(0xFF0A0E0A);
  static const surface = Color(0xFF12160F);
  static const surfaceVariant = Color(0xFF1A1F18);
  static const surfaceHighlight = Color(0xFF22291F);

  static const primaryText = Color(0xFFC8FFC8);
  static const secondaryText = Color(0xFF7FB87F);
  static const disabledText = Color(0xFF4A6B4A);
  static const hintText = Color(0xFF3D5C3D);

  static const accent = Color(0xFF39FF6A); // Neon green
  static const accentDim = Color(0xFF1E8C3A);
  static const accentGlow = Color(0x4039FF6A); // 25% alpha for glow effects

  static const success = Color(0xFF39FF6A);
  static const successSurface = Color(0xFF0D2E1A);
  static const error = Color(0xFFFF5C5C);
  static const errorSurface = Color(0xFF2E0D0D);
  static const warning = Color(0xFFFFD54A);
  static const warningSurface = Color(0xFF2E250D);
  static const info = Color(0xFF4ACFFF);

  // Result table diff colors
  static const resultMatch = Color(0xFF0D2E1A);
  static const resultExtra = Color(0xFF2E1A0D);
  static const resultMissing = Color(0xFF2E0D1A);

  // ─── Typography ──────────────────────────────────────────────────────────────
  // JetBrains Mono throughout (terminal conceit)
  static String? get fontFamily => GoogleFonts.jetBrainsMono().fontFamily;

  static TextStyle get displayLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 2.0,
    height: 1.2,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: 1.5,
    height: 1.3,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: 1.0,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryText,
    letterSpacing: 0.8,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    color: primaryText,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: secondaryText,
    height: 1.4,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: accent,
    letterSpacing: 1.5,
  );

  static TextStyle get code => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.6,
    letterSpacing: 0.3,
  );

  static TextStyle get codeSmall => TextStyle(
    fontFamily: fontFamily,
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
  // Terminal theme: sharp corners by default, very slight rounding max
  static const double radiusNone = 0.0;
  static const double radiusSm = 2.0;
  static const double radiusMd = 4.0;

  static final BorderRadius borderRadiusNone = BorderRadius.circular(radiusNone);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  // ─── Border / divider ────────────────────────────────────────────────────────
  static final BorderSide borderSide = BorderSide(color: accentDim, width: 1);
  static final BorderSide borderSideAccent = BorderSide(color: accent, width: 1);
  static final BorderSide borderSideError = BorderSide(color: error, width: 1);

  // ─── Animation durations ─────────────────────────────────────────────────────
  // "Calm motion" — subtle, not distracting
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationNormal = Duration(milliseconds: 220);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationCelebration = Duration(milliseconds: 800);

  // Cursor blink (the signature element — Section 6.2)
  static const Duration cursorBlinkDuration = Duration(milliseconds: 530);

  // ─── Elevation / shadows ─────────────────────────────────────────────────────
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: accentGlow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> accentGlowShadow = [
    BoxShadow(
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
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentDim,
        surface: surface,
        error: error,
        onPrimary: background,
        onSecondary: primaryText,
        onSurface: primaryText,
        onError: background,
      ),
      fontFamily: fontFamily,
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
            side: BorderSide(color: accent, width: 1),
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
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: BorderSide(color: error, width: 1),
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



