import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';
import '../settings/settings_service.dart';

class AudioController {
  final Ref ref;

  AudioController(this.ref) {
    _init();
  }

  void _init() {
    ref.listen(settingsProvider, (previous, next) {
      if (previous?.musicEnabled != next.musicEnabled) {
        if (!next.musicEnabled) {
          stopBgm();
        } else {
          // Ideally resume previous bgm if we kept track of it.
        }
      }
    });
  }

  Future<void> playSfx(String sfxId) async {
    final settings = ref.read(settingsProvider);
    if (!settings.soundEffectsEnabled) return;
    
    try {
      await FlameAudio.play(sfxId);
    } catch (e) {
      debugPrint('[AudioController] Error playing SFX $sfxId: $e');
    }
  }

  Future<void> playBgm(String bgmId) async {
    final settings = ref.read(settingsProvider);
    if (!settings.musicEnabled) return;

    try {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.stop();
      }
      await FlameAudio.bgm.play(bgmId);
    } catch (e) {
      debugPrint('[AudioController] Error playing BGM $bgmId: $e');
    }
  }

  void stopBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.stop();
    }
  }
}

final audioControllerProvider = Provider<AudioController>((ref) {
  return AudioController(ref);
});
