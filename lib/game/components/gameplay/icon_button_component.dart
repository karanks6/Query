import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

class IconButtonComponent extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;

  bool _isPressed = false;

  IconButtonComponent({
    required this.label,
    required this.onTap,
    this.primaryColor = const Color(0xFFD48B3E), // Amber
    super.position,
    super.size,
  });

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8.0),
    );

    // Drop shadow
    if (!_isPressed) {
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 2, size.x, size.y),
        const Radius.circular(8.0),
      );
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
      canvas.drawRRect(shadowRRect, shadowPaint);
    }

    final bgPaint = Paint()
      ..color = _isPressed ? const Color(0xFFEFE6D5) : const Color(0xFFF9F5EA) // Parchment
      ..style = PaintingStyle.fill;
    
    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 2);
    }

    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRRect(rrect, borderPaint);

    if (_isPressed) {
      canvas.restore();
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Label text
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final textComp = children.whereType<TextComponent>().firstOrNull;
    if (textComp != null) {
      textComp.position = Vector2(size.x / 2, (size.y / 2) + (_isPressed ? 2 : 0));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      onTap();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}

