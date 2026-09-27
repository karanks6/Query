import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

class ParchmentPanel extends PositionComponent {
  final Color baseColor;

  ParchmentPanel({
    super.position,
    super.size,
    this.baseColor = const Color(0xFFF9F5EA),
  });

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16.0), // Rounded 2xl
    );

    // Drop shadow
    final shadowRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 8, size.x, size.y),
      const Radius.circular(16.0),
    );
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawRRect(shadowRRect, shadowPaint);

    // Main Fill
    final bgPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rrect, bgPaint);

    // Thick Wood Border
    final borderPaint = Paint()
      ..color = const Color(0xFF5C3D2E) // wood-700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    canvas.drawRRect(rrect, borderPaint);

    // Stitched edge (dashed inner border)
    final stitchedRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 6, size.x - 12, size.y - 12),
      const Radius.circular(12.0),
    );
    
    final Path path = Path()..addRRect(stitchedRRect);
    
    // Draw dashed path manually
    final dashPaint = Paint()
      ..color = const Color(0xFFBA8869) // wood-400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _drawDashedPath(canvas, path, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 6.0;
    final dashSpace = 6.0;
    
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          final extractPath = metric.extractPath(distance, distance + length);
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }
}
