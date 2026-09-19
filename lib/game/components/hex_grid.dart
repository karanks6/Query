import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HexGridComponent extends PositionComponent {
  final double hexSize = 40.0;
  final Paint _paint = Paint()
    ..color = const Color(0x0AFFFFFF) // Very faint
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;
    
    final double width = sqrt(3) * hexSize;
    final double height = 2 * hexSize;
    
    for (double y = 0; y < size.y + height; y += height * 0.75) {
      double offset = ((y / (height * 0.75)).round() % 2 == 1) ? width / 2 : 0;
      for (double x = 0; x < size.x + width; x += width) {
        _drawHexagon(canvas, Offset(x + offset, y), hexSize);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = 2 * pi / 6 * i + pi / 6;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
