import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'query_scene.dart';
import '../effects/particle_effects.dart';
import '../../data/content/models/level_model.dart';
import '../../features/gameplay/gameplay_provider.dart';

class VictoryScene extends QueryScene {
  final LevelModel level;
  final GameplayState state;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onMap;

  VictoryScene({
    required this.level,
    required this.state,
    required this.onNextLevel,
    required this.onReplay,
    required this.onMap,
  });

  @override
  List<String> get activeOverlays => ['victory_overlay'];

  @override
  Future<void> onEnter() async {
    // Cinematic background dimming
    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()..color = const Color(0xFF140B06).withValues(alpha: 0.85),
      ),
    );

    // Gold Rain celebration particles behind the modal
    add(ParticleEffects.goldRain(game.size));
  }
}

