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

  final double screenWidth;
  final double margin;

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
    this.screenWidth = 390.0,
    this.margin = 14.0,
    super.position,
    Vector2? size,
  }) : super(
          size: size ??
              Vector2(
                calculateRequiredWidth(
                  title: title,
                  subText: !isUnlocked
                      ? 'STAGE $stageNumber'
                      : (isCurrent ? 'STAGE $stageNumber • READY' : 'STAGE $stageNumber'),
                  statusText: !isUnlocked
                      ? '🔒 LOCKED'
                      : (stars == 3
                          ? '★★★ CLEARED'
                          : (stars == 2
                              ? '★★☆ CLEARED'
                              : (stars == 1 ? '★☆☆ CLEARED' : (isCurrent ? '▶ PLAY NOW' : '☆☆☆ UNLOCKED')))),
                  screenWidth: screenWidth,
                  margin: margin,
                ),
                72.0,
              ),
        );

  static double measureTextWidth(String text, TextStyle style) {
    if (text.isEmpty) return 0.0;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  static double calculateRequiredWidth({
    required String title,
    required String subText,
    required String statusText,
    required double screenWidth,
    double margin = 14.0,
  }) {
    final subStyle = GoogleFonts.quicksand(
      fontSize: 10.0,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.7,
    );
    final titleStyle = GoogleFonts.nunitoSans(
      fontSize: 12.0,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );
    final statusStyle = GoogleFonts.quicksand(
      fontSize: 9.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    );

    final wSub = measureTextWidth(subText, subStyle);
    final wTitle = measureTextWidth(title, titleStyle);
    final wStatus = measureTextWidth(statusText, statusStyle);

    final maxTextWidth = [wSub, wTitle, wStatus].reduce(max);
    // Medallion side (46px diameter + 11px margin + 9px gap = 66px) + text + opposite edge padding (20px) = 86px
    final needed = maxTextWidth + 88.0;

    final effectiveScreenW = screenWidth > 0 ? screenWidth : 390.0;
    final maxAllowed = (effectiveScreenW - (margin * 2.0)).clamp(200.0, effectiveScreenW);

    return needed.clamp(215.0, maxAllowed);
  }

  Vector2 get riverAnchorPoint {
    final mx = isLeftAligned ? 36.0 : (size.x - 36.0);
    return Vector2(position.x + mx, position.y + (size.y / 2.0));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _stageSubText = TextComponent();
    add(_stageSubText);

    _titleText = TextComponent();
    add(_titleText);

    _starRatingText = TextComponent();
    add(_starRatingText);

    _medallionText = TextComponent(anchor: Anchor.center);
    add(_medallionText);

    _applyLayoutAndStyles();
  }

  void updateProgress({
    required int stars,
    required bool isUnlocked,
    required bool isCurrent,
  }) {
    this.stars = stars;
    this.isUnlocked = isUnlocked;
    this.isCurrent = isCurrent;

    if (isLoaded) {
      _applyLayoutAndStyles();
    }
  }

  void _applyLayoutAndStyles() {
    final subTextStr = _computeSubText();
    final statusTextStr = _computeStatusText();

    // 1. Calculate flexible width based on words
    final requiredWidth = calculateRequiredWidth(
      title: title,
      subText: subTextStr,
      statusText: statusTextStr,
      screenWidth: screenWidth,
      margin: margin,
    );
    size.x = requiredWidth;

    // 2. If right-aligned, update position.x to keep margin consistent
    if (!isLeftAligned && screenWidth > 0) {
      position.x = screenWidth - size.x - margin;
    }

    final medallionCenterX = isLeftAligned ? 36.0 : (size.x - 36.0);
    final contentLeft = isLeftAligned ? 66.0 : 18.0;
    final availableTextWidth = (size.x - 86.0).clamp(100.0, screenWidth > 0 ? screenWidth : 390.0);

    // 3. Stage Subtitle with auto-fitting
    double subFontSize = 10.0;
    double subLetterSpacing = 0.7;
    while (subFontSize > 8.0 &&
        measureTextWidth(
              subTextStr,
              GoogleFonts.quicksand(
                fontSize: subFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: subLetterSpacing,
              ),
            ) >
            availableTextWidth) {
      subFontSize -= 0.4;
      if (subLetterSpacing > 0.2) subLetterSpacing -= 0.2;
    }

    _stageSubText.text = subTextStr;
    _stageSubText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: _computeSubColor(),
        fontSize: subFontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: subLetterSpacing,
      ),
    );
    _stageSubText.position = Vector2(contentLeft, 11);

    // 4. Stage Title (Full untruncated title with auto-fitting)
    double titleFontSize = 12.0;
    double titleLetterSpacing = 0.2;
    while (titleFontSize > 8.5 &&
        measureTextWidth(
              title,
              GoogleFonts.nunitoSans(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: titleLetterSpacing,
              ),
            ) >
            availableTextWidth) {
      titleFontSize -= 0.5;
      if (titleLetterSpacing > 0.0) titleLetterSpacing -= 0.05;
    }

    _titleText.text = title;
    _titleText.textRenderer = TextPaint(
      style: GoogleFonts.nunitoSans(
        color: isUnlocked ? const Color(0xFFFDFBF7) : const Color(0xFFA0AEC0),
        fontSize: titleFontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: titleLetterSpacing,
        shadows: [
          const Shadow(
            color: Color(0x99000000),
            offset: Offset(0, 1.5),
            blurRadius: 2.0,
          )
        ],
      ),
    );
    _titleText.position = Vector2(contentLeft, 27);

    // 5. Stars / Status row with auto-fitting
    double statusFontSize = 9.5;
    double statusLetterSpacing = 0.6;
    while (statusFontSize > 8.0 &&
        measureTextWidth(
              statusTextStr,
              GoogleFonts.quicksand(
                fontSize: statusFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: statusLetterSpacing,
              ),
            ) >
            availableTextWidth) {
      statusFontSize -= 0.5;
    }

    _starRatingText.text = statusTextStr;
    _starRatingText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: _computeStatusColor(),
        fontSize: statusFontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: statusLetterSpacing,
      ),
    );
    _starRatingText.position = Vector2(contentLeft, 47);

    // 6. Medallion Glyph
    _medallionText.text = !isUnlocked ? '🔒' : '$stageNumber';
    _medallionText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: isCurrent || stars > 0 ? const Color(0xFF2C1E07) : const Color(0xFFF1F5F9),
        fontSize: !isUnlocked ? 14 : 19,
        fontWeight: FontWeight.w900,
        shadows: isCurrent || stars > 0
            ? [const Shadow(color: Color(0x66FFFFFF), offset: Offset(0, 1), blurRadius: 1)]
            : null,
      ),
    );
    _medallionText.position = Vector2(medallionCenterX, size.y / 2.0);
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
