import 'package:flame/components.dart';
import 'package:flame/events.dart';
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

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16.0),
    );

    // Drop shadow
    if (!_isPressed) {
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 4, size.x, size.y),
        const Radius.circular(16.0),
      );
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.25);
      canvas.drawRRect(shadowRRect, shadowPaint);
    }

    final primaryColor = const Color(0xFF4A7C59); // Forest green

    // Fill
    final bgPaint = Paint()
      ..color = _isPressed ? _darken(primaryColor, 0.1) : primaryColor
      ..style = PaintingStyle.fill;
    
    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 4);
    }

    canvas.drawRRect(rrect, bgPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final highlightPath = Path()
      ..moveTo(16, 2)
      ..lineTo(size.x - 16, 2);
    canvas.drawPath(highlightPath, highlightPaint);

    if (_isPressed) {
      canvas.restore();
    }
  }
  
  Color _darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final textComp = TextComponent(
      text: 'RUN',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(textComp);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Shift text down if pressed
    final textComp = children.whereType<TextComponent>().firstOrNull;
    if (textComp != null) {
      textComp.position = Vector2(size.x / 2, (size.y / 2) + (_isPressed ? 4 : 0));
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
      onRun();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}

