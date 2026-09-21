import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class IconButtonComponent extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;
  
  IconButtonComponent({
    required this.label,
    required this.onTap,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF15171E)
        ..style = PaintingStyle.fill,
    ));
    
    // Border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    ));
    
    // Text
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(0.9);
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    onTap();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}
