import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import '../components/ui/wood_button.dart';
import '../components/ui/parchment_panel.dart';
import '../effects/particle_effects.dart';
import '../../core/scoring/level_scorer.dart';
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
  Future<void> onEnter() async {
    // Background dimming
    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()..color = const Color(0xFF2C1B10).withValues(alpha: 0.8),
      ),
    );

    // Gold Rain Particles
    add(ParticleEffects.goldRain(game.size));

    // Title
    final title = TextComponent(
      text: 'TRAIL CLEARED',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA),
          fontSize: 48,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: const Color(0xFFD48B3E).withValues(alpha: 0.8),
              blurRadius: 12,
            )
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, 100),
    );
    title.scale = Vector2.zero();
    title.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.bounceOut)));
    add(title);

    // Score Panel
    final panelWidth = 400.0;
    final panelHeight = 250.0;
    final panel = ParchmentPanel(
      size: Vector2(panelWidth, panelHeight),
      position: Vector2(game.size.x / 2 - panelWidth / 2, 180),
    );
    panel.scale = Vector2.zero();
    panel.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, startDelay: 0.2, curve: Curves.easeOut)));
    add(panel);

    // Stars
    final score = state.levelScore ?? const LevelScore.zero();
    for (int i = 0; i < 3; i++) {
      final earned = i < score.starCount;
      final starColor = earned ? const Color(0xFFD48B3E) : const Color(0xFF9E8B75);
      final starX = game.size.x / 2 - 80 + (i * 80);
      
      final star = TextComponent(
        text: '★',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 64,
            color: starColor,
            shadows: earned ? [Shadow(color: starColor.withValues(alpha: 0.8), blurRadius: 10)] : [],
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
    final xpStart = Vector2(game.size.x / 2 - 120, 240);
    
    final baseText = TextComponent(
      text: '+ ${score.xpEarned} ACORNS BASE',
      textRenderer: TextPaint(style: GoogleFonts.quicksand(color: const Color(0xFF5C3D2E), fontSize: 18, fontWeight: FontWeight.bold)),
      position: xpStart,
    );
    baseText.scale = Vector2.zero();
    baseText.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, startDelay: 1.5)));
    add(baseText);

    final totalText = TextComponent(
      text: '= ${score.xpEarned} ACORNS TOTAL',
      textRenderer: TextPaint(style: GoogleFonts.nunitoSans(color: const Color(0xFF3D2817), fontSize: 24, fontWeight: FontWeight.w900)),
      position: xpStart + Vector2(0, 40),
    );
    totalText.scale = Vector2.zero();
    totalText.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, startDelay: 2.0)));
    add(totalText);

    // Buttons
    final btnWidth = 140.0;
    final btnSpacing = 20.0;
    final totalBtnsWidth = (btnWidth * 3) + (btnSpacing * 2);
    final startX = game.size.x / 2 - totalBtnsWidth / 2;
    final btnY = game.size.y - 80.0; // Always relative to screen bottom

    add(WoodButton(
      text: 'MAP',
      size: Vector2(btnWidth, 50),
      position: Vector2(startX, btnY),
      onPressed: onMap,
    ));

    add(WoodButton(
      text: 'REPLAY',
      size: Vector2(btnWidth, 50),
      position: Vector2(startX + btnWidth + btnSpacing, btnY),
      onPressed: onReplay,
    ));

    add(WoodButton(
      text: 'NEXT',
      size: Vector2(btnWidth, 50),
      position: Vector2(startX + (btnWidth + btnSpacing) * 2, btnY),
      primaryColor: const Color(0xFF4A7C59),
      onPressed: onNextLevel,
    ));
  }
}
