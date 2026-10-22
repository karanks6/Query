import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:query/core/settings/settings_service.dart';

void main() {
  group('SettingsService & StateNotifier QA Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Initializes with default values when preferences are empty', () {
      final notifier = SettingsNotifier(prefs);

      expect(notifier.state.soundEffectsEnabled, isTrue);
      expect(notifier.state.musicEnabled, isTrue);
      expect(notifier.state.colorblindModeEnabled, isFalse);
    });

    test('Toggles sound effects and persists change to SharedPreferences', () async {
      final notifier = SettingsNotifier(prefs);

      await notifier.toggleSoundEffects(false);
      expect(notifier.state.soundEffectsEnabled, isFalse);
      expect(prefs.getBool('sound_effects_enabled'), isFalse);

      await notifier.toggleSoundEffects(true);
      expect(notifier.state.soundEffectsEnabled, isTrue);
      expect(prefs.getBool('sound_effects_enabled'), isTrue);
    });

    test('Toggles background music and persists change to SharedPreferences', () async {
      final notifier = SettingsNotifier(prefs);

      await notifier.toggleMusic(false);
      expect(notifier.state.musicEnabled, isFalse);
      expect(prefs.getBool('music_enabled'), isFalse);
    });

    test('Toggles colorblind mode accessibility setting and persists to SharedPreferences', () async {
      final notifier = SettingsNotifier(prefs);

      await notifier.toggleColorblindMode(true);
      expect(notifier.state.colorblindModeEnabled, isTrue);
      expect(prefs.getBool('colorblind_mode_enabled'), isTrue);
    });

    test('Loads pre-existing persisted preferences correctly on startup', () {
      prefs.setBool('sound_effects_enabled', false);
      prefs.setBool('music_enabled', false);
      prefs.setBool('colorblind_mode_enabled', true);

      final notifier = SettingsNotifier(prefs);

      expect(notifier.state.soundEffectsEnabled, isFalse);
      expect(notifier.state.musicEnabled, isFalse);
      expect(notifier.state.colorblindModeEnabled, isTrue);
    });
  });
}
