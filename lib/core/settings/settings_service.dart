import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool soundEffectsEnabled;
  final bool musicEnabled;
  final bool colorblindModeEnabled;

  const SettingsState({
    this.soundEffectsEnabled = true,
    this.musicEnabled = true,
    this.colorblindModeEnabled = false,
  });

  SettingsState copyWith({
    bool? soundEffectsEnabled,
    bool? musicEnabled,
    bool? colorblindModeEnabled,
  }) {
    return SettingsState(
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      colorblindModeEnabled: colorblindModeEnabled ?? this.colorblindModeEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    state = SettingsState(
      soundEffectsEnabled: _prefs.getBool('sound_effects_enabled') ?? true,
      musicEnabled: _prefs.getBool('music_enabled') ?? true,
      colorblindModeEnabled: _prefs.getBool('colorblind_mode_enabled') ?? false,
    );
  }

  Future<void> toggleSoundEffects(bool value) async {
    await _prefs.setBool('sound_effects_enabled', value);
    state = state.copyWith(soundEffectsEnabled: value);
  }

  Future<void> toggleMusic(bool value) async {
    await _prefs.setBool('music_enabled', value);
    state = state.copyWith(musicEnabled: value);
  }

  Future<void> toggleColorblindMode(bool value) async {
    await _prefs.setBool('colorblind_mode_enabled', value);
    state = state.copyWith(colorblindModeEnabled: value);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider not initialized');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
