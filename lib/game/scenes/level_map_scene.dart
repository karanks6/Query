import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import '../components/ui/cyber_button.dart';
import 'gameplay_scene.dart';
import '../../data/content/models/level_model.dart';
import '../../core/sandbox_engine/level_schema.dart';

class LevelMapScene extends QueryScene {
  final String worldId;

  LevelMapScene({required this.worldId});

  @override
  Future<void> onLoad() async {
    add(CircuitPathComponent());

    final title = TextComponent(
      text: 'CASE LOG: ${worldId.toUpperCase()}',
      position: Vector2(60, 60),
      textRenderer: TextPaint(
        style: GoogleFonts.orbitron(
          color: const Color(0xFF00F0FF),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
    add(title);

    final backBtn = CyberButton(
      text: '< BACK',
      size: Vector2(150, 40),
      position: Vector2(60, 100),
      primaryColor: const Color(0xFF6B7A8F),
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

    // Node 1
    final node1 = CyberButton(
      text: 'CASE 01',
      size: Vector2(160, 50),
      position: Vector2(300, 200),
      primaryColor: const Color(0xFF00FF66),
      onPressed: () {
        game.pushScene(GameplayScene(level: dummyLevel));
      },
    );
    add(node1);
  }
}

class CircuitPathComponent extends PositionComponent {
  CircuitPathComponent() {
    anchor = Anchor.topLeft;
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    // Draw a circuit board trace path
    final paint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.miter;

    final glowPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    path.moveTo(size.x / 2, 0);
    path.lineTo(size.x / 2, 100);
    path.lineTo(380, 180);
    path.lineTo(380, 200);
    // Expand this to more nodes later...
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
}
