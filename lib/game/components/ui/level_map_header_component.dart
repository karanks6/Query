import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';

/// A soft, animated adventure game fixed header for the Level Map.
///
/// Features:
/// - Safe top spacing (46px+ top inset) preventing any collision with Android status bar/notch
/// - Warm adventure game palette (mahogany canopy, warm gold trim, soft glowing stars)
/// - 3D tactile circular Back Button with warm wood/amber tones and bounce feedback
/// - World Title & Chapter subtitle styled with soft fantasy typography
/// - Dynamic Star Trophy pill badge that updates reactively
class LevelMapHeaderComponent extends PositionComponent {
  final String worldTitle;
  final String worldSubtitle;
  int earnedStars;
  final int totalPossibleStars;
  final VoidCallback onBackPressed;

  late _StarBadgeComponent _badgePill;
  late TextComponent _titleComp;
  late TextComponent _subtitleComp;

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

    const topInset = 46.0;

    // 1. Back Button
    final backBtn = _HeaderBackButton(
      position: Vector2(16, topInset),
      size: Vector2(44, 44),
      onPressed: onBackPressed,
    );
    add(backBtn);

    // 2. World Title Text
    final centerX = size.x / 2.0;
    _titleComp = TextComponent(
      text: worldTitle.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF9EC),
          fontSize: 16.5,
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
      position: Vector2(centerX, topInset + 2),
    );
    add(_titleComp);

    // 3. World Subtitle Text
    _subtitleComp = TextComponent(
      text: worldSubtitle.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFFFD166),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(centerX, topInset + 25),
    );
    add(_subtitleComp);

    // 4. Star Badge Text
    const badgeWidth = 68.0;
    const badgeHeight = 32.0;
    final badgeLeft = size.x - badgeWidth - 16.0;
    final badgeTop = topInset + 6.0;

    _badgePill = _StarBadgeComponent(
      position: Vector2(badgeLeft, badgeTop),
      size: Vector2(badgeWidth, badgeHeight),
      earnedStars: earnedStars,
      totalStars: totalPossibleStars,
    );
    add(_badgePill);
  }

  void updateStars(int earned, int total) {
    earnedStars = earned;
    _badgePill.updateStars(earned, total);
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    // 1. Warm Mahogany Canopy Backdrop with Gradient
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgGradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      [
        const Color(0xF724160E),
        const Color(0xEB1A100A),
        const Color(0xD9120B07),
      ],
      const [0.0, 0.7, 1.0],
    );

    canvas.drawRect(rect, Paint()..shader = bgGradient);

    // 2. Soft Bottom Shadow Gradient
    final shadowRect = Rect.fromLTWH(0, size.y, size.x, 18);
    final shadowGradient = ui.Gradient.linear(
      shadowRect.topCenter,
      shadowRect.bottomCenter,
      [
        const Color(0x80000000),
        const Color(0x00000000),
      ],
    );
    canvas.drawRect(shadowRect, Paint()..shader = shadowGradient);

    // 3. Warm Amber Bezel Line
    final bezelPaint = Paint()
      ..color = const Color(0xFFD48B3E)
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
  int earnedStars;
  int totalStars;
  late TextComponent _numText;

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
      position: Vector2(7, 6),
    );
    add(starText);

    _numText = TextComponent(
      text: '$earnedStars/$totalStars',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF9EC),
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      position: Vector2(25, 7),
    );
    add(_numText);
  }

  void updateStars(int earned, int total) {
    earnedStars = earned;
    totalStars = total;
    _numText.text = '$earned/$total';
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );

    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 2)),
      Paint()..color = const Color(0x55000000),
    );

    // Background
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF332014));

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
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF9EC),
          fontSize: 23,
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
        rrect.shift(const Offset(0, 3)),
        Paint()..color = const Color(0x66000000),
      );
    }

    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 2);
    }

    // Warm Adventure Wood/Amber Gradient Fill
    final bgGradient = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      [
        const Color(0xFF4E3524),
        const Color(0xFF332014),
      ],
    );
    canvas.drawRRect(rrect, Paint()..shader = bgGradient);

    // Golden Rim
    final borderPaint = Paint()
      ..color = const Color(0xFFE5B048)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Top Rim Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
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
        c.position.y += 2;
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
          c.position.y -= 2;
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
          c.position.y -= 2;
        }
      }
    }
  }
}
