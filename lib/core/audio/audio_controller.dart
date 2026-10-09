import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';
import '../settings/settings_service.dart';

class AudioController {
  final Ref ref;
  String? _currentBgm;

  static const Map<String, String> _worldBgmMap = {
    'dashboard': 'ambient_dashboard.mp3',
    'world_01_archive_vaults': 'bgm_world_01.mp3',
    'world_02_filter_district': 'bgm_world_02.mp3',
    'world_03_aggregation_district': 'bgm_world_03.mp3',
    'world_04_join_nexus': 'bgm_world_04.mp3',
  };

  AudioController(this.ref) {
    _init();
  }

  void _init() {
    ref.listen(settingsProvider, (previous, next) {
      if (previous?.musicEnabled != next.musicEnabled) {
        if (!next.musicEnabled) {
          stopBgm();
        } else if (_currentBgm != null) {
          playBgm(_currentBgm!);
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

  Future<void> playWorldBgm(String worldId) async {
    final track = _worldBgmMap[worldId] ?? 'ambient_dashboard.mp3';
    await playBgm(track);
  }

  Future<void> playBgm(String bgmId) async {
    _currentBgm = bgmId;
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

  Future<void> playCelebration() async {
    final settings = ref.read(settingsProvider);
    if (settings.musicEnabled && FlameAudio.bgm.isPlaying) {
      // Pause music briefly
      FlameAudio.bgm.pause();
    }
    
    if (settings.soundEffectsEnabled) {
      try {
        await FlameAudio.play('celebration.wav');
      } catch (e) {
        debugPrint('[AudioController] Error playing celebration: $e');
      }
    }
    
    // Resume after 2.5 seconds
    if (settings.musicEnabled) {
      Timer(const Duration(milliseconds: 2500), () {
        if (_currentBgm != null && !FlameAudio.bgm.isPlaying) {
          FlameAudio.bgm.resume();
        }
      });
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
