import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BlinkCursorComponent extends PositionComponent {
  bool _isVisible = true;
  double _timer = 0;
  final Paint _paint = Paint()..color = const Color(0xFFFFCC00); // Accent gold

  BlinkCursorComponent() : super(size: Vector2(10, 20));

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer > 0.5) { // Blink every 500ms
      _isVisible = !_isVisible;
      _timer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isVisible) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
    }
  }
}
