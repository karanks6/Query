import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class RunButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onRun;

  late final RectangleComponent _fill;

  RunButtonComponent({
    required this.onRun,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Glowing neon green fill
    _fill = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF00FF9D)
        ..style = PaintingStyle.fill,
    );
    add(_fill);

    // Bright inner glow border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    ));

    // RUN QUERY text
    add(TextComponent(
      text: 'RUN  QUERY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF0D0F18), // Very dark for max contrast on neon
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    _fill.paint = Paint()
      ..color = const Color(0xFF00CC7A) // Slightly dimmed on press
      ..style = PaintingStyle.fill;
    add(ScaleEffect.to(Vector2.all(0.95), EffectController(duration: 0.08)));
  }

  @override
  void onTapUp(TapUpEvent event) {
    _fill.paint = Paint()
      ..color = const Color(0xFF00FF9D)
      ..style = PaintingStyle.fill;
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.08)));
    onRun();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _fill.paint = Paint()
      ..color = const Color(0xFF00FF9D)
      ..style = PaintingStyle.fill;
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.08)));
  }
}
