import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import 'level_map_scene.dart';
import '../components/ui/cyber_button.dart';
import '../components/hex_grid_background.dart';

class WorldSelectScene extends QueryScene {
  @override
  Future<void> onLoad() async {
    add(HexGridBackground(hexColor: const Color(0xFFFF0055)));

    final title = TextComponent(
      text: 'GLOBAL ARCHIVE',
      position: Vector2(60, 60),
      textRenderer: TextPaint(
        style: GoogleFonts.orbitron(
          color: const Color(0xFFFF0055),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
    add(title);

    final backBtn = CyberButton(
      text: '< BACK',
      size: Vector2(150, 40),
      position: Vector2(60, 120),
      primaryColor: const Color(0xFF6B7A8F),
      onPressed: () {
        game.popScene();
      },
    );
    add(backBtn);

    final world1 = CyberButton(
      text: 'W1: The Archive Vaults',
      secondaryText: 'Fundamentals of Selection',
      position: Vector2(60, 180),
      primaryColor: const Color(0xFF00F0FF),
      onPressed: () {
        game.pushScene(LevelMapScene(worldId: 'world_01'));
      },
    );
    add(world1);

    final world2 = CyberButton(
      text: 'W2: Filter District',
      secondaryText: 'Advanced WHERE clauses',
      position: Vector2(60, 260),
      primaryColor: const Color(0xFF00FF66),
      onPressed: () {
        game.pushScene(LevelMapScene(worldId: 'world_02'));
      },
    );
    add(world2);

    final world3 = CyberButton(
      text: 'W3: Aggregation Exchange',
      secondaryText: 'GROUP BY and HAVING',
      position: Vector2(60, 340),
      primaryColor: const Color(0xFFFFB800),
      onPressed: () {
        game.pushScene(LevelMapScene(worldId: 'world_03'));
      },
    );
    add(world3);
  }

  @override
  List<String> get activeOverlays => [];
}
