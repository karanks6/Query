import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Space / Cosmic Database theme design tokens (Section 6.5).
class SpaceTokens {
  SpaceTokens._();

  static const background = Color(0xFF050414);
  static const surface = Color(0xFF0E0C29);
  static const surfaceVariant = Color(0xFF1E194D);
  
  static const primaryText = Color(0xFFE8E6FF);
  static const secondaryText = Color(0xFFA19CCC);
  
  static const accent = Color(0xFF8B5CF6); // Purple
  static const accentDim = Color(0xFF4A3184);
  static const accentGlow = Color(0x408B5CF6);
  
  static const success = Color(0xFF5CE1E6); // Cyan
  static const error = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFD166);

  static String? get headerFontFamily => GoogleFonts.spaceGrotesk().fontFamily;
  static String? get codeFontFamily => GoogleFonts.jetBrainsMono().fontFamily;

  static TextStyle get displayLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: accent,
  );
  
  static TextStyle get displayMedium => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );
  
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );
  
  static TextStyle get headlineMedium => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryText,
  );
  
  static TextStyle get titleLarge => TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: accent,
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
  );

  static final BorderRadius borderRadiusCircle = BorderRadius.circular(100.0);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(12.0);

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
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMd,
          side: BorderSide(color: accentDim, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentDim,
          foregroundColor: accent,
          textStyle: labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusCircle,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: success,
        linearTrackColor: surfaceVariant,
      ),
      iconTheme: const IconThemeData(color: success, size: 18),
      useMaterial3: true,
    );
  }
}



