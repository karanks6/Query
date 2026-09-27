import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

class DirtTrailComponent extends PositionComponent {
  DirtTrailComponent() {
    anchor = Anchor.topLeft;
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    if (_points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFB5A68F) // Dirt brown dashed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(_points.first.x, _points.first.y);
    for (int i = 1; i < _points.length; i++) {
      // Create a smooth curve between points
      final p1 = _points[i - 1];
      final p2 = _points[i];
      
      final control1 = Vector2(p1.x, (p1.y + p2.y) / 2);
      final control2 = Vector2(p2.x, (p1.y + p2.y) / 2);
      
      path.cubicTo(
        control1.x, control1.y,
        control2.x, control2.y,
        p2.x, p2.y,
      );
    }
    
    // Create a dashed effect manually
    final metric = path.computeMetrics().firstOrNull;
    if (metric != null) {
      final dashPath = Path();
      const dashLength = 15.0;
      const dashSpace = 15.0;
      double distance = 0.0;
      
      while (distance < metric.length) {
        final length = min(dashLength, metric.length - distance);
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  List<Vector2> _points = [];
  void setPoints(List<Vector2> points) {
    _points = points;
  }
}
