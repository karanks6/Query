import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';

/// A soft, animated adventure game fixed header for the World Select Trail.
///
/// Features:
/// - Safe top spacing (46px+ top inset) preventing any collision with Android status bar/notch
/// - Warm adventure game palette (mahogany canopy, warm gold trim, glowing star counters)
/// - 3D tactile circular Back Button with warm wood/amber tones and bounce feedback
/// - World Trail Title & Expedition subtitle styled with soft fantasy typography
/// - Dynamic Star Trophy pill badge showing total stars earned across all worlds
class WorldSelectHeaderComponent extends PositionComponent {
  final String title;
  final String subtitle;
  int unlockedWorlds;
  final int totalWorlds;
  int earnedStars;
  final VoidCallback onBackPressed;

  late _HeaderTrophyBadgeComponent _badgePill;
  late TextComponent _titleComp;
  late TextComponent _subtitleComp;

  WorldSelectHeaderComponent({
    required this.title,
    required this.subtitle,
    required this.unlockedWorlds,
    required this.totalWorlds,
    required this.earnedStars,
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

    // 2. World Trail Title Text
    final centerX = size.x / 2.0;
    _titleComp = TextComponent(
      text: title.toUpperCase(),
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

    // 3. Subtitle Text
    _subtitleComp = TextComponent(
      text: subtitle.toUpperCase(),
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

    // 4. Star / World Trophy Badge Text
    const badgeWidth = 72.0;
    const badgeHeight = 32.0;
    final badgeLeft = size.x - badgeWidth - 16.0;
    final badgeTop = topInset + 6.0;

    _badgePill = _HeaderTrophyBadgeComponent(
      position: Vector2(badgeLeft, badgeTop),
      size: Vector2(badgeWidth, badgeHeight),
      earnedStars: earnedStars,
      unlockedWorlds: unlockedWorlds,
      totalWorlds: totalWorlds,
    );
    add(_badgePill);
  }

  void updateStats({
    required int unlocked,
    required int total,
    required int stars,
  }) {
    unlockedWorlds = unlocked;
    earnedStars = stars;
    _badgePill.updateStats(unlocked, total, stars);
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

class _HeaderTrophyBadgeComponent extends PositionComponent {
  int earnedStars;
  int unlockedWorlds;
  int totalWorlds;
  late TextComponent _text;

  _HeaderTrophyBadgeComponent({
    required super.position,
    required super.size,
    required this.earnedStars,
    required this.unlockedWorlds,
    required this.totalWorlds,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final starIcon = TextComponent(
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
    add(starIcon);

    _text = TextComponent(
      text: '$earnedStars',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF9EC),
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
        ),
      ),
      position: Vector2(25, 7),
    );
    add(_text);
  }

  void updateStats(int unlocked, int total, int stars) {
    unlockedWorlds = unlocked;
    totalWorlds = total;
    earnedStars = stars;
    _text.text = '$stars';
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
