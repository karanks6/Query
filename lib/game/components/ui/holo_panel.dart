import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

class HoloPanelComponent extends PositionComponent {
  final Color borderColor;
  final Color bgColor;

  HoloPanelComponent({
    Vector2? position,
    Vector2? size,
    this.borderColor = const Color(0xFF00F0FF),
    this.bgColor = const Color(0xFF0B0C10),
  }) : super(position: position, size: size ?? Vector2(400, 300));

  @override
  void render(Canvas canvas) {
    // Fill
    final bgPaint = Paint()
      ..color = bgColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    
    final rect = size.toRect();
    canvas.drawRect(rect, bgPaint);

    // Subtle grid
    final gridPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const gridSize = 20.0;
    for (double i = 0; i < size.x; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.y), gridPaint);
    }
    for (double i = 0; i < size.y; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.x, i), gridPaint);
    }

    // Border
    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRect(rect, borderPaint);

    // Corner accents
    final accentPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const cornerLength = 15.0;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), accentPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), accentPaint);
    // Top-right
    canvas.drawLine(Offset(size.x, 0), Offset(size.x - cornerLength, 0), accentPaint);
    canvas.drawLine(Offset(size.x, 0), Offset(size.x, cornerLength), accentPaint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.y), Offset(cornerLength, size.y), accentPaint);
    canvas.drawLine(Offset(0, size.y), Offset(0, size.y - cornerLength), accentPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.x, size.y), Offset(size.x - cornerLength, size.y), accentPaint);
    canvas.drawLine(Offset(size.x, size.y), Offset(size.x, size.y - cornerLength), accentPaint);
  }
}
