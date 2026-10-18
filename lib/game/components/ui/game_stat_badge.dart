import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/audio_controller.dart';

enum GameStatBadgeType { streak, achievements, xp }

/// An animated ember spark rising from the flame
class _FlameEmber {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;
  Color color;

  _FlameEmber({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
  });

  void reset(double originX, double originY, Random random) {
    x = originX + (random.nextDouble() - 0.5) * 8.0;
    y = originY + random.nextDouble() * 4.0;
    vx = (random.nextDouble() - 0.5) * 8.0;
    vy = -12.0 - random.nextDouble() * 16.0; // Float upward
    life = 0.0;
    maxLife = 0.8 + random.nextDouble() * 0.8;
    size = 1.0 + random.nextDouble() * 1.6;
    final colorChoices = [
      const Color(0xFFFFE082),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFFFD54F),
    ];
    color = colorChoices[random.nextInt(colorChoices.length)];
  }
}

/// A premium game UI badge tile displaying a stat with custom moving animations,
/// tactical carved wood aesthetics, metallic borders, corner rivets, and interactive feedback.
class GameStatBadge extends PositionComponent with TapCallbacks, RiverpodComponentMixin {
  final GameStatBadgeType type;
  final VoidCallback onPressed;
  int _value;

  bool _isPressed = false;
  double _animTime = 0.0;
  final Random _random = Random();

  // Embers for streak badge
  final List<_FlameEmber> _embers = [];

  GameStatBadge({
    required this.type,
    required int initialValue,
    required this.onPressed,
    required super.size,
    required super.position,
  }) : _value = initialValue {
    if (type == GameStatBadgeType.streak) {
      for (int i = 0; i < 5; i++) {
        final ember = _FlameEmber(
          x: 0,
          y: 0,
          vx: 0,
          vy: 0,
          life: 0,
          maxLife: 1.0,
          size: 1.5,
          color: const Color(0xFFFF9800),
        );
        ember.reset(22.0, size.y * 0.5 + 4, _random);
        ember.life = _random.nextDouble() * ember.maxLife; // Stagger initial life
        _embers.add(ember);
      }
    }
  }

  set value(int newVal) {
    if (_value != newVal) {
      _value = newVal;
    }
  }

  int get value => _value;

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;

    if (type == GameStatBadgeType.streak) {
      final originX = 22.0;
      final originY = size.y * 0.5 + 3.0;
      for (final ember in _embers) {
        ember.life += dt;
        if (ember.life >= ember.maxLife) {
          ember.reset(originX, originY, _random);
        } else {
          ember.y += ember.vy * dt;
          ember.x += sin(_animTime * 5.0 + ember.life * 4.0) * (ember.vx * dt);
        }
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      try {
        ref.read(audioControllerProvider).playSfx('ui_click.wav');
      } catch (_) {}
      onPressed();
    }
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    super.onTapCancel(event);
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    final w = size.x;
    final h = size.y;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(13.0),
    );

    // ── 1. Tactical Drop Shadow ──────────────────────────────────────────────
    if (!_isPressed) {
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 4.0, w, h),
        const Radius.circular(13.0),
      );
      canvas.drawRRect(shadowRRect, Paint()..color = const Color(0x66000000));
    }

    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 2.0);
    }

    // ── 2. Plaque Background Surface ─────────────────────────────────────────
    final rect = Rect.fromLTWH(0, 0, w, h);
    final bgGradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      const [
        Color(0xFF381F14), // Warm dark mahogany
        Color(0xFF28140B),
        Color(0xFF1B0B05), // Deep shadow walnut
      ],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = bgGradient);

    // ── 3. Thematic Radial Backlight (Behind Emblem) ─────────────────────────
    final emblemCenter = Offset(21.0, h * 0.5);
    final Color glowColor;
    switch (type) {
      case GameStatBadgeType.streak:
        glowColor = const Color(0x55E65100);
        break;
      case GameStatBadgeType.achievements:
        glowColor = const Color(0x55FFC107);
        break;
      case GameStatBadgeType.xp:
        glowColor = const Color(0x5500B0FF);
        break;
    }

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        emblemCenter,
        28.0,
        [glowColor, glowColor.withValues(alpha: 0.0)],
        const [0.0, 1.0],
      );
    canvas.drawRRect(rrect, glowPaint);

    // ── 4. Carved Metal / Wood Trim Border ───────────────────────────────────
    final List<Color> borderColors;
    switch (type) {
      case GameStatBadgeType.streak:
        borderColors = const [
          Color(0xFFE59B28), // Golden copper
          Color(0xFFB55A22),
          Color(0xFF7A330B),
        ];
        break;
      case GameStatBadgeType.achievements:
        borderColors = const [
          Color(0xFFFFDF78), // Radiant gold
          Color(0xFFD49A24),
          Color(0xFF8A5B0B),
        ];
        break;
      case GameStatBadgeType.xp:
        borderColors = const [
          Color(0xFF8AE0FF), // Celestial brass / cyan
          Color(0xFF4A89A8),
          Color(0xFF234C60),
        ];
        break;
    }

    final borderGradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      borderColors,
      const [0.0, 0.6, 1.0],
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = borderGradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Inner top highlight line (1px highlight bevel)
    canvas.drawLine(
      const Offset(12.0, 1.5),
      Offset(w - 12.0, 1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // ── 5. Corner Studs / Rivets ─────────────────────────────────────────────
    _drawCornerStuds(canvas, w, h);

    // ── 6. Live Emblem Animation ─────────────────────────────────────────────
    switch (type) {
      case GameStatBadgeType.streak:
        _renderStreakEmblem(canvas, emblemCenter);
        break;
      case GameStatBadgeType.achievements:
        _renderAchievementsEmblem(canvas, emblemCenter);
        break;
      case GameStatBadgeType.xp:
        _renderXpEmblem(canvas, emblemCenter);
        break;
    }

    // ── 7. Text Display (Value & Label) ──────────────────────────────────────
    _renderText(canvas, w, h);

    // ── 8. Periodic Shimmer / Glint Sweep (for Achievements) ─────────────────
    if (type == GameStatBadgeType.achievements) {
      _renderShimmerSweep(canvas, rrect, w, h);
    }

    if (_isPressed) {
      canvas.restore();
    }
  }

  void _drawCornerStuds(Canvas canvas, double w, double h) {
    final studOffsets = [
      const Offset(5.0, 5.0),
      Offset(w - 5.0, 5.0),
      Offset(5.0, h - 5.0),
      Offset(w - 5.0, h - 5.0),
    ];
    final darkPaint = Paint()..color = const Color(0xFF160A04);
    final brassPaint = Paint()..color = const Color(0xFFD49A24);
    final glintPaint = Paint()..color = const Color(0xFFFFF6D6);

    for (final pos in studOffsets) {
      canvas.drawCircle(pos, 1.8, darkPaint);
      canvas.drawCircle(pos, 1.2, brassPaint);
      canvas.drawCircle(pos + const Offset(-0.3, -0.3), 0.45, glintPaint);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STREAK ANIMATION: DANCING MULTI-TONE FIRE + RISING EMBERS
  // ════════════════════════════════════════════════════════════════════════════
  void _renderStreakEmblem(Canvas canvas, Offset center) {
    final cx = center.dx;
    final cy = center.dy;

    // A. Pulsing Flame Aura
    final auraPulse = (sin(_animTime * 4.0) + 1.0) * 0.5;
    final auraRadius = 14.0 + auraPulse * 4.0;
    canvas.drawCircle(
      Offset(cx, cy + 1.0),
      auraRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy + 1.0),
          auraRadius,
          [
            const Color(0x66FF6F00),
            const Color(0x00FF6F00),
          ],
          const [0.0, 1.0],
        ),
    );

    // B. Rising Ember Particles
    for (final ember in _embers) {
      final alpha = (1.0 - (ember.life / ember.maxLife)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(ember.x, ember.y),
        ember.size,
        Paint()..color = ember.color.withValues(alpha: alpha * 0.9),
      );
    }

    // C. Animated Flame Shape
    canvas.save();
    canvas.translate(cx, cy + 7.0);

    // Flame breathing & dance swaying
    final sway = sin(_animTime * 6.0) * 1.6;
    final scaleY = 1.0 + sin(_animTime * 5.0) * 0.08;
    final scaleX = 1.0 + cos(_animTime * 5.0) * 0.05;
    canvas.scale(scaleX, scaleY);

    // Outer Ruby/Crimson Flame Path
    final outerPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(-6.5, -2, -9.0, -10, -5.0 + sway * 0.3, -15)
      ..cubicTo(-3.0, -18, -1.0, -21 + sway * 0.5, 0 + sway, -24)
      ..cubicTo(2.0, -20 + sway * 0.4, 5.0, -17, 7.5, -13)
      ..cubicTo(10.0, -8, 7.5, -2, 0, 0)
      ..close();

    final outerPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -24),
        const Offset(0, 0),
        const [
          Color(0xFFFF3D00), // Fiery crimson
          Color(0xFFFF6D00),
          Color(0xFFDD2C00),
        ],
        const [0.0, 0.6, 1.0],
      );
    canvas.drawPath(outerPath, outerPaint);

    // Middle Amber/Orange Flame Path
    final midSway = sin(_animTime * 6.5 + 1.0) * 1.2;
    final midPath = Path()
      ..moveTo(0, -1.0)
      ..cubicTo(-4.5, -2.5, -6.0, -8, -3.0 + midSway * 0.3, -12)
      ..cubicTo(-1.5, -14, -0.5, -16 + midSway * 0.4, 0 + midSway, -19)
      ..cubicTo(1.5, -15 + midSway * 0.3, 3.5, -13, 5.0, -10)
      ..cubicTo(6.5, -6, 5.0, -2, 0, -1.0)
      ..close();

    final midPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -19),
        const Offset(0, -1),
        const [
          Color(0xFFFFD54F), // Bright gold
          Color(0xFFFF9100), // Amber
        ],
        const [0.0, 1.0],
      );
    canvas.drawPath(midPath, midPaint);

    // Inner White-Hot Core Spark
    final corePath = Path()
      ..moveTo(0, -2.0)
      ..cubicTo(-2.5, -3.5, -3.0, -7, 0, -12)
      ..cubicTo(3.0, -7, 2.5, -3.5, 0, -2.0)
      ..close();
    canvas.drawPath(corePath, Paint()..color = const Color(0xFFFFF9C4));

    canvas.restore();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ACHIEVEMENTS ANIMATION: FLOATING TROPHY + STAR TWINKLES
  // ════════════════════════════════════════════════════════════════════════════
  void _renderAchievementsEmblem(Canvas canvas, Offset center) {
    final bobbing = sin(_animTime * 2.8) * 1.5;
    final tilt = sin(_animTime * 2.2) * 0.04;
    final cx = center.dx;
    final cy = center.dy + bobbing;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(tilt);

    // A. Trophy Pedestal Base
    final baseRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7.0, 7.5, 14.0, 4.0),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(baseRect, Paint()..color = const Color(0xFF6D4C10));

    final stemPath = Path()
      ..moveTo(-3.0, 7.5)
      ..lineTo(3.0, 7.5)
      ..lineTo(2.0, 3.0)
      ..lineTo(-2.0, 3.0)
      ..close();
    canvas.drawPath(stemPath, Paint()..color = const Color(0xFFD49A24));

    // B. Trophy Handles
    final handlePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    // Left handle
    canvas.drawArc(
      const Rect.fromLTWH(-10.5, -7.0, 8.0, 8.0),
      pi * 0.5,
      pi * 1.1,
      false,
      handlePaint,
    );
    // Right handle
    canvas.drawArc(
      const Rect.fromLTWH(2.5, -7.0, 8.0, 8.0),
      -pi * 0.6,
      pi * 1.1,
      false,
      handlePaint,
    );

    // C. Trophy Cup Bowl
    final cupPath = Path()
      ..moveTo(-7.0, -8.0)
      ..lineTo(7.0, -8.0)
      ..cubicTo(6.5, -1.0, 4.5, 3.0, 0, 3.5)
      ..cubicTo(-4.5, 3.0, -6.5, -1.0, -7.0, -8.0)
      ..close();

    final cupPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -8.0),
        const Offset(0, 3.5),
        const [
          Color(0xFFFFE082), // Lustrous light gold
          Color(0xFFFFB300), // Polished gold
          Color(0xFFC78700), // Rich shadow gold
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawPath(cupPath, cupPaint);

    // Cup rim highlight
    canvas.drawLine(
      const Offset(-7.0, -8.0),
      const Offset(7.0, -8.0),
      Paint()
        ..color = const Color(0xFFFFF9C4)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Cup star crest
    _drawSparkle(canvas, const Offset(0, -2.5), 2.2, 0, 0.95);

    canvas.restore();

    // D. Twinkling Sparkle Stars (Around Trophy)
    // Star 1 (Top left)
    final sp1 = (_animTime % 2.2) / 2.2;
    if (sp1 < 0.45) {
      final s = sin(sp1 / 0.45 * pi);
      _drawSparkle(canvas, Offset(cx - 9.0, cy - 8.0), 3.2 * s, sp1 * pi, s);
    }
    // Star 2 (Top right)
    final sp2 = ((_animTime + 1.1) % 2.6) / 2.6;
    if (sp2 < 0.45) {
      final s = sin(sp2 / 0.45 * pi);
      _drawSparkle(canvas, Offset(cx + 9.5, cy - 6.5), 2.6 * s, -sp2 * pi, s);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // XP ANIMATION: PULSING ARCANE GEM + ORBITING STARDUST MOTES
  // ════════════════════════════════════════════════════════════════════════════
  void _renderXpEmblem(Canvas canvas, Offset center) {
    final cx = center.dx;
    final cy = center.dy;

    // A. Expanding Arcane Pulse Wave
    final rippleCycle = (_animTime % 2.0) / 2.0;
    final rippleR = 8.0 + rippleCycle * 13.0;
    final rippleAlpha = (1.0 - rippleCycle).clamp(0.0, 1.0) * 0.45;
    canvas.drawCircle(
      Offset(cx, cy),
      rippleR,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: rippleAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // B. Orbiting Stardust Motes
    // Mote 1 (Cyan)
    final a1 = _animTime * 2.5;
    final m1 = Offset(cx + cos(a1) * 11.5, cy + sin(a1) * 6.5);
    canvas.drawCircle(m1, 2.0, Paint()..color = const Color(0x5500E5FF));
    canvas.drawCircle(m1, 1.1, Paint()..color = const Color(0xFFE0F7FA));

    // Mote 2 (Electric Blue / White)
    final a2 = -_animTime * 1.9 + 2.0;
    final m2 = Offset(cx + cos(a2) * 13.0, cy + sin(a2) * 8.0);
    canvas.drawCircle(m2, 2.2, Paint()..color = const Color(0x5580DEEA));
    canvas.drawCircle(m2, 1.3, Paint()..color = const Color(0xFFFFFFFF));

    // Mote 3 (Starlight Gold)
    final a3 = _animTime * 1.5 + 4.2;
    final m3 = Offset(cx + cos(a3) * 9.5, cy + sin(a3) * 5.5);
    canvas.drawCircle(m3, 1.6, Paint()..color = const Color(0x55FFE082));
    canvas.drawCircle(m3, 0.9, Paint()..color = const Color(0xFFFFF9C4));

    // C. Pulsing Arcane Gem Core
    canvas.save();
    canvas.translate(cx, cy);
    final gemPulse = 1.0 + sin(_animTime * 3.5) * 0.08;
    canvas.scale(gemPulse, gemPulse);

    // Outer Octagonal / Diamond Facet
    final outerGem = Path()
      ..moveTo(0, -10.0)
      ..lineTo(5.5, -4.5)
      ..lineTo(7.5, 0)
      ..lineTo(5.5, 4.5)
      ..lineTo(0, 10.0)
      ..lineTo(-5.5, 4.5)
      ..lineTo(-7.5, 0)
      ..lineTo(-5.5, -4.5)
      ..close();

    final gemPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -10.0),
        const Offset(0, 10.0),
        const [
          Color(0xFF00E5FF), // Radiant celestial cyan
          Color(0xFF0091EA),
          Color(0xFF005999),
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawPath(outerGem, gemPaint);

    // Inner Diamond Facet Highlight
    final innerGem = Path()
      ..moveTo(0, -6.5)
      ..lineTo(4.0, 0)
      ..lineTo(0, 6.5)
      ..lineTo(-4.0, 0)
      ..close();

    canvas.drawPath(
      innerGem,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -6.5),
          const Offset(0, 6.5),
          const [
            Color(0xFFE0F7FA), // Brilliant starlight center
            Color(0xFF80DEEA),
          ],
          const [0.0, 1.0],
        ),
    );

    canvas.restore();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 4-POINTED STAR / SPARKLE DRAWING HELPER
  // ════════════════════════════════════════════════════════════════════════════
  void _drawSparkle(Canvas canvas, Offset center, double size, double rotation, double alpha) {
    if (size <= 0.1 || alpha <= 0.01) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.15, -size * 0.25, size * 0.25, -size * 0.15, size, 0)
      ..cubicTo(size * 0.25, size * 0.15, size * 0.15, size * 0.25, 0, size)
      ..cubicTo(-size * 0.15, size * 0.25, -size * 0.25, size * 0.15, -size, 0)
      ..cubicTo(-size * 0.25, -size * 0.15, -size * 0.15, -size * 0.25, 0, -size)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFFFFDE7).withValues(alpha: alpha.clamp(0.0, 1.0)),
    );
    canvas.restore();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHIMMER / GLINT SWEEP (FOR TROPHY BADGE)
  // ════════════════════════════════════════════════════════════════════════════
  void _renderShimmerSweep(Canvas canvas, RRect rrect, double w, double h) {
    final sheenCycle = _animTime % 3.6;
    if (sheenCycle >= 0.8) return;

    final progress = sheenCycle / 0.8;
    final sweepX = -40.0 + progress * (w + 80.0);

    canvas.save();
    canvas.clipRRect(rrect);

    final sheenWidth = 26.0;
    final sheenPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(sweepX - sheenWidth * 0.5, 0),
        Offset(sweepX + sheenWidth * 0.5, h),
        [
          Colors.white.withValues(alpha: 0.0),
          const Color(0xFFFFF59D).withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.40),
          const Color(0xFFFFF59D).withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
        const [0.0, 0.35, 0.5, 0.65, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(sweepX - sheenWidth, 0, sheenWidth * 2, h), sheenPaint);
    canvas.restore();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TEXT RENDERING (VALUE & SUBTITLE LABEL)
  // ════════════════════════════════════════════════════════════════════════════
  void _renderText(Canvas canvas, double w, double h) {
    final textStartX = 39.0;
    final availableW = (w - textStartX - 5.0).clamp(20.0, 150.0);

    final String valueStr;
    final String labelStr;
    final Color valueColor;

    switch (type) {
      case GameStatBadgeType.streak:
        valueStr = '$_value';
        labelStr = 'STREAK';
        valueColor = _value > 0 ? const Color(0xFFFFD54F) : const Color(0xFFA89F91);
        break;
      case GameStatBadgeType.achievements:
        valueStr = '$_value';
        labelStr = 'BADGES';
        valueColor = const Color(0xFFFFE082);
        break;
      case GameStatBadgeType.xp:
        valueStr = '$_value XP';
        labelStr = 'TOTAL XP';
        valueColor = const Color(0xFFE0F7FA);
        break;
    }

    // 1. Value Text with Auto-Fit
    double fontSize = type == GameStatBadgeType.xp ? 14.5 : 16.5;
    TextPainter valuePainter = _layoutText(
      valueStr,
      GoogleFonts.nunitoSans(
        color: valueColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
        shadows: const [
          Shadow(
            color: Color(0xCC000000),
            offset: Offset(0, 1.5),
            blurRadius: 2.5,
          ),
        ],
      ),
    );

    // Auto-scale font down if large numbers (e.g. 5-digit XP)
    while (fontSize > 10.0 && valuePainter.width > availableW) {
      fontSize -= 0.6;
      valuePainter = _layoutText(
        valueStr,
        GoogleFonts.nunitoSans(
          color: valueColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
          shadows: const [
            Shadow(
              color: Color(0xCC000000),
              offset: Offset(0, 1.5),
              blurRadius: 2.5,
            ),
          ],
        ),
      );
    }

    final valueY = h * 0.5 - valuePainter.height + 1.5;
    valuePainter.paint(canvas, Offset(textStartX, valueY));

    // 2. Subtitle Label
    final labelPainter = _layoutText(
      labelStr,
      GoogleFonts.quicksand(
        color: const Color(0xFFD4B28C),
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        shadows: const [
          Shadow(
            color: Color(0x99000000),
            offset: Offset(0, 1.0),
            blurRadius: 1.5,
          ),
        ],
      ),
    );

    final labelY = h * 0.5 + 2.5;
    labelPainter.paint(canvas, Offset(textStartX, labelY));
  }

  TextPainter _layoutText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter;
  }
}
