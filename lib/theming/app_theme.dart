import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tokens/terminal_classic_tokens.dart';

/// All available themes (Section 6.1).
/// v1.0 ships Terminal/Classic. Others are unlocked in later phases.
enum AppTheme {
  terminalClassic('terminal_classic', 'Terminal / Classic'),
  cyberpunk('cyberpunk', 'Cyberpunk / Data Center'),
  nature('nature', 'Nature / Organic Data'),
  space('space', 'Space / Cosmic Database'),
  medieval('medieval', 'Medieval / Archival');

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

/// Central theme provider — manages the active theme and returns
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
      return TerminalClassicTokens.themeData;
    // Future themes return their own ThemeData
    default:
      return TerminalClassicTokens.themeData;
  }
});

/// Returns the active [AppThemeTokens] for direct token access in widgets.
final activeTokensProvider = Provider<AppThemeTokens>((ref) {
  final theme = ref.watch(themeNotifierProvider);
  switch (theme) {
    case AppTheme.terminalClassic:
    default:
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
  @override Color get background => TerminalClassicTokens.background;
  @override Color get surface => TerminalClassicTokens.surface;
  @override Color get surfaceVariant => TerminalClassicTokens.surfaceVariant;
  @override Color get primaryText => TerminalClassicTokens.primaryText;
  @override Color get secondaryText => TerminalClassicTokens.secondaryText;
  @override Color get accent => TerminalClassicTokens.accent;
  @override Color get success => TerminalClassicTokens.success;
  @override Color get error => TerminalClassicTokens.error;
  @override Color get warning => TerminalClassicTokens.warning;
  @override Color get accentGlow => TerminalClassicTokens.accentGlow;
  @override Duration get durationNormal => TerminalClassicTokens.durationNormal;
  @override Duration get durationFast => TerminalClassicTokens.durationFast;
}
