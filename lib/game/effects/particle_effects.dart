import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticleEffects {
  static final _random = Random();

  /// Creates a neon particle explosion.
  static ParticleSystemComponent successExplosion(Vector2 position) {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 50,
        lifespan: 1.5,
        generator: (i) {
          final angle = _random.nextDouble() * 2 * pi;
          final speed = _random.nextDouble() * 200 + 100; // 100 to 300
          final dx = cos(angle) * speed;
          final dy = sin(angle) * speed;

          return AcceleratedParticle(
            acceleration: Vector2(0, 100), // Gravity
            speed: Vector2(dx, dy),
            position: Vector2.zero(),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = const Color(0xFF39FF6A).withOpacity(1 - particle.progress)
                  ..style = PaintingStyle.fill;
                canvas.drawCircle(Offset.zero, 3 * (1 - particle.progress), paint);
              },
            ),
          );
        },
      ),
    );
  }

  /// Creates red spark particles for error.
  static ParticleSystemComponent errorSparks(Vector2 position) {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 20,
        lifespan: 0.8,
        generator: (i) {
          final angle = _random.nextDouble() * pi; // Upwards
          final speed = _random.nextDouble() * 150 + 50;
          final dx = cos(angle + pi) * speed; // Random horizontal
          final dy = -sin(angle) * speed; // Always up

          return AcceleratedParticle(
            acceleration: Vector2(0, 300), // Strong gravity
            speed: Vector2(dx, dy),
            position: Vector2.zero(),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = const Color(0xFFFF4A4A).withOpacity(1 - particle.progress)
                  ..style = PaintingStyle.fill;
                canvas.drawRect(
                  Rect.fromCenter(center: Offset.zero, width: 4 * (1 - particle.progress), height: 4), 
                  paint
                );
              },
            ),
          );
        },
      ),
    );
  }
}
