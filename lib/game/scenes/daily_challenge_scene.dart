import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'query_scene.dart';
import '../components/ui/game_button_component.dart';

class DailyChallengeScene extends QueryScene {
  @override
  Future<void> onLoad() async {
    final title = TextComponent(
      text: 'DAILY CYPHER',
      position: Vector2(40, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF8B92A5),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontFamily: 'Courier',
        ),
      ),
    );
    add(title);

    final backBtn = GameButtonComponent(
      title: 'BACK',
      size: Vector2(100, 40),
      position: Vector2(40, 100),
      onPressed: () {
        game.popScene();
      },
    );
    add(backBtn);

    final challengeTitle = TextComponent(
      text: 'SECURITY AUDIT',
      position: Vector2(40, 200),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD54F),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontFamily: 'Courier',
        ),
      ),
    );
    add(challengeTitle);
    
    final desc = TextComponent(
      text: 'We need to check who had failed login\nattempts recently.',
      position: Vector2(40, 250),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF8B92A5),
          fontSize: 16,
          height: 1.5,
          fontFamily: 'Courier',
        ),
      ),
    );
    add(desc);

    final startBtn = GameButtonComponent(
      title: 'START CHALLENGE',
      position: Vector2(40, 320),
      onPressed: () {
        // We need a LevelModel for daily challenge, for now just placeholder
        // game.pushScene(GameplayScene(level: ...));
      },
    );
    add(startBtn);
  }

  @override
  List<String> get activeOverlays => [];
}
