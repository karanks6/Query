import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParallaxWorldComponent extends PositionComponent {
  final List<_Star> _stars = [];
  final Random _random = Random();
  final Paint _paint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 200; i++) {
      _stars.add(_Star(
        position: Vector2(_random.nextDouble(), _random.nextDouble()),
        depth: _random.nextDouble() * 0.5 + 0.1, // 0.1 to 0.6
      ));
    }
  }

  @override
  void update(double dt) {
    for (final star in _stars) {
      // Move stars leftwards based on their depth to create parallax
      star.position.x -= (star.depth * 0.05) * dt;
      if (star.position.x < 0) {
        star.position.x = 1.0; // wrap around
        star.position.y = _random.nextDouble();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;
    for (final star in _stars) {
      final x = star.position.x * size.x;
      final y = star.position.y * size.y;
      _paint.color = Colors.white.withValues(alpha: star.depth);
      canvas.drawCircle(Offset(x, y), star.depth * 2, _paint);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}

class _Star {
  Vector2 position; // 0.0 to 1.0 normalized
  double depth;
  _Star({required this.position, required this.depth});
}
