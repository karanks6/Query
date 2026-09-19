import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'query_scene.dart';

class LevelMapScene extends QueryScene {
  @override
  Future<void> onLoad() async {
    // We will draw a winding path background here
    add(WindingPathComponent());
  }
}

class WindingPathComponent extends PositionComponent {
  WindingPathComponent() {
    anchor = Anchor.topLeft;
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
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
