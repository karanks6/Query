import 'package:flutter/material.dart';

/// Medieval / Archival theme design tokens (Section 6.6).
class MedievalTokens {
  MedievalTokens._();

  static const background = Color(0xFF2B1D12);
  static const surface = Color(0xFF3C2A18);
  static const surfaceVariant = Color(0xFF563E26);
  
  static const primaryText = Color(0xFFF0E4C8);
  static const secondaryText = Color(0xFFB8A282);
  
  static const accent = Color(0xFFC89B3C); // Gold leaf
  static const accentDim = Color(0xFF76581C);
  static const accentGlow = Color(0x40C89B3C);
  
  static const success = Color(0xFF7A9B5C);
  static const error = Color(0xFF9B3C3C); // Wax-seal red
  static const warning = Color(0xFFC89B3C);

  static const headerFontFamily = 'Cormorant';
  static const codeFontFamily = 'JetBrainsMono';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: accent,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryText,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: accent,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 14,
    color: primaryText,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 13,
    color: primaryText,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: codeFontFamily,
    fontSize: 11,
    color: secondaryText,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: accent,
  );

  static final BorderRadius borderRadiusMd = BorderRadius.circular(4.0);

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
      textTheme: const TextTheme(
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
        shape: Border(bottom: BorderSide(color: accentDim, width: 2)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMd,
          side: BorderSide(color: accentDim, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: error, // Wax-seal accent
          foregroundColor: primaryText,
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
      iconTheme: const IconThemeData(color: accent, size: 18),
      useMaterial3: true,
    );
  }
}
