import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';

/// A soft, animated game UI stage node card.
///
/// Styled like top animated adventure games (Zelda, Genshin, Ori):
/// - Soft rounded organic tablets with warm wood/moss/amber palette
/// - Sunlit golden medallion portal with tactile depth
/// - Warm breathing aura ring on the active/ready stage
/// - 3-Star achievement rating and status
/// - Fully reactive updateProgress() method for dynamic level unlocking
class StageNodeComponent extends PositionComponent with TapCallbacks {
  final int stageNumber;
  final String title;
  int stars;
  bool isUnlocked;
  bool isCurrent;
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
  }) : super(size: size ?? Vector2(195, 72));

  Vector2 get riverAnchorPoint {
    final mx = isLeftAligned ? 36.0 : (size.x - 36.0);
    return Vector2(position.x + mx, position.y + (size.y / 2.0));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final medallionCenterX = isLeftAligned ? 36.0 : (size.x - 36.0);
    final double contentLeft = isLeftAligned ? 68.0 : 16.0;

    // 1. Stage Subtitle
    _stageSubText = TextComponent(
      text: _computeSubText(),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: _computeSubColor(),
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(contentLeft, 11),
    );
    add(_stageSubText);

    // 2. Stage Title
    final displayTitle = title.length > 13 ? '${title.substring(0, 12)}...' : title;
    _titleText = TextComponent(
      text: displayTitle,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: isUnlocked ? const Color(0xFFFDFBF7) : const Color(0xFFA0AEC0),
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          shadows: [
            const Shadow(
              color: Color(0x99000000),
              offset: Offset(0, 1.5),
              blurRadius: 2.0,
            )
          ],
        ),
      ),
      position: Vector2(contentLeft, 27),
    );
    add(_titleText);

    // 3. Stars / Status row
    _starRatingText = TextComponent(
      text: _computeStatusText(),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: _computeStatusColor(),
          fontSize: 10.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
      position: Vector2(contentLeft, 47),
    );
    add(_starRatingText);

    // 4. Medallion Glyph
    _medallionText = TextComponent(
      text: !isUnlocked ? '🔒' : '$stageNumber',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: isCurrent || stars > 0 ? const Color(0xFF2C1E07) : const Color(0xFFF1F5F9),
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

  void updateProgress({
    required int stars,
    required bool isUnlocked,
    required bool isCurrent,
  }) {
    this.stars = stars;
    this.isUnlocked = isUnlocked;
    this.isCurrent = isCurrent;

    _stageSubText.text = _computeSubText();
    _stageSubText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: _computeSubColor(),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );

    final displayTitle = title.length > 13 ? '${title.substring(0, 12)}...' : title;
    _titleText.text = displayTitle;
    _titleText.textRenderer = TextPaint(
      style: GoogleFonts.nunitoSans(
        color: isUnlocked ? const Color(0xFFFDFBF7) : const Color(0xFFA0AEC0),
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );

    _starRatingText.text = _computeStatusText();
    _starRatingText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: _computeStatusColor(),
        fontSize: 10.0,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );

    _medallionText.text = !isUnlocked ? '🔒' : '$stageNumber';
    _medallionText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: isCurrent || stars > 0 ? const Color(0xFF2C1E07) : const Color(0xFFF1F5F9),
        fontSize: !isUnlocked ? 14 : 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  String _computeSubText() {
    if (!isUnlocked) return 'STAGE $stageNumber';
    if (isCurrent) return 'STAGE $stageNumber • READY';
    return 'STAGE $stageNumber';
  }

  Color _computeSubColor() {
    if (!isUnlocked) return const Color(0xFF8C9BAE);
    if (isCurrent) return const Color(0xFFFFD54F);
    if (stars > 0) return const Color(0xFFFFE082);
    return const Color(0xFF81D4FA);
  }

  String _computeStatusText() {
    if (!isUnlocked) return '🔒 LOCKED';
    if (stars == 3) return '★★★ CLEARED';
    if (stars == 2) return '★★☆ CLEARED';
    if (stars == 1) return '★☆☆ CLEARED';
    return isCurrent ? '▶ PLAY NOW' : '☆☆☆ UNLOCKED';
  }

  Color _computeStatusColor() {
    if (!isUnlocked) return const Color(0xFF8C9BAE);
    if (stars > 0) return const Color(0xFFFFD166);
    return isCurrent ? const Color(0xFFA7F3D0) : const Color(0xFF94A3B8);
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
      const Radius.circular(20.0),
    );

    // 1. Soft Drop Shadow
    if (!_isPressed) {
      final shadowColor = isUnlocked ? const Color(0x66000000) : const Color(0x44000000);
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 5, size.x, size.y),
        const Radius.circular(20.0),
      );
      canvas.drawRRect(shadowRRect, Paint()..color = shadowColor);
    }

    if (_isPressed) {
      canvas.save();
      canvas.translate(0, 3);
    }

    // 2. Soft Nature Tablet Gradient (Warm Wood, Moss Green, Warm Amber)
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final List<Color> bgColors;
    if (!isUnlocked) {
      bgColors = [
        const Color(0xFF2E3D39), // Soft weathered river moss stone
        const Color(0xFF24302D),
        const Color(0xFF1B2523),
      ];
    } else if (isCurrent) {
      bgColors = [
        const Color(0xFFD97706), // Warm sunlit amber gold
        const Color(0xFFB45309),
        const Color(0xFF8A3D06),
      ];
    } else if (stars > 0) {
      bgColors = [
        const Color(0xFF2E6F4B), // Lush forest jade moss
        const Color(0xFF23583B),
        const Color(0xFF18422B),
      ];
    } else {
      bgColors = [
        const Color(0xFF335C67), // Soft mountain lake teal
        const Color(0xFF274750),
        const Color(0xFF1B3238),
      ];
    }

    final gradient = ui.Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      bgColors,
      const [0.0, 0.5, 1.0],
    );

    canvas.drawRRect(rrect, Paint()..shader = gradient);

    // 3. Warm Beveled Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (!isUnlocked) {
      borderPaint.color = const Color(0xFF4A5E57); // Muted river moss rim
    } else if (isCurrent) {
      borderPaint.color = const Color(0xFFFFE082); // Warm sun gold rim
    } else if (stars > 0) {
      borderPaint.color = const Color(0xFFE5B048); // Antique gold rim
    } else {
      borderPaint.color = const Color(0xFF78909C);
    }
    canvas.drawRRect(rrect, borderPaint);

    // 4. Soft Top Chamfer Highlight
    final topHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isUnlocked ? 0.28 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    canvas.drawLine(
      const Offset(20, 2),
      Offset(size.x - 20, 2),
      topHighlightPaint,
    );

    // 5. Render Medallion Portal Plate
    final medallionCenterX = isLeftAligned ? 36.0 : (size.x - 36.0);
    final medallionCenter = Offset(medallionCenterX, size.y / 2.0);
    _renderMedallion(canvas, medallionCenter);

    if (_isPressed) {
      canvas.restore();
    }
  }

  void _renderMedallion(Canvas canvas, Offset center) {
    const radius = 24.0;

    // A. Soft Warm Breathing Halo on Ready Stage
    if (isCurrent) {
      final pulse = (sin(_animTime * 3.5) + 1.0) / 2.0;
      final pulseRadius = radius + 3.0 + (pulse * 5.0);
      final pulseAlpha = (0.5 - (pulse * 0.35)).clamp(0.0, 1.0);

      final pulsePaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: pulseAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // B. Medallion Drop Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x55000000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, 2.5), radius, shadowPaint);

    // C. Medallion Plate Gradient
    final plateColors = isUnlocked
        ? (isCurrent
            ? [const Color(0xFFFDE047), const Color(0xFFF59E0B), const Color(0xFFB45309)]
            : (stars > 0
                ? [const Color(0xFFFDE68A), const Color(0xFFD97706), const Color(0xFF92400E)]
                : [const Color(0xFF475569), const Color(0xFF334155), const Color(0xFF1E293B)]))
        : [const Color(0xFF33413E), const Color(0xFF273330), const Color(0xFF1B2321)];

    final plateGradient = ui.Gradient.radial(
      center - const Offset(3, 3),
      radius * 1.2,
      plateColors,
      const [0.0, 0.6, 1.0],
    );

    canvas.drawCircle(center, radius, Paint()..shader = plateGradient);

    // D. Medallion Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = isUnlocked
          ? (isCurrent ? const Color(0xFFFFFBEB) : const Color(0xFFFFE082))
          : const Color(0xFF566963);
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isUnlocked) return;
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
