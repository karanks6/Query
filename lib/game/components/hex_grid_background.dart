import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

class HexGridBackground extends PositionComponent {
  final Color hexColor;
  double _time = 0;

  HexGridBackground({
    this.hexColor = const Color(0xFF00F0FF),
  });

  @override
  void update(double dt) {
    _time += dt * 0.5; // Scroll speed
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final paint = Paint()
      ..color = hexColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final hexRadius = 40.0;
    final hexWidth = sqrt(3) * hexRadius;
    final hexHeight = 2 * hexRadius;
    final vertDist = hexHeight * 0.75;
    final horizDist = hexWidth;

    double offsetY = (_time * 20) % vertDist;

    for (double y = -vertDist - offsetY; y < size.y + vertDist; y += vertDist) {
      int row = (y / vertDist).round();
      double offset = (row % 2 == 0) ? 0 : hexWidth / 2;

      for (double x = -hexWidth; x < size.x + hexWidth; x += horizDist) {
        _drawHexagon(canvas, Offset(x + offset, y), hexRadius, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = pi / 3 * i - pi / 6;
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
