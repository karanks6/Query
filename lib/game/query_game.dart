import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import '../core/audio/audio_controller.dart';
import 'scenes/query_scene.dart';
import 'components/scan_line_component.dart';
import 'components/parallax_world.dart';

class QueryGame extends FlameGame with RiverpodGameMixin {
  final List<QueryScene> sceneStack = [];

  late final ScanLineComponent scanLines;
  late final ParallaxWorldComponent parallax;

  @override
  Color backgroundColor() => const Color(0xFF15171E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    
    parallax = ParallaxWorldComponent();
    scanLines = ScanLineComponent();
    
    // Scanlines should be drawn on top of most things, 
    // but below the Flutter UI (since Flutter is an overlay).
    // The parallax is in the deep background.
    add(parallax);
    add(scanLines);

    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'ui_click.wav', 
      'celebration.wav',
      'ambient_dashboard.mp3',
      'bgm_world_01.mp3',
      'bgm_world_02.mp3',
      'bgm_world_03.mp3',
      'bgm_world_04.mp3'
    ]);
    ref.read(audioControllerProvider).playWorldBgm('dashboard');
  }

  Future<void> pushScene(QueryScene next) async {
    if (sceneStack.isNotEmpty) {
      await sceneStack.last.onExit();
      remove(sceneStack.last);
    }
    
    sceneStack.add(next);
    add(next);
    await next.onEnter();
    
    _updateOverlays();
  }

  Future<void> replaceScene(QueryScene next) async {
    if (sceneStack.isNotEmpty) {
      final old = sceneStack.removeLast();
      await old.onExit();
      remove(old);
    }
    
    sceneStack.add(next);
    add(next);
    await next.onEnter();
    
    _updateOverlays();
  }

  Future<void> popScene() async {
    if (sceneStack.length > 1) {
      final old = sceneStack.removeLast();
      await old.onExit();
      remove(old);

      final current = sceneStack.last;
      add(current);
      await current.onEnter();
      _updateOverlays();
    }
  }

  void _updateOverlays() {
    overlays.clear();
    if (sceneStack.isNotEmpty) {
      for (final overlay in sceneStack.last.activeOverlays) {
        overlays.add(overlay);
      }
    }
  }
}
