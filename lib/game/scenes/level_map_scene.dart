import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'query_scene.dart';

import '../components/ui/game_button_component.dart';
import 'gameplay_scene.dart';
import '../../data/content/models/level_model.dart';
import '../../core/sandbox_engine/level_schema.dart';
class LevelMapScene extends QueryScene {
  final String worldId;

  LevelMapScene({required this.worldId});

  @override
  Future<void> onLoad() async {
    add(WindingPathComponent());

    final backBtn = GameButtonComponent(
      title: 'BACK',
      size: Vector2(100, 40),
      position: Vector2(40, 60),
      onPressed: () {
        game.popScene();
      },
    );
    add(backBtn);

    final dummyLevel = LevelModel(
      id: 'level_1',
      worldId: worldId,
      levelNumber: 1,
      title: 'First Query',
      narrative: 'Select all users.',
      type: LevelType.puzzle,
      schema: LevelSchema(tables: []),
      xpReward: 50,
      allowedWorldNumber: 1,
      hints: const [],
      orderSensitive: false,
      performanceActive: false,
      efficiencyThreshold: 0.8,
      schemaSql: '',
      seedSql: '',
      expectedResult: const [],
    );

    final node = GameButtonComponent(
      title: 'LEVEL 1',
      size: Vector2(140, 50),
      position: Vector2(150, 150),
      onPressed: () {
        game.pushScene(GameplayScene(level: dummyLevel));
      },
    );
    add(node);
  }
}

class WindingPathComponent extends PositionComponent {
  WindingPathComponent() {
    anchor = Anchor.topLeft;
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x3300FFCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double startY = 150.0;
    
    // Draw a winding path mimicking a Mario world map
    path.moveTo(size.x / 2, startY);
    for (int i = 0; i < 5; i++) {
      path.quadraticBezierTo(
        size.x / 2 + (i % 2 == 0 ? 150 : -150), 
        startY + (i * 100) + 50,
        size.x / 2, 
        startY + ((i + 1) * 100)
      );
    }
    
    canvas.drawPath(path, paint);
  }
}
