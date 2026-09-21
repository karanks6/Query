import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class RunButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onRun;
  
  RunButtonComponent({
    required this.onRun,
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
        ..color = const Color(0xFF00FF9D) // Neon green accent
        ..style = PaintingStyle.fill,
    ));
    
    // Text
    add(TextComponent(
      text: 'RUN QUERY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF0F111A), // Dark background color
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Add visual feedback
    scale = Vector2.all(0.95);
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    onRun();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}
