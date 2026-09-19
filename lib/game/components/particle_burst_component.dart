import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticleBurstComponent extends Component {
  final Vector2 position;
  final Color color;
  final int count;

  ParticleBurstComponent({
    required this.position,
    this.color = const Color(0xFF00FF9D), // Success green
    this.count = 40,
  });

  @override
  Future<void> onLoad() async {
    final random = Random();
    
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: count,
          lifespan: 1.0,
          generator: (i) {
            final angle = random.nextDouble() * 2 * pi;
            final speed = random.nextDouble() * 200 + 50;
            final vx = cos(angle) * speed;
            final vy = sin(angle) * speed;

            return AcceleratedParticle(
              position: position.clone(),
              speed: Vector2(vx, vy),
              acceleration: Vector2(0, 100), // Gravity effect
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final paint = Paint()
                    ..color = color.withValues(alpha: 1 - particle.progress)
                    ..style = PaintingStyle.fill;
                  canvas.drawCircle(Offset.zero, 3.0 * (1 - particle.progress), paint);
                },
              ),
            );
          },
        ),
      ),
    );
    
    // Auto-remove after burst is done
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (isMounted) removeFromParent();
    });
  }
}
