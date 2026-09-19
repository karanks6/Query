import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DataTraceComponent extends PositionComponent {
  final Random _random = Random();
  late Vector2 velocity;
  final Paint _paint = Paint()..color = const Color(0xFFFFCC00);

  @override
  Future<void> onLoad() async {
    size = Vector2(8, 8);
    // Random velocity along cardinal or diagonal directions
    final angle = (_random.nextInt(8) * pi / 4);
    final speed = _random.nextDouble() * 50 + 50;
    velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
  }

  @override
  void update(double dt) {
    position += velocity * dt;

    final gameSize = findGame()?.size;
    if (gameSize != null) {
      if (position.x < 0 || position.x > gameSize.x || position.y < 0 || position.y > gameSize.y) {
        removeFromParent(); // Despawn when out of bounds
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }
}
