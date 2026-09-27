import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import 'gameplay_scene.dart';
import '../../features/daily_challenge/daily_challenge_service.dart';
import '../../data/content/models/level_model.dart';
import '../components/ui/wood_button.dart';
import '../components/ui/parchment_panel.dart';

class DailyChallengeScene extends QueryScene {
  LevelModel? _todayLevel;
  late PositionComponent layoutContainer;

  @override
  Future<void> onLoad() async {
    _todayLevel = await DailyChallengeService.instance.getTodayChallenge();
    
    // Warm wood desk background
    final bg = RectangleComponent(
      size: game.size,
      paint: Paint()..color = const Color(0xFF3D2817),
    );
    add(bg);

    layoutContainer = PositionComponent(
      size: Vector2(game.size.x, game.size.y - 60),
      position: Vector2(0, 60), // Push down to avoid notch
    );
    add(layoutContainer);

    _buildLayout();
  }

  void _buildLayout() {
    final availableWidth = game.size.x;
    final contentWidth = availableWidth > 440 ? 400.0 : availableWidth - 32;
    final centerX = availableWidth / 2;
    var yPos = 20.0;
    
    final title = TextComponent(
      text: 'DAILY FORAGE',
      position: Vector2(centerX, yPos),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFD48B3E), // Amber
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          shadows: [
            const Shadow(
              color: Color(0xFF1E1108),
              offset: Offset(0, 4),
              blurRadius: 4,
            )
          ]
        ),
      ),
    );
    layoutContainer.add(title);
    yPos += 50;

    final backBtn = WoodButton(
      text: 'BACK TO CAMP',
      size: Vector2(contentWidth, 50),
      position: Vector2(centerX - contentWidth / 2, yPos),
      primaryColor: const Color(0xFF7A6B5D),
      onPressed: () {
        game.popScene();
      },
    );
    layoutContainer.add(backBtn);
    yPos += 70;

    final challengePanel = ParchmentPanel(
      position: Vector2(centerX - contentWidth / 2, yPos),
      size: Vector2(contentWidth, 260),
    );
    layoutContainer.add(challengePanel);

    final challengeTitleText = _todayLevel?.title.toUpperCase() ?? 'NO SIGNAL';
    
    // Use TextBoxComponent to allow wrapping in case the title is long
    final challengeTitle = TextBoxComponent(
      text: challengeTitleText,
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF2A180E),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: contentWidth - 40,
      ),
    );
    challengePanel.add(challengeTitle);
    
    // Auto-wrapping text box for narrative
    final desc = TextBoxComponent(
      text: _todayLevel?.narrative ?? 'Unable to find today\'s trail. Return tomorrow.',
      position: Vector2(20, 80),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFF5C3D2E),
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: contentWidth - 40,
      ),
    );
    challengePanel.add(desc);

    yPos += 260 + 20;

    final startBtn = WoodButton(
      text: 'START EXPEDITION',
      secondaryText: 'REWARD: +250 ACORNS',
      position: Vector2(centerX - contentWidth / 2, yPos),
      size: Vector2(contentWidth, 80),
      primaryColor: const Color(0xFFD48B3E),
      onPressed: () {
        if (_todayLevel != null) {
          game.pushScene(GameplayScene(level: _todayLevel!));
        }
      },
    );
    layoutContainer.add(startBtn);
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (final child in children) {
      if (child is RectangleComponent && child.paint.color == const Color(0xFF3D2817)) {
        child.size = size;
      }
    }
    
    if (isLoaded) {
      layoutContainer.removeAll(layoutContainer.children);
      layoutContainer.size = Vector2(size.x, size.y - 60);
      _buildLayout();
    }
  }

  @override
  List<String> get activeOverlays => [];
}

