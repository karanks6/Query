import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

class CyberButton extends PositionComponent with TapCallbacks {
  final String text;
  final String secondaryText;
  final VoidCallback onPressed;
  final Color primaryColor;
  
  late final TextComponent _textComp;
  late final TextComponent _secondaryTextComp;
  
  bool _isPressed = false;

  CyberButton({
    required this.text,
    this.secondaryText = '',
    required this.onPressed,
    this.primaryColor = const Color(0xFF00F0FF),
    super.position,
    Vector2? size,
  }) : super(size: size ?? Vector2(300, 60));

  @override
  Future<void> onLoad() async {
    _textComp = TextComponent(
      text: text,
      position: Vector2(30, secondaryText.isEmpty ? size.y / 2 : size.y / 2 - 8),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
    );

    _secondaryTextComp = TextComponent(
      text: secondaryText,
      position: Vector2(30, size.y / 2 + 10),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: GoogleFonts.firaCode(
          color: primaryColor.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
    );

    add(_textComp);
    if (secondaryText.isNotEmpty) {
      add(_secondaryTextComp);
    }
  }

  @override
  void render(Canvas canvas) {
    final path = Path();
    final chamfer = 15.0;

    // Draw a chamfered rectangle (angled corners)
    path.moveTo(chamfer, 0);
    path.lineTo(size.x, 0);
    path.lineTo(size.x, size.y - chamfer);
    path.lineTo(size.x - chamfer, size.y);
    path.lineTo(0, size.y);
    path.lineTo(0, chamfer);
    path.close();

    // Background fill
    final bgPaint = Paint()
      ..color = _isPressed 
          ? primaryColor.withValues(alpha: 0.2) 
          : const Color(0xFF121820).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, bgPaint);

    // Glowing stroke
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: _isPressed ? 1.0 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isPressed ? 3.0 : 1.5;
      
    // Glow effect
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: _isPressed ? 0.8 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, strokePaint);

    // Decorative corner dots
    final dotPaint = Paint()..color = primaryColor;
    canvas.drawRect(Rect.fromLTWH(6, 6, 3, 3), dotPaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 9, size.y - 9, 3, 3), dotPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    scale = Vector2.all(0.95);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    scale = Vector2.all(1.0);
    onPressed();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    scale = Vector2.all(1.0);
  }
}
