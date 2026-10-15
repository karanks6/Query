import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';

/// A soft, animated adventure game World Node card.
///
/// Styled like top animated adventure games (Zelda, Genshin, Ori):
/// - Soft rounded organic tablets with warm wood/moss/amber palette
/// - 3D sunlit golden medallion portal showing chapter number or lock state
/// - Warm breathing aura ring on the active/ready expedition
/// - Clear progress indicator (stages cleared & star count)
/// - Fully reactive updateProgress() for dynamic unlocking
class WorldNodeComponent extends PositionComponent with TapCallbacks {
  final int worldNumber;
  final String worldId;
  String title;
  int stagesCompleted;
  int totalStages;
  int starsEarned;
  bool isUnlocked;
  bool isCurrent;
  final bool isLeftAligned;
  final VoidCallback onPressed;

  final double screenWidth;
  final double margin;

  bool _isPressed = false;
  double _animTime = 0.0;

  late TextComponent _subText;
  late TextComponent _titleText;
  late TextComponent _medallionText;
  late TextComponent _statusText;

  WorldNodeComponent({
    required this.worldNumber,
    required this.worldId,
    required this.title,
    required this.stagesCompleted,
    required this.totalStages,
    required this.starsEarned,
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
                      ? 'CHAPTER $worldNumber'
                      : (totalStages > 0 && stagesCompleted >= totalStages
                          ? 'CHAPTER $worldNumber • EXPEDITION CLEAR'
                          : (isCurrent ? 'CHAPTER $worldNumber • EXPEDITION ACTIVE' : 'CHAPTER $worldNumber')),
                  statusText: !isUnlocked
                      ? '🔒 LOCKED'
                      : (totalStages > 0 && stagesCompleted >= totalStages
                          ? '★ $starsEarned STARS • ALL CLEAR'
                          : (stagesCompleted > 0
                              ? '★ $starsEarned STARS • $stagesCompleted/$totalStages CLEARED'
                              : (isCurrent ? '▶ EXPLORE NOW' : '☆☆☆ UNLOCKED • $totalStages STAGES'))),
                  screenWidth: screenWidth,
                  margin: margin,
                ),
                76.0,
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
      fontSize: 12.5,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.4,
    );
    final statusStyle = GoogleFonts.quicksand(
      fontSize: 9.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
    );

    final wSub = measureTextWidth(subText, subStyle);
    final wTitle = measureTextWidth(title.toUpperCase(), titleStyle);
    final wStatus = measureTextWidth(statusText, statusStyle);

    final maxTextWidth = [wSub, wTitle, wStatus].reduce(max);
    // Medallion (50px) + margins (13px outer, 9px inner = 72px) + text + opposite edge curve padding (22px) = 94px total padding
    final needed = maxTextWidth + 94.0;

    final effectiveScreenW = screenWidth > 0 ? screenWidth : 390.0;
    final maxAllowed = (effectiveScreenW - (margin * 2.0)).clamp(220.0, effectiveScreenW);

    return needed.clamp(235.0, maxAllowed);
  }

  Vector2 get riverAnchorPoint {
    final mx = isLeftAligned ? 38.0 : (size.x - 38.0);
    return Vector2(position.x + mx, position.y + (size.y / 2.0));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _subText = TextComponent();
    add(_subText);

    _titleText = TextComponent();
    add(_titleText);

    _statusText = TextComponent();
    add(_statusText);

    _medallionText = TextComponent(anchor: Anchor.center);
    add(_medallionText);

    _applyLayoutAndStyles();
  }

  bool get _isCompleted => totalStages > 0 && stagesCompleted >= totalStages;

  void updateProgress({
    required int stagesCompleted,
    required int totalStages,
    required int starsEarned,
    required bool isUnlocked,
    required bool isCurrent,
    String? newTitle,
  }) {
    this.stagesCompleted = stagesCompleted;
    this.totalStages = totalStages;
    this.starsEarned = starsEarned;
    this.isUnlocked = isUnlocked;
    this.isCurrent = isCurrent;
    if (newTitle != null && newTitle.isNotEmpty) {
      title = newTitle;
    }

    if (isLoaded) {
      _applyLayoutAndStyles();
    }
  }

  void _applyLayoutAndStyles() {
    final subTextStr = _computeSubText();
    final statusTextStr = _computeStatusText();

    // 1. Calculate flexible width based on the actual words
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

    final medallionCenterX = isLeftAligned ? 38.0 : (size.x - 38.0);
    final contentLeft = isLeftAligned ? 72.0 : 20.0;
    // Available width for text lines before hitting medallion or opposite edge
    final availableTextWidth = (size.x - 92.0).clamp(100.0, screenWidth > 0 ? screenWidth : 390.0);

    // 3. Subtitle with auto-fitting so it never overflows
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

    _subText.text = subTextStr;
    _subText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: _computeSubColor(),
        fontSize: subFontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: subLetterSpacing,
      ),
    );
    _subText.position = Vector2(contentLeft, 11);

    // 4. World Title (Full untruncated title with auto-fitting)
    final fullTitleUpper = title.toUpperCase();
    double titleFontSize = 12.5;
    double titleLetterSpacing = 0.4;
    while (titleFontSize > 9.0 &&
        measureTextWidth(
              fullTitleUpper,
              GoogleFonts.nunitoSans(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: titleLetterSpacing,
              ),
            ) >
            availableTextWidth) {
      titleFontSize -= 0.5;
      if (titleLetterSpacing > 0.1) titleLetterSpacing -= 0.1;
    }

    _titleText.text = fullTitleUpper;
    _titleText.textRenderer = TextPaint(
      style: GoogleFonts.nunitoSans(
        color: isUnlocked ? const Color(0xFFFDFBF7) : const Color(0xFFA0AEC0),
        fontSize: titleFontSize,
        fontWeight: FontWeight.w900,
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

    // 5. Status Text with auto-fitting
    double statusFontSize = 9.5;
    double statusLetterSpacing = 0.5;
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

    _statusText.text = statusTextStr;
    _statusText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: _computeStatusColor(),
        fontSize: statusFontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: statusLetterSpacing,
      ),
    );
    _statusText.position = Vector2(contentLeft, 47);

    // 6. Medallion glyph
    _medallionText.text = !isUnlocked ? '🔒' : '$worldNumber';
    _medallionText.textRenderer = TextPaint(
      style: GoogleFonts.nunitoSans(
        color: isCurrent || _isCompleted ? const Color(0xFF2C1E07) : const Color(0xFFF1F5F9),
        fontSize: !isUnlocked ? 15 : 20,
        fontWeight: FontWeight.w900,
        shadows: isCurrent || _isCompleted
            ? [const Shadow(color: Color(0x66FFFFFF), offset: Offset(0, 1), blurRadius: 1)]
            : null,
      ),
    );
    _medallionText.position = Vector2(medallionCenterX, size.y / 2.0);
  }

  String _computeSubText() {
    if (!isUnlocked) return 'CHAPTER $worldNumber';
    if (_isCompleted) return 'CHAPTER $worldNumber • EXPEDITION CLEAR';
    if (isCurrent) return 'CHAPTER $worldNumber • EXPEDITION ACTIVE';
    return 'CHAPTER $worldNumber';
  }

  Color _computeSubColor() {
    if (!isUnlocked) return const Color(0xFF8C9BAE);
    if (isCurrent) return const Color(0xFFFFD54F);
    if (_isCompleted) return const Color(0xFFFFE082);
    return const Color(0xFF81D4FA);
  }

  String _computeStatusText() {
    if (!isUnlocked) return '🔒 LOCKED';
    if (_isCompleted) return '★ $starsEarned STARS • ALL CLEAR';
    if (stagesCompleted > 0) return '★ $starsEarned STARS • $stagesCompleted/$totalStages CLEARED';
    return isCurrent ? '▶ EXPLORE NOW' : '☆☆☆ UNLOCKED • $totalStages STAGES';
  }

  Color _computeStatusColor() {
    if (!isUnlocked) return const Color(0xFF8C9BAE);
    if (_isCompleted) return const Color(0xFFFFD166);
    if (isCurrent) return const Color(0xFFA7F3D0);
    return const Color(0xFF94A3B8);
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
    } else if (_isCompleted) {
      bgColors = [
        const Color(0xFF2E6F4B), // Lush forest jade moss
        const Color(0xFF23583B),
        const Color(0xFF18422B),
      ];
    } else {
      bgColors = [
        const Color(0xFF4E3524), // Warm expedition timber
        const Color(0xFF3B2518),
        const Color(0xFF2C1B10),
      ];
    }

    final bgGradient = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      bgColors,
      const [0.0, 0.55, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = bgGradient);

    // 3. Golden / Nature Bezel Trim
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (!isUnlocked) {
      borderPaint.color = const Color(0xFF4B5E57);
    } else if (isCurrent) {
      borderPaint.color = const Color(0xFFFFD54F);
    } else if (_isCompleted) {
      borderPaint.color = const Color(0xFF68D391);
    } else {
      borderPaint.color = const Color(0xFFE5B048);
    }
    canvas.drawRRect(rrect, borderPaint);

    // 4. Subtle Top Edge Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isUnlocked ? 0.28 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    final startX = isLeftAligned ? 68.0 : 16.0;
    final endX = isLeftAligned ? size.x - 16.0 : size.x - 68.0;
    canvas.drawLine(
      Offset(startX, 2.5),
      Offset(endX, 2.5),
      highlightPaint,
    );

    // 5. Pulsing Aura on Active/Current World
    if (isCurrent) {
      final pulse = (sin(_animTime * 3.5) + 1.0) / 2.0; // 0.0 -> 1.0
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.18 + 0.18 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 + 2.0 * pulse;

      final glowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-3, -3, size.x + 6, size.y + 6),
        const Radius.circular(23.0),
      );
      canvas.drawRRect(glowRRect, glowPaint);
    }

    // 6. 3D Medallion Portal Backing & Rim
    final medallionCenterX = isLeftAligned ? 38.0 : (size.x - 38.0);
    _renderMedallion(canvas, Offset(medallionCenterX, size.y / 2.0));

    if (_isPressed) {
      canvas.restore();
    }
  }

  void _renderMedallion(Canvas canvas, Offset center) {
    const radius = 25.0;

    // Medallion Drop Shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      radius,
      Paint()..color = const Color(0x55000000),
    );

    // Medallion Plate Gradient
    final plateColors = isUnlocked
        ? (isCurrent || _isCompleted
            ? [const Color(0xFFFFE082), const Color(0xFFF59E0B), const Color(0xFFD97706)]
            : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1), const Color(0xFF94A3B8)])
        : [const Color(0xFF24302D), const Color(0xFF1B2523), const Color(0xFF121B19)];

    final plateGradient = ui.Gradient.radial(
      center - const Offset(4, 4),
      radius,
      plateColors,
      const [0.0, 0.65, 1.0],
    );

    canvas.drawCircle(center, radius, Paint()..shader = plateGradient);

    // Medallion Bezel Rim
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
