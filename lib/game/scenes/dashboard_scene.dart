import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'query_scene.dart';
import 'world_select_scene.dart';
import 'daily_challenge_scene.dart';
import '../components/persistent_hud.dart';
import '../components/ui/game_button_component.dart';

class DashboardScene extends QueryScene {
  late PersistentHudComponent hud;

  @override
  Future<void> onLoad() async {
    hud = PersistentHudComponent();
    add(hud);

    final title = TextComponent(
      text: 'QUERY BUREAU',
      position: Vector2(40, 100),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD54F),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          fontFamily: 'Courier',
        ),
      ),
    );
    add(title);

    final continueBtn = GameButtonComponent(
      title: 'CONTINUE MISSION',
      subtitle: 'The Archive Vaults - W4',
      position: Vector2(40, 180),
      onPressed: () {
        // Go to World 4 Level Map
        // For now, we will just open LevelMapScene manually later
      },
    );
    add(continueBtn);

    final dailyBtn = GameButtonComponent(
      title: 'DAILY CHALLENGE',
      subtitle: 'A new case every day. +2x XP.',
      position: Vector2(40, 270),
      onPressed: () {
        game.pushScene(DailyChallengeScene());
      },
    );
    add(dailyBtn);

    final worldMapBtn = GameButtonComponent(
      title: 'WORLD MAP',
      subtitle: 'Access the global case map',
      position: Vector2(40, 360),
      onPressed: () {
        game.pushScene(WorldSelectScene());
      },
    );
    add(worldMapBtn);
  }

  @override
  List<String> get activeOverlays => []; // No Flutter UI on dashboard
}
