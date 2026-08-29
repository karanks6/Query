import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Nature / Organic Data theme design tokens (Section 6.4).
class NatureTokens {
  NatureTokens._();

  static const background = Color(0xFF0C1710);
  static const surface = Color(0xFF16241A);
  static const surfaceVariant = Color(0xFF223829);
  
  static const primaryText = Color(0xFFE4EDDD);
  static const secondaryText = Color(0xFF9CB8A2);
  
  static const accent = Color(0xFF7FB069); // Moss/fern
  static const accentDim = Color(0xFF456B36);
  static const accentGlow = Color(0x407FB069);

  static const success = Color(0xFF7FB069);
  static const error = Color(0xFFD46A54);
  static const warning = Color(0xFFD9A441);

  static String? get headerFontFamily => GoogleFonts.poppins().fontFamily;
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

  static final BorderRadius borderRadiusLg = BorderRadius.circular(16.0);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(8.0);

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
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
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
            borderRadius: borderRadiusMd,
          ),
        ),
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



