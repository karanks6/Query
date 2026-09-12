import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tokens/game_tokens.dart';
import 'tokens/cyberpunk_tokens.dart';
import 'tokens/nature_tokens.dart';
import 'tokens/space_tokens.dart';
import 'tokens/medieval_tokens.dart';
import 'tokens/detective_tokens.dart';

/// All available themes (Section 6.1).
/// v1.0 ships Terminal/Classic. Others are unlocked in later phases.
enum AppTheme {
  terminalClassic('terminal_classic', 'Terminal / Classic'),
  cyberpunk('cyberpunk', 'Cyberpunk / Data Center'),
  nature('nature', 'Nature / Organic Data'),
  space('space', 'Space / Cosmic Database'),
  medieval('medieval', 'Medieval / Archival'),
  detective('detective', 'Detective / Hacker');

  final String id;
  final String displayName;
  const AppTheme(this.id, this.displayName);

  static AppTheme fromId(String id) {
    return AppTheme.values.firstWhere(
      (t) => t.id == id,
      orElse: () => AppTheme.terminalClassic,
    );
  }
}

/// Central theme provider â€” manages the active theme and returns
/// the MaterialThemeData for the currently active theme.
class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.terminalClassic);

  void setTheme(AppTheme theme) => state = theme;
  void setThemeById(String id) => state = AppTheme.fromId(id);
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);

/// Returns the [ThemeData] for the currently active theme.
final activeThemeDataProvider = Provider<ThemeData>((ref) {
  final theme = ref.watch(themeNotifierProvider);
  switch (theme) {
    case AppTheme.terminalClassic:
      return GameTokens.themeData;
    case AppTheme.cyberpunk:
      return CyberpunkTokens.themeData;
    case AppTheme.nature:
      return NatureTokens.themeData;
    case AppTheme.space:
      return SpaceTokens.themeData;
    case AppTheme.medieval:
      return MedievalTokens.themeData;
    case AppTheme.detective:
      return DetectiveTokens.themeData;
  }
});

/// Returns the active [AppThemeTokens] for direct token access in widgets.
final activeTokensProvider = Provider<AppThemeTokens>((ref) {
  final theme = ref.watch(themeNotifierProvider);
  switch (theme) {
    case AppTheme.cyberpunk:
      return CyberpunkAppThemeTokens();
    case AppTheme.nature:
      return NatureAppThemeTokens();
    case AppTheme.space:
      return SpaceAppThemeTokens();
    case AppTheme.medieval:
      return MedievalAppThemeTokens();
    case AppTheme.detective:
      return DetectiveAppThemeTokens();
    case AppTheme.terminalClassic:
      return TerminalClassicAppThemeTokens();
  }
});

/// Abstract base class for typed token access in widgets.
/// This avoids hard-coding the theme name in every widget.
abstract class AppThemeTokens {
  Color get background;
  Color get surface;
  Color get surfaceVariant;
  Color get primaryText;
  Color get secondaryText;
  Color get accent;
  Color get success;
  Color get error;
  Color get warning;
  Color get accentGlow;
  Duration get durationNormal;
  Duration get durationFast;
}

class TerminalClassicAppThemeTokens implements AppThemeTokens {
  @override Color get background => GameTokens.background;
  @override Color get surface => GameTokens.surface;
  @override Color get surfaceVariant => GameTokens.surfaceVariant;
  @override Color get primaryText => GameTokens.primaryText;
  @override Color get secondaryText => GameTokens.secondaryText;
  @override Color get accent => GameTokens.accent;
  @override Color get success => GameTokens.success;
  @override Color get error => GameTokens.error;
  @override Color get warning => GameTokens.warning;
  @override Color get accentGlow => GameTokens.accentGlow;
  @override Duration get durationNormal => GameTokens.durationNormal;
  @override Duration get durationFast => GameTokens.durationFast;
}

class CyberpunkAppThemeTokens implements AppThemeTokens {
  @override Color get background => CyberpunkTokens.background;
  @override Color get surface => CyberpunkTokens.surface;
  @override Color get surfaceVariant => CyberpunkTokens.surfaceVariant;
  @override Color get primaryText => CyberpunkTokens.primaryText;
  @override Color get secondaryText => CyberpunkTokens.secondaryText;
  @override Color get accent => CyberpunkTokens.accent;
  @override Color get success => CyberpunkTokens.success;
  @override Color get error => CyberpunkTokens.error;
  @override Color get warning => CyberpunkTokens.warning;
  @override Color get accentGlow => CyberpunkTokens.accentGlow;
  @override Duration get durationNormal => const Duration(milliseconds: 220);
  @override Duration get durationFast => const Duration(milliseconds: 120);
}

class NatureAppThemeTokens implements AppThemeTokens {
  @override Color get background => NatureTokens.background;
  @override Color get surface => NatureTokens.surface;
  @override Color get surfaceVariant => NatureTokens.surfaceVariant;
  @override Color get primaryText => NatureTokens.primaryText;
  @override Color get secondaryText => NatureTokens.secondaryText;
  @override Color get accent => NatureTokens.accent;
  @override Color get success => NatureTokens.success;
  @override Color get error => NatureTokens.error;
  @override Color get warning => NatureTokens.warning;
  @override Color get accentGlow => NatureTokens.accentGlow;
  @override Duration get durationNormal => const Duration(milliseconds: 220);
  @override Duration get durationFast => const Duration(milliseconds: 120);
}

class SpaceAppThemeTokens implements AppThemeTokens {
  @override Color get background => SpaceTokens.background;
  @override Color get surface => SpaceTokens.surface;
  @override Color get surfaceVariant => SpaceTokens.surfaceVariant;
  @override Color get primaryText => SpaceTokens.primaryText;
  @override Color get secondaryText => SpaceTokens.secondaryText;
  @override Color get accent => SpaceTokens.accent;
  @override Color get success => SpaceTokens.success;
  @override Color get error => SpaceTokens.error;
  @override Color get warning => SpaceTokens.warning;
  @override Color get accentGlow => SpaceTokens.accentGlow;
  @override Duration get durationNormal => const Duration(milliseconds: 220);
  @override Duration get durationFast => const Duration(milliseconds: 120);
}

class MedievalAppThemeTokens implements AppThemeTokens {
  @override Color get background => MedievalTokens.background;
  @override Color get surface => MedievalTokens.surface;
  @override Color get surfaceVariant => MedievalTokens.surfaceVariant;
  @override Color get primaryText => MedievalTokens.primaryText;
  @override Color get secondaryText => MedievalTokens.secondaryText;
  @override Color get accent => MedievalTokens.accent;
  @override Color get success => MedievalTokens.success;
  @override Color get error => MedievalTokens.error;
  @override Color get warning => MedievalTokens.warning;
  @override Color get accentGlow => MedievalTokens.accentGlow;
  @override Duration get durationNormal => const Duration(milliseconds: 220);
  @override Duration get durationFast => const Duration(milliseconds: 120);
}

class DetectiveAppThemeTokens implements AppThemeTokens {
  @override Color get background => DetectiveTokens.background;
  @override Color get surface => DetectiveTokens.surface;
  @override Color get surfaceVariant => DetectiveTokens.surfaceVariant;
  @override Color get primaryText => DetectiveTokens.primaryText;
  @override Color get secondaryText => DetectiveTokens.secondaryText;
  @override Color get accent => DetectiveTokens.accent;
  @override Color get success => DetectiveTokens.success;
  @override Color get error => DetectiveTokens.error;
  @override Color get warning => DetectiveTokens.warning;
  @override Color get accentGlow => DetectiveTokens.accentGlow;
  @override Duration get durationNormal => const Duration(milliseconds: 200);
  @override Duration get durationFast => const Duration(milliseconds: 100);
}
