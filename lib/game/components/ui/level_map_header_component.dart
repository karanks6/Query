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
/// - Ornate World Title plaque with Quicksand/NunitoSans fantasy typography
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

    // 1. Back Button
    final backBtn = _HeaderBackButton(
      position: Vector2(16, 24),
      size: Vector2(46, 46),
      onPressed: onBackPressed,
    );
    add(backBtn);

    // 2. World Title Text
    final centerX = size.x / 2.0;
    final titleComp = TextComponent(
      text: worldTitle.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFF9F5EA),
          fontSize: 17,
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
      ),
      anchor: Anchor.topCenter,
      position: Vector2(centerX, 23),
    );
    add(titleComp);

    // 3. World Subtitle Text
    final subtitleComp = TextComponent(
      text: worldSubtitle.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFFFD166),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(centerX, 48),
    );
    add(subtitleComp);

    // 4. Star Badge Text
    final badgeWidth = 66.0;
    final badgeHeight = 32.0;
    final badgeLeft = size.x - badgeWidth - 16.0;
    final badgeTop = 31.0;

    final badgePill = _StarBadgeComponent(
      position: Vector2(badgeLeft, badgeTop),
      size: Vector2(badgeWidth, badgeHeight),
      earnedStars: earnedStars,
      totalStars: totalPossibleStars,
    );
    add(badgePill);
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
        const Color(0xF2121B20),
        const Color(0xE6162329),
        const Color(0xCC0E171C),
      ],
      const [0.0, 0.7, 1.0],
    );

    canvas.drawRect(rect, Paint()..shader = bgGradient);

    // 2. Bottom Shadow Gradient
    final shadowRect = Rect.fromLTWH(0, size.y, size.x, 20);
    final shadowGradient = ui.Gradient.linear(
      shadowRect.topCenter,
      shadowRect.bottomCenter,
      [
        const Color(0x99000000),
        const Color(0x00000000),
      ],
    );
    canvas.drawRect(shadowRect, Paint()..shader = shadowGradient);

    // 3. Golden Bottom Bezel Line
    final bezelPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, size.y),
      Offset(size.x, size.y),
      bezelPaint,
    );
  }
}

class _StarBadgeComponent extends PositionComponent {
  final int earnedStars;
  final int totalStars;

  _StarBadgeComponent({
    required super.position,
    required super.size,
    required this.earnedStars,
    required this.totalStars,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final starText = TextComponent(
      text: '★',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD166),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      position: Vector2(8, 6),
    );
    add(starText);

    final numText = TextComponent(
      text: '$earnedStars/$totalStars',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFF8FAFC),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      position: Vector2(25, 8),
    );
    add(numText);
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );

    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = const Color(0x55000000),
    );

    // Background
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF1E293B));

    // Gold Trim
    final trimPaint = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rrect, trimPaint);
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
  Future<void> onLoad() async {
    await super.onLoad();
    final chevron = TextComponent(
      text: '<',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFFFF3B0),
          fontSize: 24,
          fontWeight: FontWeight.w900,
          shadows: [
            const Shadow(
              color: Color(0x99000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            )
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2 - 1, size.y / 2),
    );
    add(chevron);
  }

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
      Offset.zero,
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

    if (_isPressed) {
      canvas.restore();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    for (final c in children) {
      if (c is PositionComponent) {
        c.position.y += 3;
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
          c.position.y -= 3;
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
          c.position.y -= 3;
        }
      }
    }
  }
}
