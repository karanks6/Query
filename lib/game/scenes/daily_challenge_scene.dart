import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import 'gameplay_scene.dart';
import '../../features/daily_challenge/daily_challenge_service.dart';
import '../../data/content/models/level_model.dart';
import '../components/ui/wood_button.dart';

/// The Daily Forage Expedition scene, styled in Wanderwood fantasy adventure aesthetics.
///
/// Features:
/// - Living atmospheric mahogany background with floating golden spore motes
/// - Fixed top navigation canopy with notch clearance (46px+), tactile back button,
///   glowing title typography, and a live countdown timer badge
/// - Ornate Expedition Folio parchment with carved wood trim, brass corner rivets,
///   challenge badge ribbon, narrative briefing, schema intel chips, and 3-card bounty rewards
/// - Dynamic primary Start Expedition action button with pulsing shimmer and daily streak accents
class DailyChallengeScene extends QueryScene {
  LevelModel? _todayLevel;
  late _DailyAtmosphericBackground _bgComponent;
  late _DailyHeaderComponent _headerComponent;
  late PositionComponent _contentContainer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _todayLevel = await DailyChallengeService.instance.getTodayChallenge();

    // 1. Living Atmospheric Background with motes
    _bgComponent = _DailyAtmosphericBackground(size: game.size);
    add(_bgComponent);

    // 2. Fixed Top Navigation Canopy
    _headerComponent = _DailyHeaderComponent(
      size: Vector2(game.size.x, 106),
      onBackPressed: () => game.popScene(),
    );
    add(_headerComponent);

    // 3. Responsive Content Container
    _contentContainer = PositionComponent(
      size: Vector2(game.size.x, game.size.y),
    );
    add(_contentContainer);

    _buildContent();
  }

  void _buildContent() {
    _contentContainer.removeAll(_contentContainer.children);

    final availableWidth = game.size.x;
    final availableHeight = game.size.y;
    final contentWidth = min(availableWidth - 32.0, 410.0);
    final centerX = availableWidth / 2.0;

    const headerHeight = 106.0;
    const footerMargin = 20.0;
    final isTallScreen = availableHeight >= 760.0;
    final folioHeight = isTallScreen ? 390.0 : 340.0;
    const buttonHeight = 68.0;
    const gap = 14.0;
    const footnoteHeight = 22.0;

    final totalHeight = folioHeight + gap + buttonHeight + 8.0 + footnoteHeight;
    final remainingSpace = availableHeight - headerHeight - footerMargin;
    final startY = headerHeight + max(12.0, (remainingSpace - totalHeight) / 2.0);

    // 1. Expedition Scroll / Folio
    final folio = _DailyExpeditionFolio(
      level: _todayLevel,
      position: Vector2(centerX - contentWidth / 2.0, startY),
      size: Vector2(contentWidth, folioHeight),
    );
    _contentContainer.add(folio);

    // 2. Start Expedition Action Button
    final buttonY = startY + folioHeight + gap;
    final startBtn = WoodButton(
      text: 'START EXPEDITION',
      secondaryText: 'ACCEPT CONTRACT & COMMENCE',
      position: Vector2(centerX - contentWidth / 2.0, buttonY),
      size: Vector2(contentWidth, buttonHeight),
      primaryColor: const Color(0xFFD48B3E), // Amber Gold
      isPrimary: true,
      isDaily: true,
      onPressed: () {
        if (_todayLevel != null) {
          game.pushScene(GameplayScene(level: _todayLevel!));
        }
      },
    );
    _contentContainer.add(startBtn);

    // 3. Subtext / Reassurance footnote
    final footnoteY = buttonY + buttonHeight + 8.0;
    final footnote = TextComponent(
      text: '⚡ Resets daily at 00:00 UTC • Play daily to preserve your streak',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFB59379),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(centerX, footnoteY),
    );
    _contentContainer.add(footnote);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;

    _bgComponent.size = size;
    _headerComponent.size = Vector2(size.x, 106);
    _contentContainer.size = size;
    _buildContent();
  }

  @override
  List<String> get activeOverlays => [];
}

/// Ambient spore mote for the living mahogany background.
class _Mote {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  _Mote({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

/// Warm mahogany radial vignette background with drifting golden spore particles.
class _DailyAtmosphericBackground extends PositionComponent {
  final List<_Mote> _motes = [];
  final Random _rng = Random();
  double _time = 0.0;

  _DailyAtmosphericBackground({required Vector2 size}) : super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (int i = 0; i < 18; i++) {
      _motes.add(
        _Mote(
          x: _rng.nextDouble() * size.x,
          y: _rng.nextDouble() * size.y,
          size: 1.5 + _rng.nextDouble() * 2.5,
          speed: 10.0 + _rng.nextDouble() * 16.0,
          opacity: 0.25 + _rng.nextDouble() * 0.45,
          phase: _rng.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    for (final mote in _motes) {
      mote.y -= mote.speed * dt;
      mote.x += sin(_time * 1.5 + mote.phase) * (dt * 8.0);
      if (mote.y < -10) {
        mote.y = size.y + 10;
        mote.x = _rng.nextDouble() * size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    // 1. Deep warm mahogany radial vignette
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.x / 2.0, size.y * 0.35),
        max(size.x, size.y) * 0.85,
        const [
          Color(0xFF352013), // Warm mahogany core
          Color(0xFF22130A), // Deep walnut mid
          Color(0xFF130904), // Vignette edge
        ],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // 2. Subtle cartographer compass rings
    final center = Offset(size.x / 2.0, size.y * 0.42);
    final ringRadius = min(size.x, size.y) * 0.36;
    final ringPaint = Paint()
      ..color = const Color(0xFFD48B3E).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, ringRadius, ringPaint);
    canvas.drawCircle(center, ringRadius * 0.65, ringPaint);

    // 3. Floating golden spore motes
    for (final mote in _motes) {
      final pulse = (sin(_time * 2.0 + mote.phase) * 0.2 + 0.8).clamp(0.0, 1.0);
      final motePaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: mote.opacity * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
      canvas.drawCircle(Offset(mote.x, mote.y), mote.size, motePaint);
    }
  }
}

/// Fixed top navigation canopy with notch clearance (46px+), tactile back button,
/// centered Wanderwood title typography, and countdown timer pill.
class _DailyHeaderComponent extends PositionComponent {
  final VoidCallback onBackPressed;
  final String title;
  final String subtitle;

  _DailyHeaderComponent({
    required this.onBackPressed,
    this.title = 'DAILY FORAGE',
    this.subtitle = 'EXPEDITION ARCHIVE',
    required Vector2 size,
  }) : super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const topInset = 46.0;

    // 1. Tactile Back Button
    final backBtn = _DailyBackButton(
      position: Vector2(16, topInset),
      size: Vector2(44, 44),
      onPressed: onBackPressed,
    );
    add(backBtn);

    // 2. Centered Title
    final centerX = size.x / 2.0;
    final titleComp = TextComponent(
      text: title.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF9EC),
          fontSize: 16.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          shadows: const [
            Shadow(
              color: Color(0xCC000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(centerX, topInset + 2),
    );
    add(titleComp);

    // 3. Subtitle
    final subtitleComp = TextComponent(
      text: subtitle.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFFFD166),
          fontSize: 10.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(centerX, topInset + 24),
    );
    add(subtitleComp);

    // 4. Timer badge pill on right
    const badgeWidth = 84.0;
    const badgeHeight = 32.0;
    final badgeLeft = size.x - badgeWidth - 16.0;
    final badgeTop = topInset + 6.0;

    final timerBadge = _DailyTimerBadgeComponent(
      position: Vector2(badgeLeft, badgeTop),
      size: Vector2(badgeWidth, badgeHeight),
    );
    add(timerBadge);
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    // Mahogany canopy gradient
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgGradient = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      const [
        Color(0xFF381F14), // Mahogany
        Color(0xFF26140B), // Walnut
        Color(0xFF190C06), // Deep base
      ],
      const [0.0, 0.7, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = bgGradient);

    // Bottom Rim Line (Amber / Brass)
    final rimPaint = Paint()
      ..color = const Color(0xFFD48B3E)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), rimPaint);

    // Subtle drop shadow under rim
    final shadowPaint = Paint()
      ..color = const Color(0x66000000)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawLine(Offset(0, size.y + 1.5), Offset(size.x, size.y + 1.5), shadowPaint);
  }
}

/// Circular tactile 3D back button with warm wood tones.
class _DailyBackButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  bool _isPressed = false;

  _DailyBackButton({
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
          fontSize: 22,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              color: Color(0x99000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
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

    final bgGradient = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      const [
        Color(0xFF4E3524),
        Color(0xFF332014),
      ],
    );
    canvas.drawRRect(rrect, Paint()..shader = bgGradient);

    final borderPaint = Paint()
      ..color = const Color(0xFFE5B048)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(rrect, borderPaint);

    if (_isPressed) {
      canvas.restore();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    onPressed();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}

/// Dynamic timer badge pill displaying time remaining until midnight UTC.
class _DailyTimerBadgeComponent extends PositionComponent {
  late TextComponent _text;
  double _elapsed = 0.0;

  _DailyTimerBadgeComponent({
    required super.position,
    required super.size,
  });

  String _formatTimeRemaining() {
    final now = DateTime.now().toUtc();
    final tomorrow = DateTime.utc(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final icon = TextComponent(
      text: '⏳',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 10),
      ),
      position: Vector2(7, size.y / 2),
      anchor: Anchor.centerLeft,
    );
    add(icon);

    _text = TextComponent(
      text: _formatTimeRemaining(),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFD54F),
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      position: Vector2(25, size.y / 2),
      anchor: Anchor.centerLeft,
    );
    add(_text);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= 30.0) {
      _elapsed = 0.0;
      _text.text = _formatTimeRemaining();
    }
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );

    // Drop shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 2)),
      Paint()..color = const Color(0x55000000),
    );

    // Dark walnut background
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF28170D));

    // Amber gold border
    final borderPaint = Paint()
      ..color = const Color(0xFFD48B3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(rrect, borderPaint);
  }
}

/// Ornate adventurer's expedition folio scroll.
///
/// Features:
/// - Drop shadow & carved wood frame with brass corner rivets
/// - Multi-layer warm parchment fill with subtle stitched border
/// - Header ribbon banner with daily challenge tier
/// - Big bold challenge title with narrative briefing
/// - Target schema intel pills (tables explored)
/// - 3-card bounty rewards banner (+250 Acorns, +100 EXP, +1 Streak)
class _DailyExpeditionFolio extends PositionComponent {
  final LevelModel? level;

  _DailyExpeditionFolio({
    required this.level,
    required super.position,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final contentWidth = size.x;
    var currentY = 32.0;

    // Challenge level number & cleaned title
    final levelNum = level?.levelNumber ?? 1;
    final rawTitle = level?.title ?? 'Daily Expedition';
    final cleanTitle = rawTitle.replaceFirst(RegExp(r'^Daily\s*#\d+:\s*', caseSensitive: false), '');

    // 1. Contract number pill text
    final contractBadge = TextComponent(
      text: 'CONTRACT #$levelNum • DAILY ARCHIVE'.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFB57428),
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(contentWidth / 2.0, currentY),
    );
    add(contractBadge);
    currentY += 20.0;

    // 2. Large Challenge Title
    final titleComp = TextBoxComponent(
      text: cleanTitle.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF2A160A),
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          height: 1.15,
        ),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: contentWidth - 44.0,
        growingBox: false,
      ),
      anchor: Anchor.topCenter,
      position: Vector2(contentWidth / 2.0, currentY),
    );
    add(titleComp);
    currentY += 46.0;

    // 3. Narrative Briefing
    final narrative = level?.narrative ?? 'A strange record anomaly was reported in the archives. Inspect the tables and reconstruct the missing query.';
    final descComp = TextBoxComponent(
      text: '“ $narrative ”',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFF5A3925),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.45,
          fontStyle: FontStyle.italic,
        ),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: contentWidth - 48.0,
        growingBox: false,
      ),
      anchor: Anchor.topCenter,
      position: Vector2(contentWidth / 2.0, currentY),
    );
    add(descComp);
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    // 1. Drop shadow
    final outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      outerRRect.shift(const Offset(0, 8)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 2. Carved Wood Plaque Border
    canvas.drawRRect(outerRRect, Paint()..color = const Color(0xFF4A2E1B));

    // 3. Inner Parchment Panel (Inset 5.5px)
    final parchmentRect = Rect.fromLTWH(5.5, 5.5, size.x - 11, size.y - 11);
    final parchmentRRect = RRect.fromRectAndRadius(parchmentRect, const Radius.circular(13));
    final parchmentShader = ui.Gradient.linear(
      parchmentRect.topCenter,
      parchmentRect.bottomCenter,
      const [
        Color(0xFFFFFBF2),
        Color(0xFFF7EED9),
        Color(0xFFEADFCA),
      ],
      const [0.0, 0.6, 1.0],
    );
    canvas.drawRRect(parchmentRRect, Paint()..shader = parchmentShader);

    // 4. Stitched Inner Border (dashed)
    final stitchRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(11, 11, size.x - 22, size.y - 22),
      const Radius.circular(9),
    );
    _drawDashedRRect(canvas, stitchRRect, const Color(0xFFC89C74));

    // 5. Four Corner Brass Rivets
    _drawBrassRivet(canvas, const Offset(14, 14));
    _drawBrassRivet(canvas, Offset(size.x - 14, 14));
    _drawBrassRivet(canvas, Offset(14, size.y - 14));
    _drawBrassRivet(canvas, Offset(size.x - 14, size.y - 14));

    // 6. Top Ribbon Seal Banner
    _drawRibbonSeal(canvas);

    // 7. Middle Divider: Target Schema Intel
    final intelY = size.y - 145.0;
    _drawOrnamentalDivider(canvas, intelY, 'TARGET TABLES');
    _drawSchemaPills(canvas, intelY + 14.0);

    // 8. Lower Divider: Expedition Bounties
    final rewardsY = size.y - 82.0;
    _drawOrnamentalDivider(canvas, rewardsY, 'EXPEDITION BOUNTIES');
    _drawBountyBadges(canvas, rewardsY + 13.0);
  }

  void _drawRibbonSeal(Canvas canvas) {
    const bannerWidth = 190.0;
    const bannerHeight = 22.0;
    final bannerLeft = (size.x - bannerWidth) / 2.0;
    const bannerTop = 4.0;

    final bannerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bannerLeft, bannerTop, bannerWidth, bannerHeight),
      const Radius.circular(11),
    );

    // Ribbon drop shadow
    canvas.drawRRect(
      bannerRRect.shift(const Offset(0, 1.5)),
      Paint()..color = const Color(0x33000000),
    );

    // Ribbon mahogany fill
    final ribbonShader = ui.Gradient.linear(
      Offset(bannerLeft, bannerTop),
      Offset(bannerLeft, bannerTop + bannerHeight),
      const [
        Color(0xFF6B2F1C),
        Color(0xFF4A1F12),
      ],
    );
    canvas.drawRRect(bannerRRect, Paint()..shader = ribbonShader);

    // Gold trim
    final trimPaint = Paint()
      ..color = const Color(0xFFE5B048)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawRRect(bannerRRect, trimPaint);

    // Ribbon label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '✦ EXPEDITION BRIEFING ✦',
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFE8B2),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        bannerLeft + (bannerWidth - textPainter.width) / 2.0,
        bannerTop + (bannerHeight - textPainter.height) / 2.0,
      ),
    );
  }

  void _drawBrassRivet(Canvas canvas, Offset center) {
    canvas.drawCircle(center + const Offset(0, 1), 4.2, Paint()..color = const Color(0x44000000));
    canvas.drawCircle(center, 3.8, Paint()..color = const Color(0xFFD49E3E));
    canvas.drawCircle(center - const Offset(0.8, 0.8), 1.6, Paint()..color = const Color(0xFFFFF2BF));
    canvas.drawCircle(center, 1.1, Paint()..color = const Color(0xFF3E2314));
  }

  void _drawOrnamentalDivider(Canvas canvas, double y, String label) {
    final centerX = size.x / 2.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF966848),
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textHalfW = textPainter.width / 2.0 + 8.0;

    final linePaint = Paint()
      ..color = const Color(0xFFD8B99D)
      ..strokeWidth = 1.0;

    // Left line
    canvas.drawLine(Offset(24, y), Offset(centerX - textHalfW, y), linePaint);
    // Right line
    canvas.drawLine(Offset(centerX + textHalfW, y), Offset(size.x - 24, y), linePaint);

    // Small amber diamond on each side
    final diamondPaint = Paint()..color = const Color(0xFFD48B3E);
    _drawDiamond(canvas, Offset(centerX - textHalfW - 3, y), 2.5, diamondPaint);
    _drawDiamond(canvas, Offset(centerX + textHalfW + 3, y), 2.5, diamondPaint);

    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2.0, y - textPainter.height / 2.0));
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSchemaPills(Canvas canvas, double y) {
    final tables = level?.schema.tables.map((t) => t.name).toList() ?? ['records'];
    final displayTables = tables.take(3).toList();

    const pillH = 26.0;
    final totalW = size.x - 40.0;
    final pillW = (totalW - (displayTables.length - 1) * 8.0) / displayTables.length;

    for (int i = 0; i < displayTables.length; i++) {
      final pillLeft = 20.0 + i * (pillW + 8.0);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillLeft, y, pillW, pillH),
        const Radius.circular(8),
      );

      // Pill background
      canvas.drawRRect(rrect, Paint()..color = const Color(0xFFE4D5BC));
      // Subtle border
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFBA8F69)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: '📜 ${displayTables[i]}',
          style: GoogleFonts.nunitoSans(
            color: const Color(0xFF381F12),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: pillW - 8.0);

      tp.paint(
        canvas,
        Offset(
          pillLeft + (pillW - tp.width) / 2.0,
          y + (pillH - tp.height) / 2.0,
        ),
      );
    }
  }

  void _drawBountyBadges(Canvas canvas, double y) {
    final badges = [
      {'icon': '🌰', 'val': '+250', 'label': 'ACORNS'},
      {'icon': '⚡', 'val': '+100', 'label': 'EXP'},
      {'icon': '🔥', 'val': '+1', 'label': 'STREAK'},
    ];

    const cardH = 46.0;
    final totalW = size.x - 40.0;
    final cardW = (totalW - (badges.length - 1) * 8.0) / badges.length;

    for (int i = 0; i < badges.length; i++) {
      final cardLeft = 20.0 + i * (cardW + 8.0);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cardLeft, y, cardW, cardH),
        const Radius.circular(10),
      );

      // Card drop shadow
      canvas.drawRRect(
        rrect.shift(const Offset(0, 1.5)),
        Paint()..color = const Color(0x22000000),
      );

      // Walnut & amber pill fill
      canvas.drawRRect(rrect, Paint()..color = const Color(0xFF3A2114));

      // Gold border
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFD48B3E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Value & Icon (Row 1)
      final valTp = TextPainter(
        text: TextSpan(
          text: '${badges[i]['icon']} ${badges[i]['val']}',
          style: GoogleFonts.nunitoSans(
            color: const Color(0xFFFFD54F),
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      valTp.paint(
        canvas,
        Offset(
          cardLeft + (cardW - valTp.width) / 2.0,
          y + 7.0,
        ),
      );

      // Sub-label (Row 2)
      final lblTp = TextPainter(
        text: TextSpan(
          text: badges[i]['label']!,
          style: GoogleFonts.quicksand(
            color: const Color(0xFFD8BA9F),
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      lblTp.paint(
        canvas,
        Offset(
          cardLeft + (cardW - lblTp.width) / 2.0,
          y + 25.0,
        ),
      );
    }
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Color color) {
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    const dashWidth = 5.0;
    const dashSpace = 5.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          final extractPath = metric.extractPath(distance, distance + length);
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }
}
