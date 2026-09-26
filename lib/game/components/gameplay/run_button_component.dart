import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

class RunButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onRun;

  bool _isPressed = false;

  RunButtonComponent({
    required this.onRun,
    super.position,
    super.size,
  });

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final path = Path();
    final chamfer = 12.0;

    path.moveTo(chamfer, 0);
    path.lineTo(size.x, 0);
    path.lineTo(size.x, size.y - chamfer);
    path.lineTo(size.x - chamfer, size.y);
    path.lineTo(0, size.y);
    path.lineTo(0, chamfer);
    path.close();

    final primaryColor = const Color(0xFF00FF66);

    // Fill
    final bgPaint = Paint()
      ..color = _isPressed 
          ? primaryColor.withValues(alpha: 0.4) 
          : primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, bgPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: _isPressed ? 1.0 : 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isPressed ? 3.0 : 1.5;
      
    // Glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: _isPressed ? 1.0 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, strokePaint);

    // Draw text manually or use a child TextComponent? We can just use a child.
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(TextComponent(
      text: 'EXECUTE',
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF00FF66),
          fontSize: 18,
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
    _isPressed = true;
    add(ScaleEffect.to(Vector2.all(0.95), EffectController(duration: 0.08)));
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.08)));
    onRun();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.08)));
  }
}
