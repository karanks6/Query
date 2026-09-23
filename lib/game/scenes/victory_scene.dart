import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'query_scene.dart';
import '../query_game.dart';
import '../components/persistent_hud.dart';
import '../components/game_button.dart';
import '../components/game_panel.dart';
import '../effects/particle_effects.dart';
import '../../core/scoring/level_scorer.dart';
import '../../data/content/models/level_model.dart';
import '../../features/gameplay/gameplay_provider.dart';
import '../../theming/tokens/game_tokens.dart';

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
  Future<void> onEnter() async {
    // Background dimming
    add(
      RectangleComponent(
        size: gameRef.size,
        paint: Paint()..color = Colors.black.withOpacity(0.7),
      ),
    );

    // Gold Rain Particles
    add(ParticleEffects.goldRain(gameRef.size));

    // Title
    final title = TextComponent(
      text: 'CASE CRACKED',
      textRenderer: TextPaint(
        style: GameTokens.headlineLarge.copyWith(
          color: GameTokens.success,
          fontSize: 48,
          shadows: [
            Shadow(
              color: GameTokens.success.withOpacity(0.5),
              blurRadius: 12,
            )
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameRef.size.x / 2, 100),
    );
    title.scale = Vector2.zero();
    title.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.bounceOut)));
    add(title);

    // Score Panel
    final panelWidth = 400.0;
    final panelHeight = 250.0;
    final panel = GamePanelComponent(
      size: Vector2(panelWidth, panelHeight),
      position: Vector2(gameRef.size.x / 2 - panelWidth / 2, 180),
      backgroundColor: GameTokens.surface,
      borderColor: GameTokens.success,
    );
    panel.scale = Vector2.zero();
    panel.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, startDelay: 0.2, curve: Curves.easeOut)));
    add(panel);

    // Stars
    final score = state.levelScore ?? const LevelScore.zero();
    for (int i = 0; i < 3; i++) {
      final earned = i < score.starCount;
      final starColor = earned ? GameTokens.accent : GameTokens.disabledText;
      final starX = gameRef.size.x / 2 - 80 + (i * 80);
      
      final star = TextComponent(
        text: '★',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 64,
            color: starColor,
            shadows: earned ? [Shadow(color: starColor.withOpacity(0.8), blurRadius: 10)] : [],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(starX, 150),
      );
      
      star.scale = Vector2.zero();
      star.add(SequenceEffect([
        ScaleEffect.to(Vector2.all(1.5), EffectController(duration: 0.3, startDelay: 0.5 + (i * 0.3))),
        ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.2)),
      ]));
      
      add(star);
    }

    // XP Breakdown
    final xpStart = Vector2(gameRef.size.x / 2 - 120, 240);
    
    final baseText = TextComponent(
      text: '+ ${score.xpEarned} XP BASE',
      textRenderer: TextPaint(style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText)),
      position: xpStart,
    );
    baseText.scale = Vector2.zero();
    baseText.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, startDelay: 1.5)));
    add(baseText);

    final totalText = TextComponent(
      text: '= ${score.xpEarned} XP TOTAL',
      textRenderer: TextPaint(style: GameTokens.headlineMedium.copyWith(color: GameTokens.accent)),
      position: xpStart + Vector2(0, 40),
    );
    totalText.scale = Vector2.zero();
    totalText.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, startDelay: 2.0)));
    add(totalText);

    // Buttons
    final btnWidth = 140.0;
    final btnSpacing = 20.0;
    final totalBtnsWidth = (btnWidth * 3) + (btnSpacing * 2);
    final startX = gameRef.size.x / 2 - totalBtnsWidth / 2 + btnWidth / 2;

    add(GameButtonComponent(
      text: 'MAP',
      size: Vector2(btnWidth, 50),
      position: Vector2(startX, 480),
      onPressed: onMap,
    ));

    add(GameButtonComponent(
      text: 'REPLAY',
      size: Vector2(btnWidth, 50),
      position: Vector2(startX + btnWidth + btnSpacing, 480),
      onPressed: onReplay,
    ));

    add(GameButtonComponent(
      text: 'NEXT LEVEL',
      size: Vector2(btnWidth, 50),
      position: Vector2(startX + (btnWidth + btnSpacing) * 2, 480),
      onPressed: onNextLevel,
    ));
  }
}
