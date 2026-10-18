import 'dart:math';
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
  final bool isPrimary;
  final bool isDaily;

  bool _isPressed = false;
  double _animTime = 0.0;

  WoodButton({
    required this.text,
    this.secondaryText,
    required this.onPressed,
    this.primaryColor = const Color(0xFF4A7C59), // Forest Green
    this.textColor = const Color(0xFFF9F5EA), // Parchment cream
    this.hasIcon = false,
    this.fontSize,
    this.isPrimary = false,
    this.isDaily = false,
    super.position,
    Vector2? size,
  }) : super(size: size ?? Vector2(200, 60));

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16.0),
    );

    // Dynamic drop shadow color based on primary color
    final shadowColor = _darken(primaryColor, 0.35);

    // Drop shadow (if not pressed)
    if (!_isPressed) {
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 5, size.x, size.y),
        const Radius.circular(16.0),
      );
      final shadowPaint1 = Paint()..color = shadowColor;
      canvas.drawRRect(shadowRRect, shadowPaint1);

      final shadowRRect2 = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 8, size.x, size.y),
        const Radius.circular(16.0),
      );
      final shadowPaint2 = Paint()..color = const Color(0x66000000);
      canvas.drawRRect(shadowRRect2, shadowPaint2);
    }

    // Shift canvas down if pressed
    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 5);
    }

    // Gradient Main Fill
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      [
        primaryColor,
        _darken(primaryColor, 0.08),
        _darken(primaryColor, 0.22),
      ],
      [0.0, 0.45, 1.0],
    );

    final bgPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rrect, bgPaint);

    // Amber-Gold Border with subtle breathing glow for primary
    final borderGlow = (isPrimary || isDaily) ? 0.8 + 0.2 * sin(_animTime * 3.0) : 1.0;
    final borderPaint = Paint()
      ..color = const Color(0xFFE59B28).withValues(alpha: borderGlow.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPrimary ? 2.5 : 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Inner highlight (top edge glow)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isPrimary ? 0.35 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    
    final highlightPath = Path()
      ..moveTo(16, 2)
      ..lineTo(size.x - 16, 2);
    canvas.drawPath(highlightPath, highlightPaint);

    // Animated diagonal shimmer sweep across button
    if (isPrimary || isDaily) {
      final cycle = _animTime % 2.8;
      if (cycle < 0.9) {
        final progress = cycle / 0.9;
        final sweepX = -60.0 + progress * (size.x + 120.0);
        final shimmerPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(sweepX - 35, 0),
            Offset(sweepX + 35, size.y),
            [
              Colors.transparent,
              (isPrimary ? const Color(0xFFFFD54F) : Colors.white).withValues(alpha: 0.25),
              Colors.transparent,
            ],
          );
        canvas.save();
        canvas.clipRRect(rrect);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), shimmerPaint);
        canvas.restore();
      }
    }

    // Interactive Pulsing Chevron or Clock Icon
    if (isPrimary) {
      final pulse = (sin(_animTime * 4.0) * 2.5);
      final arrowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      final arrowX = size.x - 32.0 + pulse;
      final arrowY = size.y * 0.5;
      final path = Path()
        ..moveTo(arrowX - 5, arrowY - 7)
        ..lineTo(arrowX + 2, arrowY)
        ..lineTo(arrowX - 5, arrowY + 7);
      canvas.drawPath(path, arrowPaint);
    } else if (isDaily) {
      final iconPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      final clockX = size.x - 28.0;
      final clockY = size.y * 0.5;
      canvas.drawCircle(Offset(clockX, clockY), 6.5, iconPaint);
      canvas.drawLine(Offset(clockX, clockY), Offset(clockX, clockY - 3.5), iconPaint);
      canvas.drawLine(Offset(clockX, clockY), Offset(clockX + 2.5, clockY), iconPaint);
    }

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
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 2),
              blurRadius: 3,
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
            color: isPrimary ? const Color(0xFFD1FAE5) : const Color(0xFFFFF7EA),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
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
