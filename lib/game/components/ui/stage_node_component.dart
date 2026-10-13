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
/// - 3-Star achievement rating (cleared vs dim stars)
/// - Crisp fantasy game typography (Cinzel & Outfit)
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
      final shadowColor = isUnlocked
          ? const Color(0x77000000)
          : const Color(0x55000000);
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
        const Color(0xFFB45309), // amber-700
        const Color(0xFF92400E), // amber-800
        const Color(0xFF78350F), // amber-900
      ];
    } else if (stars > 0) {
      bgColors = [
        const Color(0xFF1E6F48), // emerald-700
        const Color(0xFF165337), // emerald-800
        const Color(0xFF0F3A26), // emerald-900
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

    final bgPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

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

    // 4. Top Rim Highlight (3D Chamfer)
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

    // 5. Render Medallion Portal
    final medallionCenterX = isLeftAligned ? (size.x - 36.0) : 36.0;
    final medallionCenter = Offset(medallionCenterX, size.y / 2.0);
    _renderMedallion(canvas, medallionCenter);

    // 6. Render Card Content (Title, Stage subtitle, Stars)
    _renderCardContent(canvas, medallionCenterX);

    if (_isPressed) {
      canvas.restore();
    }
  }

  void _renderMedallion(Canvas canvas, Offset center) {
    const radius = 25.0;

    // A. Pulsing Aura on Current Stage
    if (isCurrent) {
      final pulse = (sin(_animTime * 4.0) + 1.0) / 2.0; // 0.0 to 1.0
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

    final platePaint = Paint()
      ..shader = plateGradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, platePaint);

    // D. Medallion Golden Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = isUnlocked
          ? (isCurrent ? const Color(0xFFFFF3B0) : const Color(0xFFFFD56B))
          : const Color(0xFF546E7A);
    canvas.drawCircle(center, radius, rimPaint);

    // E. Center Glyph
    if (!isUnlocked) {
      // Draw Lock Icon
      _drawLockIcon(canvas, center);
    } else {
      // Draw Stage Number
      final textSpan = TextSpan(
        text: '$stageNumber',
        style: GoogleFonts.cinzel(
          color: isCurrent || stars > 0 ? const Color(0xFF2A1B03) : const Color(0xFFE2E8F0),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          shadows: isCurrent || stars > 0
              ? [
                  const Shadow(
                    color: Color(0x66FFFFFF),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  )
                ]
              : null,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawLockIcon(Canvas canvas, Offset center) {
    final lockPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.fill;

    // Lock body
    final bodyRect = Rect.fromCenter(
      center: center + const Offset(0, 3),
      width: 14,
      height: 11,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)),
      lockPaint,
    );

    // Lock shackle
    final shacklePaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final shackleRect = Rect.fromCenter(
      center: center + const Offset(0, -3),
      width: 8,
      height: 8,
    );
    canvas.drawArc(shackleRect, pi, pi, false, shacklePaint);
  }

  void _renderCardContent(Canvas canvas, double medallionCenterX) {
    // Determine content bounding box
    final double contentLeft;
    final double contentWidth;
    if (isLeftAligned) {
      contentLeft = 16.0;
      contentWidth = medallionCenterX - 30.0;
    } else {
      contentLeft = medallionCenterX + 28.0;
      contentWidth = size.x - contentLeft - 16.0;
    }

    if (contentWidth <= 20) return;

    // 1. Stage Subtitle (e.g. "STAGE 1" or "STAGE 1 • ACTIVE")
    final subtitleColor = !isUnlocked
        ? const Color(0xFF78909C)
        : (isCurrent
            ? const Color(0xFFFFE082)
            : (stars > 0 ? const Color(0xFFFFD56B) : const Color(0xFF81D4FA)));

    final subSpan = TextSpan(
      text: isCurrent ? 'STAGE $stageNumber • READY' : 'STAGE $stageNumber',
      style: GoogleFonts.cinzel(
        color: subtitleColor,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
    final subPainter = TextPainter(
      text: subSpan,
      textAlign: isLeftAligned ? TextAlign.left : TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    subPainter.layout(maxWidth: contentWidth);
    subPainter.paint(canvas, Offset(contentLeft, 13));

    // 2. Stage Title
    final titleColor = !isUnlocked
        ? const Color(0xFF90A4AE)
        : const Color(0xFFFFFFFF);

    final titleSpan = TextSpan(
      text: title,
      style: GoogleFonts.outfit(
        color: titleColor,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 1.5),
            blurRadius: 2.0,
          )
        ],
      ),
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      maxLines: 1,
      ellipsis: '...',
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: contentWidth);
    titlePainter.paint(canvas, Offset(contentLeft, 30));

    // 3. Stars / Status indicator row
    _renderStarRow(canvas, contentLeft, 50);
  }

  void _renderStarRow(Canvas canvas, double left, double top) {
    if (!isUnlocked) {
      final lockTextSpan = TextSpan(
        text: 'LOCKED',
        style: GoogleFonts.outfit(
          color: const Color(0xFF546E7A),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      );
      final lockPainter = TextPainter(
        text: lockTextSpan,
        textDirection: TextDirection.ltr,
      );
      lockPainter.layout();
      lockPainter.paint(canvas, Offset(left, top));
      return;
    }

    // Draw 3 Stars
    const starChar = '★';
    for (int s = 0; s < 3; s++) {
      final isEarned = s < stars;
      final starColor = isEarned
          ? const Color(0xFFFFD166)
          : const Color(0x55FFFFFF);

      final starSpan = TextSpan(
        text: starChar,
        style: TextStyle(
          color: starColor,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          shadows: isEarned
              ? [
                  const Shadow(
                    color: Color(0x99FFC107),
                    blurRadius: 3,
                  )
                ]
              : null,
        ),
      );
      final starPainter = TextPainter(
        text: starSpan,
        textDirection: TextDirection.ltr,
      );
      starPainter.layout();
      starPainter.paint(canvas, Offset(left + (s * 14.0), top - 2));
    }

    if (stars > 0) {
      final ptsSpan = TextSpan(
        text: 'CLEARED',
        style: GoogleFonts.outfit(
          color: const Color(0xFFA7F3D0),
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      );
      final ptsPainter = TextPainter(
        text: ptsSpan,
        textDirection: TextDirection.ltr,
      );
      ptsPainter.layout();
      ptsPainter.paint(canvas, Offset(left + 48.0, top));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isUnlocked) return;
    _isPressed = true;
    try {
      FlameAudio.play('ui_click.wav');
    } catch (_) {}
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      onPressed();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}
