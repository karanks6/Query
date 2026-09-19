import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'query_scene.dart';

class WorldSelectScene extends QueryScene {
  @override
  Future<void> onLoad() async {
    // Basic isometric layout for world nodes
    for (int i = 0; i < 10; i++) {
      // Staggered positions for isometric look
      final double dx = 150.0 + (i % 2) * 50.0;
      final double dy = 100.0 + i * 40.0;
      add(IsometricTile(Vector2(dx, dy), i + 1));
    }
  }

  @override
  Future<void> onEnter() async {
    // Entry animation logic here
  }
}

class IsometricTile extends PositionComponent {
  final int worldIndex;

  IsometricTile(Vector2 pos, this.worldIndex) {
    position = pos;
    size = Vector2(120, 60);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF00FFCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    final fillPaint = Paint()
      ..color = const Color(0x3300FFCC)
      ..style = PaintingStyle.fill;
      
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(0, size.y / 2)
      ..close();
      
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
    );
    textPaint.render(canvas, 'W$worldIndex', Vector2(size.x / 2 - 12, size.y / 2 - 8));
  }
}
