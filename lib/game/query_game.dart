import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';

import 'scenes/query_scene.dart';
import 'components/scan_line_component.dart';
import 'components/parallax_world.dart';

class QueryGame extends FlameGame with RiverpodGameMixin, HasKeyboardHandlerComponents {
  QueryScene? currentScene;

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
  }

  Future<void> pushScene(QueryScene next) async {
    if (currentScene != null) {
      await currentScene!.onExit();
      remove(currentScene!);
    }
    
    currentScene = next;
    add(currentScene!);
    await currentScene!.onEnter();
    
    // Update active overlays
    overlays.clear();
    for (final overlay in next.activeOverlays) {
      overlays.add(overlay);
    }
  }

  Future<void> popScene() async {
    // Basic pop scene functionality if needed
  }
}
