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

  /// Creates gold rain particles dropping from top of screen
  static ParticleSystemComponent goldRain(Vector2 screenSize) {
    return ParticleSystemComponent(
      position: Vector2.zero(),
      particle: Particle.generate(
        count: 100,
        lifespan: 3.0,
        generator: (i) {
          final startX = _random.nextDouble() * screenSize.x;
          final startY = -_random.nextDouble() * 200; // Start slightly above screen
          final speedY = _random.nextDouble() * 150 + 50;
          
          return AcceleratedParticle(
            position: Vector2(startX, startY),
            speed: Vector2(0, speedY),
            acceleration: Vector2(0, 100), // Gravity
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = const Color(0xFFFFCC00).withOpacity(min(1.0, (1 - particle.progress) * 1.5))
                  ..style = PaintingStyle.fill;
                
                // Draw little rectangular confetti
                canvas.save();
                canvas.rotate(particle.progress * 4 * pi); // Spinning
                canvas.drawRect(
                  Rect.fromCenter(center: Offset.zero, width: 6, height: 10), 
                  paint
                );
                canvas.restore();
              },
            ),
          );
        },
      ),
    );
  }
}
