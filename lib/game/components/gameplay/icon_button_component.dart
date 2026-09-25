import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class IconButtonComponent extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;

  late final RectangleComponent _bg;

  IconButtonComponent({
    required this.label,
    required this.onTap,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Dark background fill
    _bg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF1E2130)
        ..style = PaintingStyle.fill,
    );
    add(_bg);

    // Accent border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFFFFCC00).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    ));

    // Gold label text
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFCC00),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    _bg.paint = Paint()
      ..color = const Color(0xFFFFCC00).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    scale = Vector2.all(0.92);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _bg.paint = Paint()
      ..color = const Color(0xFF1E2130)
      ..style = PaintingStyle.fill;
    scale = Vector2.all(1.0);
    onTap();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _bg.paint = Paint()
      ..color = const Color(0xFF1E2130)
      ..style = PaintingStyle.fill;
    scale = Vector2.all(1.0);
  }
}
