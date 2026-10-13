import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';

/// A high-end Unity-style game stage node card.
///
/// Features:
/// - 3D tactile beveled chassis with dynamic drop shadow
/// - Embossed circular medallion portal with metallic bezel
/// - Pulsing magical aura ring on the active/current stage
/// - 3-Star achievement rating
/// - Game typography with Quicksand & NunitoSans
/// - Lock states with padlock glyphs
/// - Responsive sizing strictly clamped to screen margins
class StageNodeComponent extends PositionComponent with TapCallbacks {
  final int stageNumber;
  final String title;
  final int stars;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isLeftAligned;
  final VoidCallback onPressed;

  bool _isPressed = false;
  double _animTime = 0.0;

  late TextComponent _stageSubText;
  late TextComponent _titleText;
  late TextComponent _medallionText;
  late TextComponent _starRatingText;

  StageNodeComponent({
    required this.stageNumber,
    required this.title,
    required this.stars,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isLeftAligned,
    required this.onPressed,
    super.position,
    Vector2? size,
  }) : super(size: size ?? Vector2(220, 74));

  Vector2 get riverAnchorPoint {
    final mx = isLeftAligned ? (size.x - 36.0) : 36.0;
    return Vector2(position.x + mx, position.y + (size.y / 2.0));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final medallionCenterX = isLeftAligned ? (size.x - 36.0) : 36.0;
    final double contentLeft = isLeftAligned ? 14.0 : (medallionCenterX + 26.0);

    // 1. Stage Subtitle (e.g. "STAGE 1 • READY")
    final subColor = !isUnlocked
        ? const Color(0xFF78909C)
        : (isCurrent
            ? const Color(0xFFFFE082)
            : (stars > 0 ? const Color(0xFFFFD56B) : const Color(0xFF81D4FA)));

    _stageSubText = TextComponent(
      text: isCurrent ? 'STAGE $stageNumber • READY' : 'STAGE $stageNumber',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: subColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      position: Vector2(contentLeft, 12),
    );
    add(_stageSubText);

    // 2. Stage Title
    final titleColor = !isUnlocked
        ? const Color(0xFF90A4AE)
        : const Color(0xFFFFFFFF);

    _titleText = TextComponent(
      text: title.length > 15 ? '${title.substring(0, 14)}...' : title,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: titleColor,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          shadows: [
            const Shadow(
              color: Color(0x99000000),
              offset: Offset(0, 1.5),
              blurRadius: 2.0,
            )
          ],
        ),
      ),
      position: Vector2(contentLeft, 28),
    );
    add(_titleText);

    // 3. Stars / Status row
    final String starString;
    final Color starColor;
    if (!isUnlocked) {
      starString = '🔒 LOCKED';
      starColor = const Color(0xFF78909C);
    } else if (stars == 3) {
      starString = '★★★ CLEARED';
      starColor = const Color(0xFFFFD166);
    } else if (stars == 2) {
      starString = '★★☆ CLEARED';
      starColor = const Color(0xFFFFD166);
    } else if (stars == 1) {
      starString = '★☆☆ CLEARED';
      starColor = const Color(0xFFFFD166);
    } else {
      starString = isCurrent ? '▶ PLAY NOW' : '☆☆☆ UNLOCKED';
      starColor = isCurrent ? const Color(0xFFA7F3D0) : const Color(0xFF94A3B8);
    }

    _starRatingText = TextComponent(
      text: starString,
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: starColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
      position: Vector2(contentLeft, 48),
    );
    add(_starRatingText);

    // 4. Medallion Glyph
    _medallionText = TextComponent(
      text: !isUnlocked ? '🔒' : '$stageNumber',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: isCurrent || stars > 0 ? const Color(0xFF2A1B03) : const Color(0xFFF1F5F9),
          fontSize: !isUnlocked ? 14 : 19,
          fontWeight: FontWeight.w900,
          shadows: isCurrent || stars > 0
              ? [const Shadow(color: Color(0x66FFFFFF), offset: Offset(0, 1), blurRadius: 1)]
              : null,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(medallionCenterX, size.y / 2.0),
    );
    add(_medallionText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCurrent) {
      _animTime += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(18.0),
    );

    // 1. Drop Shadow
    if (!_isPressed) {
      final shadowColor = isUnlocked ? const Color(0x77000000) : const Color(0x55000000);
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 6, size.x, size.y),
        const Radius.circular(18.0),
      );
      canvas.drawRRect(shadowRRect, Paint()..color = shadowColor);
    }

    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 4);
    }

    // 2. Chassis Background Gradient
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final List<Color> bgColors;
    if (!isUnlocked) {
      bgColors = [
        const Color(0xFF263238),
        const Color(0xFF1E272C),
        const Color(0xFF141A1E),
      ];
    } else if (isCurrent) {
      bgColors = [
        const Color(0xFFB45309),
        const Color(0xFF92400E),
        const Color(0xFF78350F),
      ];
    } else if (stars > 0) {
      bgColors = [
        const Color(0xFF1E6F48),
        const Color(0xFF165337),
        const Color(0xFF0F3A26),
      ];
    } else {
      bgColors = [
        const Color(0xFF2E4057),
        const Color(0xFF223042),
        const Color(0xFF17212E),
      ];
    }

    final gradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      bgColors,
      const [0.0, 0.5, 1.0],
    );

    canvas.drawRRect(rrect, Paint()..shader = gradient);

    // 3. Metallic Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    if (!isUnlocked) {
      borderPaint.color = const Color(0xFF455A64);
    } else if (isCurrent) {
      borderPaint.color = const Color(0xFFFFD166);
    } else if (stars > 0) {
      borderPaint.color = const Color(0xFFE5B048);
    } else {
      borderPaint.color = const Color(0xFF78909C);
    }
    canvas.drawRRect(rrect, borderPaint);

    // 4. Top Rim Highlight
    final topHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isUnlocked ? 0.28 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;
    canvas.drawLine(
      const Offset(18, 2),
      Offset(size.x - 18, 2),
      topHighlightPaint,
    );

    // 5. Render Medallion Portal Plate
    final medallionCenterX = isLeftAligned ? (size.x - 36.0) : 36.0;
    final medallionCenter = Offset(medallionCenterX, size.y / 2.0);
    _renderMedallion(canvas, medallionCenter);

    if (_isPressed) {
      canvas.restore();
    }
  }

  void _renderMedallion(Canvas canvas, Offset center) {
    const radius = 25.0;

    // A. Pulsing Aura on Current Stage
    if (isCurrent) {
      final pulse = (sin(_animTime * 4.0) + 1.0) / 2.0;
      final pulseRadius = radius + 3.0 + (pulse * 6.0);
      final pulseAlpha = (0.6 - (pulse * 0.4)).clamp(0.0, 1.0);

      final pulsePaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: pulseAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // B. Medallion Drop Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, 3), radius, shadowPaint);

    // C. Medallion Base Plate
    final plateColors = isUnlocked
        ? (isCurrent
            ? [const Color(0xFFFBBF24), const Color(0xFFD97706), const Color(0xFF92400E)]
            : (stars > 0
                ? [const Color(0xFFF3C65B), const Color(0xFFC78B2B), const Color(0xFF88570E)]
                : [const Color(0xFF37474F), const Color(0xFF263238), const Color(0xFF182024)]))
        : [const Color(0xFF263238), const Color(0xFF1E272C), const Color(0xFF101820)];

    final plateGradient = ui.Gradient.radial(
      center - const Offset(4, 4),
      radius * 1.2,
      plateColors,
      const [0.0, 0.6, 1.0],
    );

    canvas.drawCircle(center, radius, Paint()..shader = plateGradient);

    // D. Medallion Golden Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = isUnlocked
          ? (isCurrent ? const Color(0xFFFFF3B0) : const Color(0xFFFFD56B))
          : const Color(0xFF546E7A);
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isUnlocked) return;
    _isPressed = true;
    for (final c in children) {
      if (c is PositionComponent) {
        c.position.y += 4;
      }
    }
    try {
      FlameAudio.play('ui_click.wav');
    } catch (_) {}
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      for (final c in children) {
        if (c is PositionComponent) {
          c.position.y -= 4;
        }
      }
      onPressed();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (_isPressed) {
      _isPressed = false;
      for (final c in children) {
        if (c is PositionComponent) {
          c.position.y -= 4;
        }
      }
    }
  }
}
