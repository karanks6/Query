import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';

/// A high-end Unity-style fixed game header for the Level Map.
///
/// Features:
/// - Pinned top HUD with stone-arch gradient backdrop
/// - 3D tactile circular/shield Back Button with gold bevel
/// - Ornate World Title plaque with Cinzel fantasy typography
/// - Jewel-encrusted Star Trophy pill badge showing total stars earned
class LevelMapHeaderComponent extends PositionComponent {
  final String worldTitle;
  final String worldSubtitle;
  final int earnedStars;
  final int totalPossibleStars;
  final VoidCallback onBackPressed;

  LevelMapHeaderComponent({
    required this.worldTitle,
    required this.worldSubtitle,
    required this.earnedStars,
    required this.totalPossibleStars,
    required this.onBackPressed,
    required Vector2 size,
  }) : super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add interactive Back Button
    final backBtn = _HeaderBackButton(
      position: Vector2(16, 24),
      size: Vector2(46, 46),
      onPressed: onBackPressed,
    );
    add(backBtn);
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    // 1. Dark Top Bar Backdrop with Gradient
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgGradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      [
        const Color(0xF2121B20), // 95% opacity dark slate
        const Color(0xE6162329),
        const Color(0xCC0E171C),
      ],
      const [0.0, 0.7, 1.0],
    );

    final bgPaint = Paint()..shader = bgGradient;
    canvas.drawRect(rect, bgPaint);

    // 2. Bottom Shadow Gradient (Soft fade into map)
    final shadowRect = Rect.fromLTWH(0, size.y, size.x, 24);
    final shadowGradient = ui.Gradient.linear(
      shadowRect.topCenter,
      shadowRect.bottomCenter,
      [
        const Color(0x99000000),
        const Color(0x00000000),
      ],
    );
    canvas.drawRect(shadowRect, Paint()..shader = shadowGradient);

    // 3. Ornate Golden Bottom Bezel Line
    final bezelPaint = Paint()
      ..color = const Color(0xFFD4AF37) // Gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, size.y),
      Offset(size.x, size.y),
      bezelPaint,
    );

    // 4. Center World Title & Subtitle
    final centerX = size.x / 2.0;
    
    // World Title
    final titleSpan = TextSpan(
      text: worldTitle.toUpperCase(),
      style: GoogleFonts.cinzel(
        color: const Color(0xFFF9F5EA),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        shadows: [
          const Shadow(
            color: Color(0xCC000000),
            offset: Offset(0, 2),
            blurRadius: 3,
          )
        ],
      ),
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.x - 170);
    titlePainter.paint(
      canvas,
      Offset(centerX - (titlePainter.width / 2), 24),
    );

    // World Subtitle
    final subSpan = TextSpan(
      text: worldSubtitle.toUpperCase(),
      style: GoogleFonts.outfit(
        color: const Color(0xFFFFD166),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
    final subPainter = TextPainter(
      text: subSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    subPainter.layout(maxWidth: size.x - 170);
    subPainter.paint(
      canvas,
      Offset(centerX - (subPainter.width / 2), 50),
    );

    // 5. Star Trophy Badge on Right
    final badgeWidth = 68.0;
    final badgeHeight = 34.0;
    final badgeLeft = size.x - badgeWidth - 16.0;
    final badgeTop = 30.0;
    _renderStarBadge(canvas, Offset(badgeLeft, badgeTop), badgeWidth, badgeHeight);
  }

  void _renderStarBadge(Canvas canvas, Offset offset, double width, double height) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, height),
      const Radius.circular(17),
    );

    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = const Color(0x55000000),
    );

    // Background
    final bgPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(rrect, bgPaint);

    // Gold Trim
    final trimPaint = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rrect, trimPaint);

    // Star icon
    final starSpan = const TextSpan(
      text: '★',
      style: TextStyle(
        color: Color(0xFFFFD166),
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
    final starPainter = TextPainter(
      text: starSpan,
      textDirection: TextDirection.ltr,
    );
    starPainter.layout();
    starPainter.paint(canvas, offset + const Offset(9, 7));

    // Numbers (e.g. "12/18")
    final countSpan = TextSpan(
      text: '$earnedStars/$totalPossibleStars',
      style: GoogleFonts.outfit(
        color: const Color(0xFFF8FAFC),
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
    final countPainter = TextPainter(
      text: countSpan,
      textDirection: TextDirection.ltr,
    );
    countPainter.layout();
    countPainter.paint(canvas, offset + const Offset(27, 10));
  }
}

class _HeaderBackButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  bool _isPressed = false;

  _HeaderBackButton({
    required this.onPressed,
    required super.position,
    required super.size,
  });

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(14),
    );

    // Shadow
    if (!_isPressed) {
      canvas.drawRRect(
        rrect.shift(const Offset(0, 4)),
        Paint()..color = const Color(0x66000000),
      );
    }

    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 3);
    }

    // Gradient Fill
    final bgGradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.y),
      [
        const Color(0xFF2C3E50),
        const Color(0xFF1A252F),
      ],
    );
    canvas.drawRRect(rrect, Paint()..shader = bgGradient);

    // Bezel Rim
    final borderPaint = Paint()
      ..color = const Color(0xFFE5B048)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Top Rim Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;
    canvas.drawLine(
      const Offset(8, 2),
      Offset(size.x - 8, 2),
      highlightPaint,
    );

    // Back Chevron glyph '<'
    final chevronSpan = TextSpan(
      text: '<',
      style: GoogleFonts.cinzel(
        color: const Color(0xFFFFF3B0),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        shadows: [
          const Shadow(
            color: Color(0x99000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          )
        ],
      ),
    );
    final chevronPainter = TextPainter(
      text: chevronSpan,
      textDirection: TextDirection.ltr,
    );
    chevronPainter.layout();
    chevronPainter.paint(
      canvas,
      Offset(
        (size.x - chevronPainter.width) / 2 - 1,
        (size.y - chevronPainter.height) / 2,
      ),
    );

    if (_isPressed) {
      canvas.restore();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
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
