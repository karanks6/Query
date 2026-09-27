import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Game URP theme design tokens (AAA Stylized / Persona / Arknights style).
///
/// Aesthetic: Sleek, utilitarian, high-contrast, character-driven
/// - Base — deep charcoal `#1A1C23`
/// - Base — panel surface `#2A2D35`
/// - Primary accent — agent gold `#FFCC00`
/// - Secondary — crimson alert `#E63946`
class GameTokens {
  GameTokens._();

  // ─── Color palette ──────────────────────────────────────────────────────────
  static const background = Color(0xFF2A180E); // Deep Wood
  static const surface = Color(0xFFF9F5EA); // Parchment Base
  static const surfaceVariant = Color(0xFFEFE6D5); // Parchment Darker
  static const surfaceHighlight = Color(0xFFFDFBF7); // Parchment Lighter

  static const primaryText = Color(0xFF2A180E); // Deep Wood (for text on parchment)
  static const secondaryText = Color(0xFF5C3D2E); // Medium Wood
  static const disabledText = Color(0xFF8C7A6B);
  static const hintText = Color(0xFF8C7A6B);

  static const accent = Color(0xFF4A7C59); // Forest Green
  static const accentDim = Color(0xFF2D5A3A); // Deep Forest
  static const accentGlow = Color(0x334A7C59);

  static const success = Color(0xFF4A7C59); // Forest Green
  static const successSurface = Color(0xFFD4E5D9);
  static const error = Color(0xFFB83A24); // Brick Red
  static const errorSurface = Color(0xFFF0D5D1);
  static const warning = Color(0xFFE59B28); // Amber Gold
  static const warningSurface = Color(0xFFFBEBD5);
  static const info = Color(0xFF2B5B84);
  static const rare = Color(0xFF7A4A8C);

  // Result table diff colors
  static const resultMatch = Color(0xFFD4E5D9);
  static const resultExtra = Color(0xFFFBEBD5);
  static const resultMissing = Color(0xFFF0D5D1);

  // ─── Typography ──────────────────────────────────────────────────────────────
  static String? get headerFontFamily => GoogleFonts.nunitoSans().fontFamily;
  static String? get bodyFontFamily => GoogleFonts.quicksand().fontFamily;

  static TextStyle get displayLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900, 
    color: primaryText,
    letterSpacing: 1.0,
    height: 1.1,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: primaryText,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: primaryText,
    letterSpacing: 0.2,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryText,
    letterSpacing: 0.1,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: accent,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: secondaryText,
    height: 1.4,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: surface, 
    letterSpacing: 0.5,
  );

  static TextStyle get code => TextStyle(
    fontFamily: GoogleFonts.firaCode().fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryText,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static TextStyle get codeSmall => TextStyle(
    fontFamily: GoogleFonts.firaCode().fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
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

  // ─── Border radius (Sleek/Clipping) ──────────────────────────────────────────
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 12.0;
  
  // Note: We'll use ClipPath for the large angled corners, so border radius is small
  static final BorderRadius borderRadiusNone = BorderRadius.circular(radiusNone);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  // ─── Border / divider ────────────────────────────────────────────────────────
  static final BorderSide borderSide = BorderSide(color: surfaceVariant, width: 2);
  static final BorderSide borderSideAccent = BorderSide(color: accent, width: 2);
  static final BorderSide borderSideError = BorderSide(color: error, width: 2);

  // ─── Animation durations ─────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 450);
  static const Duration durationCelebration = Duration(milliseconds: 800);
  static const Duration cursorBlinkDuration = Duration(milliseconds: 530);

  // ─── Elevation / shadows ─────────────────────────────────────────────────────
  static final List<BoxShadow> panelShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── Full MaterialTheme ───────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: error,
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
        backgroundColor: background,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headlineLarge,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMd,
          side: borderSide,
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          textStyle: labelLarge,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusSm,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          textStyle: labelLarge.copyWith(color: accent),
          side: borderSideAccent,
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
          textStyle: labelLarge.copyWith(color: accent),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        labelStyle: bodyMedium.copyWith(color: secondaryText),
        hintStyle: bodyMedium.copyWith(color: hintText),
        border: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceSm,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surfaceVariant,
        thickness: 2,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMd,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: surfaceVariant,
      ),
      iconTheme: const IconThemeData(color: primaryText, size: 20),
      useMaterial3: true,
    );
  }
}
