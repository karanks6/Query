import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
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
  late final SceneTransitionComponent transitionCurtain;

  @override
  Color backgroundColor() => const Color(0xFF15171E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    
    parallax = ParallaxWorldComponent();
    scanLines = ScanLineComponent();
    transitionCurtain = SceneTransitionComponent()..priority = 1000;
    
    // Scanlines should be drawn on top of most things, 
    // but below the Flutter UI (since Flutter is an overlay).
    // The parallax is in the deep background.
    add(parallax);
    add(scanLines);
    add(transitionCurtain);

    final isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      try {
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
      } catch (e) {
        debugPrint('[QueryGame] Audio initialization skipped or failed: $e');
      }
    }
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
    if (isLoaded && transitionCurtain.isMounted) {
      transitionCurtain.fadeFromDark();
    }
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
    if (isLoaded && transitionCurtain.isMounted) {
      transitionCurtain.fadeFromDark();
    }
  }

  Future<void> popScene() async {
    if (sceneStack.length > 1) {
      final old = sceneStack.removeLast();
      await old.onExit();
      if (old.parent != null) {
        remove(old);
      }

      final current = sceneStack.last;
      if (current.parent == null) {
        add(current);
      }
      await current.onEnter();
      _updateOverlays();
      if (isLoaded && transitionCurtain.isMounted) {
        transitionCurtain.fadeFromDark();
      }
    }
  }

  Future<void> popToScene(Type sceneType) async {
    while (sceneStack.length > 1 && sceneStack.last.runtimeType != sceneType) {
      final old = sceneStack.removeLast();
      await old.onExit();
      if (old.parent != null) {
        remove(old);
      }
    }
    if (sceneStack.isNotEmpty) {
      final current = sceneStack.last;
      if (current.parent == null) {
        add(current);
      }
      await current.onEnter();
      _updateOverlays();
      if (isLoaded && transitionCurtain.isMounted) {
        transitionCurtain.fadeFromDark();
      }
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

/// A high-performance cinematic transition curtain that smoothly fades between scenes.
class SceneTransitionComponent extends PositionComponent {
  double _opacity = 0.0;

  void fadeFromDark() {
    _opacity = 0.85;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_opacity > 0.0) {
      _opacity -= dt * 4.5; // ~200ms smooth organic fade out
      if (_opacity < 0.0) {
        _opacity = 0.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0.0) return;

    final paint = Paint()
      ..color = const Color(0xFF140803).withValues(alpha: _opacity.clamp(0.0, 1.0));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    if (_opacity > 0.20) {
      final glintPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.x * 0.5, size.y * 0.5),
          size.y * 0.45,
          [
            const Color(0xFFE59B28).withValues(alpha: (_opacity * 0.20).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          const [0.0, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), glintPaint);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
