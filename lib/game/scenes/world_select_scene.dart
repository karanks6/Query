import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'query_scene.dart';
import 'level_map_scene.dart';
import '../components/ui/game_button_component.dart';

class WorldSelectScene extends QueryScene {
  @override
  Future<void> onLoad() async {
    final title = TextComponent(
      text: 'WORLD SELECT',
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

    final world1 = GameButtonComponent(
      title: 'World 1: The Archive Vaults',
      subtitle: 'Fundamentals of Selection',
      position: Vector2(40, 160),
      onPressed: () {
        game.pushScene(LevelMapScene(worldId: 'world_01'));
      },
    );
    add(world1);

    final world2 = GameButtonComponent(
      title: 'World 2: Filter District',
      subtitle: 'Advanced WHERE clauses',
      position: Vector2(40, 250),
      onPressed: () {
        game.pushScene(LevelMapScene(worldId: 'world_02'));
      },
    );
    add(world2);

    final world3 = GameButtonComponent(
      title: 'World 3: Aggregation Exchange',
      subtitle: 'GROUP BY and HAVING',
      position: Vector2(40, 340),
      onPressed: () {
        game.pushScene(LevelMapScene(worldId: 'world_03'));
      },
    );
    add(world3);
  }

  @override
  List<String> get activeOverlays => [];
}
