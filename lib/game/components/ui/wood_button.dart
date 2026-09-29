import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

class WoodButton extends PositionComponent with TapCallbacks {
  String text;
  String? secondaryText;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color textColor;
  final bool hasIcon;
  final double? fontSize;

  bool _isPressed = false;

  WoodButton({
    required this.text,
    this.secondaryText,
    required this.onPressed,
    this.primaryColor = const Color(0xFF4A7C59), // Forest Green
    this.textColor = const Color(0xFFF9F5EA), // Parchment cream
    this.hasIcon = false,
    this.fontSize,
    super.position,
    Vector2? size,
  }) : super(size: size ?? Vector2(200, 60));

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16.0),
    );

    // Dynamic drop shadow color based on primary color
    final shadowColor = _darken(primaryColor, 0.3);

    // Drop shadow (if not pressed)
    if (!_isPressed) {
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 6, size.x, size.y),
        const Radius.circular(16.0),
      );
      final shadowPaint1 = Paint()..color = shadowColor;
      canvas.drawRRect(shadowRRect, shadowPaint1);

      final shadowRRect2 = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 10, size.x, size.y),
        const Radius.circular(16.0),
      );
      final shadowPaint2 = Paint()..color = shadowColor.withValues(alpha: 0.3);
      canvas.drawRRect(shadowRRect2, shadowPaint2);
    }

    // Shift canvas down if pressed
    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 6);
    }

    // Gradient Main Fill
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      [
        primaryColor,
        _darken(primaryColor, 0.05),
        _darken(primaryColor, 0.15),
      ],
      [0.0, 0.5, 1.0], // MUST provide colorStops when length is > 2
    );

    final bgPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rrect, bgPaint);

    // Amber-Gold Border
    final borderPaint = Paint()
      ..color = const Color(0xFFE59B28) // amber-gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Inner highlight (top edge glow)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    
    final highlightPath = Path()
      ..moveTo(16, 2)
      ..lineTo(size.x - 16, 2);
    canvas.drawPath(highlightPath, highlightPaint);

    // Children are rendered automatically

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
    _layoutText();
  }

  void _layoutText() {
    removeAll(children);

    final title = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: textColor,
          fontSize: fontSize ?? (secondaryText != null ? 18 : 22),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 1.5),
              blurRadius: 2,
            )
          ]
        ),
      ),
      position: Vector2(size.x / 2, secondaryText != null ? size.y / 2 - 10 : size.y / 2),
      anchor: Anchor.center,
    );
    add(title);

    if (secondaryText != null) {
      final sub = TextComponent(
        text: secondaryText!.toUpperCase(),
        textRenderer: TextPaint(
          style: GoogleFonts.publicSans(
            color: const Color(0xFFBFE0C9), // forest-200
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 + 10),
        anchor: Anchor.center,
      );
      add(sub);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    for (var child in children) {
      if (child is PositionComponent) {
        child.position.y += 6;
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      for (var child in children) {
        if (child is PositionComponent) {
          child.position.y -= 6;
        }
      }
      onPressed();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (_isPressed) {
      _isPressed = false;
      for (var child in children) {
        if (child is PositionComponent) {
          child.position.y -= 6;
        }
      }
    }
  }
}
