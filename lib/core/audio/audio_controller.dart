import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_service.dart';

class AudioController {
  final Ref ref;

  AudioController(this.ref) {
    // Listen to settings changes if needed
  }

  void playSfx(String sfxId) {
    final settings = ref.read(settingsProvider);
    if (!settings.soundEffectsEnabled) return;
    
    // In a real implementation, this would use audioplayers or similar.
    // For now, we mock the audio playback.
    debugPrint('[AudioController] Playing SFX: $sfxId');
  }

  void playBgm(String bgmId) {
    final settings = ref.read(settingsProvider);
    if (!settings.musicEnabled) return;

    // Mock background music playback
    debugPrint('[AudioController] Playing BGM: $bgmId');
  }

  void stopBgm() {
    debugPrint('[AudioController] Stopping BGM');
  }
}

final audioControllerProvider = Provider<AudioController>((ref) {
  return AudioController(ref);
});
