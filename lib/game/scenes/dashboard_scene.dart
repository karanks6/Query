import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../features/dashboard/widgets/streak_calendar_modal.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../components/ui/game_stat_badge.dart';
import 'query_scene.dart';
import 'world_select_scene.dart';
import 'daily_challenge_scene.dart';
import '../components/persistent_hud.dart';
import '../components/ui/wood_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers.dart';
import '../../data/content/level_loader.dart';

class LayoutContainer extends PositionComponent with RiverpodComponentMixin {}

class DashboardScene extends QueryScene with RiverpodComponentMixin {
  late PersistentHudComponent hud;
  late LayoutContainer layoutContainer;
  late _AnimatedDashboardBackground _bg;
  
  String currentWorldId = 'world_01';
  String currentWorldTitle = 'Archive Vaults';
  int currentWorldNumber = 1;

  dynamic _currentPlayerProfile;
  int _achievementsCount = 0;
  _StatsRowComponent? _statsRow;

  @override
  Future<void> onLoad() async { 
    // 1. Living animated atmospheric background with floating golden spores
    _bg = _AnimatedDashboardBackground()..size = game.size;
    add(_bg);
    
    // 2. High-end carved Persistent HUD with rotating brass clockwork gear
    hud = PersistentHudComponent();
    add(hud);

    layoutContainer = LayoutContainer()
      ..size = Vector2(game.size.x, game.size.y - 100)
      ..position = Vector2(0, 105);
    add(layoutContainer);

    try {
      final prefs = await SharedPreferences.getInstance();
      final playerDao = ref.read(playerDaoProvider);
      await playerDao.checkDailyStreak(prefs, increment: false);

      final profile = await ref.read(playerProfileProvider.future);
      _currentPlayerProfile = profile;
      
      final achList = await ref.read(allAchievementsProvider.future);
      _achievementsCount = achList.length;
      
      final progressList = await ref.read(allWorldProgressProvider.future);
      String highestUnlocked = 'world_01';
      for (final p in progressList) {
        if (p.unlocked && p.worldId.compareTo(highestUnlocked) > 0) {
          highestUnlocked = p.worldId;
        }
      }
      
      currentWorldId = highestUnlocked;
      final worldData = await LevelLoader.instance.loadWorld(currentWorldId);
      currentWorldTitle = worldData.title;
      currentWorldNumber = worldData.number;

    } catch (e, st) {
      debugPrint('DASHBOARD SCENE ONLOAD ERROR: $e\n$st');
    }

    _buildLayout();
  }

  ProviderSubscription? _profileSub;

  @override
  void onMount() {
    super.onMount();
    _profileSub = ref.listenManual(
      playerProfileProvider,
      (previous, next) {
        if (next.hasValue && next.value != null) {
          _currentPlayerProfile = next.value;
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void onRemove() {
    _profileSub?.close();
    super.onRemove();
  }

  void _buildLayout() { 
    try {
      final availableWidth = game.size.x;
      final availableHeight = game.size.y - 105;
      final contentWidth = availableWidth > 440 ? 400.0 : availableWidth - 32;
      final centerX = availableWidth / 2;
      
      // Dynamic vertical scaling to ensure comfortable proportions on any mobile device
      final isCompact = availableHeight < 680;
      var yPos = isCompact ? 4.0 : 8.0;

      // ─── 1. WANDERWOOD Plaque with Hover & Shimmer ─────────────────────────
      final plaqueWidth = contentWidth * 0.85;
      final plaqueHeight = isCompact ? 52.0 : 58.0;
      
      final plaque = _AnimatedWanderwoodPlaque(
        size: Vector2(plaqueWidth, plaqueHeight),
        position: Vector2(centerX - plaqueWidth / 2, yPos),
      );
      layoutContainer.add(plaque);
      yPos += plaqueHeight + (isCompact ? 10 : 12);

      // ─── 2. Tactical Stats Row (Streak, Badges, XP) ────────────────────────
      final statsHeight = isCompact ? 48.0 : 52.0;
      _statsRow = _StatsRowComponent(
        profile: _currentPlayerProfile,
        initialAchievements: _achievementsCount,
        size: Vector2(contentWidth, statsHeight),
        position: Vector2(centerX - contentWidth / 2, yPos),
      );
      layoutContainer.add(_statsRow!);
      yPos += statsHeight + (isCompact ? 10 : 12);

      // ─── 3. Expedition Codex Folio (Living Artwork & Journey Track) ────────
      final illusWidth = contentWidth - 28;
      final illusHeight = isCompact 
          ? (illusWidth * 0.52).clamp(135.0, 160.0) 
          : (illusWidth * 0.62).clamp(160.0, 205.0);
      
      final headerH = 38.0;
      final trackerH = 26.0;
      final specimenH = isCompact ? 32.0 : 36.0;
      final folioHeight = headerH + illusHeight + 8 + trackerH + 8 + specimenH + 12;
      
      final folio = _ExpeditionCodexFolio(
        size: Vector2(contentWidth, folioHeight),
        position: Vector2(centerX - contentWidth / 2, yPos),
        currentWorldId: currentWorldId,
        currentWorldNumber: currentWorldNumber,
        currentWorldTitle: currentWorldTitle,
        illusWidth: illusWidth,
        illusHeight: illusHeight,
      );
      layoutContainer.add(folio);
      yPos += folioHeight + (isCompact ? 10 : 14);

      // ─── 4. High-End Animated Action Buttons ──────────────────────────────
      final btnHeight = isCompact ? 56.0 : 64.0;
      
      final continueBtn = WoodButton(
        text: 'CONTINUE',
        secondaryText: 'Stage 3-4 · The Whispering Brook',
        isPrimary: true,
        position: Vector2(centerX - contentWidth / 2, yPos),
        size: Vector2(contentWidth, btnHeight),
        primaryColor: const Color(0xFF2E6F4B), // Forest Green
        onPressed: () {
          game.pushScene(WorldSelectScene());
        },
      );
      layoutContainer.add(continueBtn);
      yPos += btnHeight + (isCompact ? 8 : 12);

      final dailyBtn = WoodButton(
        text: 'DAILY FORAGE',
        secondaryText: 'Ends in 05h 22m',
        isDaily: true,
        position: Vector2(centerX - contentWidth / 2, yPos),
        size: Vector2(contentWidth, btnHeight),
        primaryColor: const Color(0xFFD48B3E), // Warm Amber
        onPressed: () {
          game.pushScene(DailyChallengeScene());
        },
      );
      layoutContainer.add(dailyBtn);

    } catch (e, st) {
      final errorComp = TextComponent(
        text: 'Error in _buildLayout:\n$e\n$st',
        position: Vector2(10, 100),
        textRenderer: TextPaint(style: const TextStyle(color: Colors.red, fontSize: 10)),
      );
      layoutContainer.add(errorComp);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded && _bg.isMounted) {
      _bg.size = size;
    }
    if (isLoaded && layoutContainer.isMounted) {
       layoutContainer.size = Vector2(size.x, size.y - 100);
    }
  }

  @override
  List<String> get activeOverlays => [];
}

// ════════════════════════════════════════════════════════════════════════════
// 1. LIVING ANIMATED DASHBOARD BACKGROUND (WARM VIGNETTE & FLOATING SPORES)
// ════════════════════════════════════════════════════════════════════════════
class _AnimatedDashboardBackground extends PositionComponent {
  final List<_SporeParticle> _spores = [];
  final Random _rnd = Random();

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 20; i++) {
      _spores.add(_SporeParticle(
        x: _rnd.nextDouble() * (size.x > 0 ? size.x : 400),
        y: _rnd.nextDouble() * (size.y > 0 ? size.y : 800),
        size: 1.5 + _rnd.nextDouble() * 2.5,
        speedY: 10.0 + _rnd.nextDouble() * 16.0,
        swaySpeed: 1.2 + _rnd.nextDouble() * 2.0,
        swayAmp: 10.0 + _rnd.nextDouble() * 16.0,
        baseAlpha: 0.18 + _rnd.nextDouble() * 0.45,
        color: _rnd.nextBool()
            ? const Color(0xFFFFD54F) // Amber gold
            : const Color(0xFFF9F5EA), // Warm parchment spore
        phase: _rnd.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final curW = size.x > 0 ? size.x : 400;
    final curH = size.y > 0 ? size.y : 800;

    for (final s in _spores) {
      s.y -= s.speedY * dt;
      s.phase += s.swaySpeed * dt;
      if (s.y < -12) {
        s.y = curH + 12;
        s.x = _rnd.nextDouble() * curW;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    // Warm radial vignette - dark mahogany cartographer table
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.x * 0.5, size.y * 0.42),
        size.y * 0.72,
        [
          const Color(0xFF4A301D), // Warm mahogany core
          const Color(0xFF331F12), // Deep walnut mid
          const Color(0xFF1A0E06), // Shadow timber edge
        ],
        [0.0, 0.65, 1.0],
      );
    canvas.drawRect(rect, bgPaint);

    // Subtle grain lines
    final linePaint = Paint()
      ..color = const Color(0xFFDFD1B8).withValues(alpha: 0.03)
      ..strokeWidth = 1.0;
    for (double y = 40; y < size.y; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), linePaint);
    }

    // Floating golden spores / fireflies
    for (final s in _spores) {
      final curX = s.x + sin(s.phase) * s.swayAmp;
      final curAlpha = s.baseAlpha * (0.6 + 0.4 * sin(s.phase * 1.5));
      final pPaint = Paint()
        ..color = s.color.withValues(alpha: curAlpha.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(Offset(curX, s.y), s.size, pPaint);

      // Core sparkle
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: (curAlpha * 0.75).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(curX, s.y), s.size * 0.4, corePaint);
    }
  }
}

class _SporeParticle {
  double x;
  double y;
  final double size;
  final double speedY;
  final double swaySpeed;
  final double swayAmp;
  final double baseAlpha;
  final Color color;
  double phase;

  _SporeParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.swaySpeed,
    required this.swayAmp,
    required this.baseAlpha,
    required this.color,
    required this.phase,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// 2. ORNATE CARVED WANDERWOOD PLAQUE (HOVERING, GLOWING, EMBOSSED)
// ════════════════════════════════════════════════════════════════════════════
class _AnimatedWanderwoodPlaque extends PositionComponent {
  double _time = 0;

  _AnimatedWanderwoodPlaque({super.size, super.position});

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    // Subtle gentle sine wave hover float
    final hoverY = sin(_time * 2.2) * 1.5;
    canvas.save();
    canvas.translate(0, hoverY);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 5, size.x, size.y), const Radius.circular(16)),
      Paint()..color = const Color(0x66000000),
    );

    // Main carved wood gradient
    final woodPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.y),
        [
          const Color(0xFF6B422A), // Top bevel highlight
          const Color(0xFF4E2C19), // Rich mahogany body
          const Color(0xFF2C160B), // Deep carved base
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRRect(rrect, woodPaint);

    // Beveled antique brass border with corner accents
    final borderPaint = Paint()
      ..color = const Color(0xFFE59B28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Inner gold hairline rim
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.x - 8, size.y - 8),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Corner rivet dots
    final rivetPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(const Offset(8, 8), 1.8, rivetPaint);
    canvas.drawCircle(Offset(size.x - 8, 8), 1.8, rivetPaint);
    canvas.drawCircle(Offset(8, size.y - 8), 1.8, rivetPaint);
    canvas.drawCircle(Offset(size.x - 8, size.y - 8), 1.8, rivetPaint);

    // Periodic diagonal golden gleam sweep
    final shimmerProgress = (_time % 3.6) / 3.6;
    if (shimmerProgress < 0.32) {
      final sT = shimmerProgress / 0.32;
      final shimmerX = -40 + sT * (size.x + 80);
      final shimmerPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(shimmerX - 30, 0),
          Offset(shimmerX + 30, size.y),
          [
            Colors.transparent,
            const Color(0xFFFFD54F).withValues(alpha: 0.22),
            Colors.transparent,
          ],
        );
      canvas.save();
      canvas.clipRRect(innerRRect);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), shimmerPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Embossed Title
    final title = TextComponent(
      text: 'WANDERWOOD',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF7EA),
          fontSize: size.y > 54 ? 22 : 19,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.5,
          shadows: [
            const Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 4),
            const Shadow(color: Color(0x66E59B28), offset: Offset(0, 1), blurRadius: 6),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.40),
    );
    add(title);

    // 2. Subtitle Ribbon
    final subTitle = TextComponent(
      text: '✦  T A L E S   O F   T H E   W I L D  ✦',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFFFD54F),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.78),
    );
    add(subTitle);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 3. STATS ROW COMPONENT WITH INTERACTIVE BADGES
// ════════════════════════════════════════════════════════════════════════════
class _StatsRowComponent extends PositionComponent with RiverpodComponentMixin {
  late GameStatBadge _streakBadge;
  late GameStatBadge _achBadge;
  late GameStatBadge _xpBadge;

  dynamic profile;
  final int? initialAchievements;

  _StatsRowComponent({
    this.profile,
    this.initialAchievements,
    required super.size,
    required super.position,
  });

  void _refreshStats({int? streak, int? xp, int? achievements}) {
    if (streak != null) _streakBadge.value = streak;
    if (xp != null) _xpBadge.value = xp;
    if (achievements != null) _achBadge.value = achievements;
  }

  @override
  Future<void> onLoad() async {
    const badgeGap = 8.0;
    final badgeWidth = (size.x - (badgeGap * 2)) / 3;
    final badgeSize = Vector2(badgeWidth, size.y);

    final initialStreak = profile != null ? (profile.streakCount as int? ?? 0) : 0;
    final initialXp = profile != null ? (profile.totalXp as int? ?? 0) : 0;
    final initialAch = initialAchievements ?? 0;

    // 1. Streak Badge (Interactive + Dancing Flame & Rising Embers)
    _streakBadge = GameStatBadge(
      type: GameStatBadgeType.streak,
      initialValue: initialStreak,
      size: badgeSize,
      position: Vector2(0, 0),
      onPressed: () {
        if (navigatorKey.currentContext != null) {
          showModalBottomSheet(
            context: navigatorKey.currentContext!,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.85,
                  maxChildSize: 0.95,
                  minChildSize: 0.5,
                  builder: (_, controller) => StreakCalendarModal(
                    scrollController: controller,
                    profile: profile,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
    add(_streakBadge);

    // 2. Achievements Badge (Interactive + Floating Trophy & Stars)
    _achBadge = GameStatBadge(
      type: GameStatBadgeType.achievements,
      initialValue: initialAch,
      size: badgeSize,
      position: Vector2(badgeWidth + badgeGap, 0),
      onPressed: () {
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          );
        }
      },
    );
    add(_achBadge);

    // 3. XP Badge (Interactive + Pulsing Arcane Gem & Stardust)
    _xpBadge = GameStatBadge(
      type: GameStatBadgeType.xp,
      initialValue: initialXp,
      size: badgeSize,
      position: Vector2((badgeWidth + badgeGap) * 2, 0),
      onPressed: () {
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
    );
    add(_xpBadge);
  }

  ProviderSubscription? _profileSub;
  ProviderSubscription? _achSub;

  @override
  void onMount() {
    super.onMount();

    try {
      _profileSub = ref.listenManual(
        playerProfileProvider,
        (_, next) {
          if (next.hasValue && next.value != null) {
            profile = next.value;
            _refreshStats(
              streak: next.value!.streakCount,
              xp: next.value!.totalXp,
            );
          }
        },
        fireImmediately: true,
      );

      _achSub = ref.listenManual(
        allAchievementsProvider,
        (_, next) {
          if (next.hasValue && next.value != null) {
            _refreshStats(achievements: next.value!.length);
          }
        },
        fireImmediately: true,
      );
    } catch (e) {
      debugPrint('Error in _StatsRowComponent.onMount: $e');
    }
  }

  @override
  void onRemove() {
    _profileSub?.close();
    _achSub?.close();
    super.onRemove();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 4. EXPEDITION CODEX FOLIO (PARCHMENT, BRASS CORNERS, LIVING ATMOSPHERE)
// ════════════════════════════════════════════════════════════════════════════
class _ExpeditionCodexFolio extends PositionComponent {
  final String currentWorldId;
  final int currentWorldNumber;
  final String currentWorldTitle;
  final double illusWidth;
  final double illusHeight;

  _ExpeditionCodexFolio({
    required super.size,
    required super.position,
    required this.currentWorldId,
    required this.currentWorldNumber,
    required this.currentWorldTitle,
    required this.illusWidth,
    required this.illusHeight,
  });

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16.0),
    );

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 6, size.x, size.y), const Radius.circular(16.0)),
      Paint()..color = const Color(0x66000000),
    );

    // Warm parchment base
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.y),
        [
          const Color(0xFFFBF8EE), // Light ivory parchment
          const Color(0xFFF3EDDC),
          const Color(0xFFE9E0CB), // Aged parchment bottom
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(rrect, bgPaint);

    // Thick carved wood border
    final borderPaint = Paint()
      ..color = const Color(0xFF5C3D2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(rrect, borderPaint);

    // Stitched inner dashed border
    final stitchedRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 6, size.x - 12, size.y - 12),
      const Radius.circular(12.0),
    );
    final dashPaint = Paint()
      ..color = const Color(0xFFBA8869)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    _drawDashedRRect(canvas, stitchedRRect, dashPaint);

    // Brass corner bracket ornaments
    _drawBrassCorner(canvas, 3, 3, 0);
    _drawBrassCorner(canvas, size.x - 3, 3, pi / 2);
    _drawBrassCorner(canvas, size.x - 3, size.y - 3, pi);
    _drawBrassCorner(canvas, 3, size.y - 3, 3 * pi / 2);
  }

  void _drawBrassCorner(Canvas canvas, double x, double y, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    final bracketPaint = Paint()
      ..color = const Color(0xFFE59B28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final path = Path()
      ..moveTo(2, 14)
      ..lineTo(2, 2)
      ..lineTo(14, 2);
    canvas.drawPath(path, bracketPaint);
    canvas.drawCircle(const Offset(4, 4), 1.5, Paint()..color = const Color(0xFFFFD54F));
    canvas.restore();
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final Path path = Path()..addRRect(rrect);
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ─── Header: Expedition Codex + Realm Badge ──────────────────────────────
    final jTitle = TextComponent(
      text: '🧭 EXPEDITION CODEX',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF2A180E),
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      position: Vector2(16, 14),
    );
    add(jTitle);

    // Realm Pill Badge
    final realmBadge = _RealmBadgeComponent(
      position: Vector2(size.x - 16, 12),
    );
    add(realmBadge);

    // Decorative divider with center diamond
    add(_DividerLineComponent(
      position: Vector2(16, 36),
      lineWidth: size.x - 32,
    ));

    // ─── Illustration Container with Living Atmosphere ───────────────────────
    final illusBg = PositionComponent(
      size: Vector2(illusWidth, illusHeight),
      position: Vector2(14, 44),
    );
    add(illusBg);

    // Load sprite asynchronously
    Sprite.load('chapters/$currentWorldId.jpg').then((sprite) {
      if (!illusBg.isRemoved) {
        final srcW = 1024.0;
        final srcH = 1024.0 * (illusHeight / illusWidth);
        final srcY = (1024.0 - srcH) / 2;
        
        final spriteComp = SpriteComponent(
          sprite: Sprite(
            sprite.image,
            srcPosition: Vector2(0, srcY),
            srcSize: Vector2(srcW, srcH),
          ),
          size: Vector2(illusWidth, illusHeight),
          priority: 0,
        );
        illusBg.add(spriteComp);

        // Living forest atmosphere: floating light spores & mist over art
        illusBg.add(_IllustrationAtmosphereComponent(
          size: Vector2(illusWidth, illusHeight),
          currentWorldNumber: currentWorldNumber,
          currentWorldTitle: currentWorldTitle,
          priority: 2,
        ));
      }
    }).catchError((_) {
      // Fallback
    });

    // ─── Expedition Journey Track ────────────────────────────────────────────
    final trackY = 44 + illusHeight + 8;
    add(_ExpeditionJourneyTrack(
      position: Vector2(14, trackY),
      size: Vector2(illusWidth, 26),
    ));

    // ─── Botanical Specimen Strip (Replaces plain white box) ──────────────────
    final specY = trackY + 26 + 8;
    add(_BotanicalSpecimenBox(
      position: Vector2(14, specY),
      size: Vector2(illusWidth, 34),
    ));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 5. LIVING ATMOSPHERE OVERLAY ACROSS THE CHAPTER ARTWORK
// ════════════════════════════════════════════════════════════════════════════
class _IllustrationAtmosphereComponent extends PositionComponent {
  final int currentWorldNumber;
  final String currentWorldTitle;
  double _time = 0;
  final List<_LightMote> _motes = [];
  final Random _rnd = Random();

  _IllustrationAtmosphereComponent({
    required super.size,
    required super.priority,
    required this.currentWorldNumber,
    required this.currentWorldTitle,
  }) {
    for (int i = 0; i < 9; i++) {
      _motes.add(_LightMote(
        x: _rnd.nextDouble() * size.x,
        y: _rnd.nextDouble() * size.y,
        radius: 1.2 + _rnd.nextDouble() * 2.2,
        speedY: 6.0 + _rnd.nextDouble() * 10.0,
        phase: _rnd.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    for (final m in _motes) {
      m.y -= m.speedY * dt;
      m.phase += dt * 1.5;
      if (m.y < -5) {
        m.y = size.y + 5;
        m.x = _rnd.nextDouble() * size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    // 1. Subtle cinematic vignette rim
    final vignettePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.y),
        [
          Colors.black.withValues(alpha: 0.20),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.65),
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), vignettePaint);

    // 2. Beveled metallic frame border
    final borderPaint = Paint()
      ..color = const Color(0xFFE59B28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(8)),
      borderPaint,
    );

    // 3. Floating Light Motes over the forest
    for (final m in _motes) {
      final curX = m.x + sin(m.phase) * 8.0;
      final alpha = (0.25 + 0.25 * sin(m.phase)).clamp(0.0, 1.0);
      final pPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(Offset(curX, m.y), m.radius, pPaint);
    }

    // 4. Floating Chapter Location Banner Ribbon
    final bannerHeight = 28.0;
    final bannerY = size.y - bannerHeight;

    final bannerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, bannerY),
        Offset(0, size.y),
        [
          const Color(0xD9221108),
          const Color(0xF2120703),
        ],
      );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, bannerY, size.x, bannerHeight),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      bannerPaint,
    );

    // Pulsing Amber Waypoint Pin
    final pinPulse = (sin(_time * 3.5) * 1.5);
    final pinX = 14.0;
    final pinY = bannerY + bannerHeight * 0.5;
    final pinPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(pinX, pinY), 3.5 + pinPulse * 0.4, pinPaint);
    canvas.drawCircle(Offset(pinX, pinY), 6.5, Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.25));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Chapter Location Text
    final bannerHeight = 28.0;
    final bannerY = size.y - bannerHeight;

    final locationText = TextComponent(
      text: 'Chapter $currentWorldNumber: $currentWorldTitle',
      position: Vector2(26, bannerY + 5),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF7EA),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          shadows: [
            const Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
      ),
    );
    add(locationText);
  }
}

class _LightMote {
  double x;
  double y;
  final double radius;
  final double speedY;
  double phase;

  _LightMote({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedY,
    required this.phase,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// 6. EXPEDITION JOURNEY TRACK & PROGRESS NODES
// ════════════════════════════════════════════════════════════════════════════
class _ExpeditionJourneyTrack extends PositionComponent {
  double _time = 0;

  _ExpeditionJourneyTrack({required super.position, required super.size});

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8),
    );

    // Dark parchment track fill
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFE5DBC7));

    // Rail border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFC4B59D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Progress bar fill (3 of 5 nodes = 60%)
    final progressW = size.x * 0.55;
    final progRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, progressW, size.y),
      const Radius.circular(8),
    );
    final progPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(progressW, 0),
        [
          const Color(0xFF4A7C59), // Emerald start
          const Color(0xFFE59B28), // Amber gold lead
        ],
      );
    canvas.drawRRect(progRRect, progPaint);

    // 5 Waypoint Nodes along the track
    final nodeCount = 5;
    for (int i = 0; i < nodeCount; i++) {
      final nodeX = 16.0 + i * ((size.x - 32.0) / (nodeCount - 1));
      final nodeY = size.y * 0.5;
      final isCleared = i < 2;
      final isCurrent = i == 2;

      if (isCurrent) {
        // Pulsing active node
        final pulse = sin(_time * 4.0) * 1.5;
        canvas.drawCircle(Offset(nodeX, nodeY), 5.5 + pulse * 0.4, Paint()..color = const Color(0xFFFFD54F));
        canvas.drawCircle(Offset(nodeX, nodeY), 8.5, Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.3));
        canvas.drawCircle(Offset(nodeX, nodeY), 2.5, Paint()..color = const Color(0xFF1F1209));
      } else if (isCleared) {
        canvas.drawCircle(Offset(nodeX, nodeY), 4.5, Paint()..color = const Color(0xFFFFF7EA));
        canvas.drawCircle(Offset(nodeX, nodeY), 2.0, Paint()..color = const Color(0xFF2E6F4B));
      } else {
        canvas.drawCircle(Offset(nodeX, nodeY), 3.5, Paint()..color = const Color(0xFF8C7A6B));
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final label = TextComponent(
      text: 'STAGE 3 OF 15 COMPLETED',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF7EA),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          shadows: [
            const Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
      ),
      position: Vector2(16, 6),
    );
    add(label);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 7. BOTANICAL SPECIMEN DISCOVERY BOX (ILLUMINATED FIELD NOTE)
// ════════════════════════════════════════════════════════════════════════════
class _BotanicalSpecimenBox extends PositionComponent {
  double _time = 0;

  _BotanicalSpecimenBox({required super.position, required super.size});

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8),
    );

    // Antique field note parchment container
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.y),
        [
          const Color(0xFFF9F5EA),
          const Color(0xFFEDE4CE),
        ],
      );
    canvas.drawRRect(rrect, bgPaint);

    // Beveled amber-wood border
    final borderPaint = Paint()
      ..color = const Color(0xFFBA8869)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, borderPaint);

    // Specimen rarity pill on the right
    final pillW = 82.0;
    final pillH = 20.0;
    final pillX = size.x - pillW - 8.0;
    final pillY = (size.y - pillH) / 2;

    final pillRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillX, pillY, pillW, pillH),
      const Radius.circular(6),
    );
    final pillPaint = Paint()..color = const Color(0xFF26593B);
    canvas.drawRRect(pillRRect, pillPaint);
    canvas.drawRRect(pillRRect, Paint()..color = const Color(0xFF48BB78)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Shimmer gleam across specimen box
    final sCycle = (_time % 4.0) / 4.0;
    if (sCycle < 0.25) {
      final sX = -30.0 + (sCycle / 0.25) * (size.x + 60.0);
      final sPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(sX - 20, 0),
          Offset(sX + 20, size.y),
          [
            Colors.transparent,
            const Color(0xFFFFD54F).withValues(alpha: 0.20),
            Colors.transparent,
          ],
        );
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), sPaint);
      canvas.restore();
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Specimen Name
    final specimenText = TextComponent(
      text: '🌿 FLORA: Golden Morel',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF381F12),
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      position: Vector2(10, 8),
    );
    add(specimenText);

    // Rarity Text inside Pill
    final rarityText = TextComponent(
      text: '⭐ RARE FIND',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFE6FFFA),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
      position: Vector2(size.x - 76, 9.5),
    );
    add(rarityText);
  }
}

// ─── Small UI Helpers ────────────────────────────────────────────────────────
class _RealmBadgeComponent extends PositionComponent {
  _RealmBadgeComponent({required super.position});

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-120, 0, 120, 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF26593B));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFE59B28)..style = PaintingStyle.stroke..strokeWidth = 0.8);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final text = TextComponent(
      text: 'ACT I · MISTY VALE',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF7EA),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      position: Vector2(-108, 3.5),
    );
    add(text);
  }
}

class _DividerLineComponent extends PositionComponent {
  final double lineWidth;

  _DividerLineComponent({required super.position, required this.lineWidth});

  @override
  void render(Canvas canvas) {
    final linePaint = Paint()
      ..color = const Color(0xFFDFD1B8)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset.zero, Offset(lineWidth, 0), linePaint);

    // Center Gold Diamond
    final midX = lineWidth / 2;
    final dPath = Path()
      ..moveTo(midX, -3)
      ..lineTo(midX + 4, 0)
      ..lineTo(midX, 3)
      ..lineTo(midX - 4, 0)
      ..close();
    canvas.drawPath(dPath, Paint()..color = const Color(0xFFE59B28));
  }
}
