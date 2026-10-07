import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/events.dart';
import '../../main.dart';
import '../../features/dashboard/widgets/streak_calendar_modal.dart';
import '../../features/achievements/achievements_screen.dart';
import 'query_scene.dart';
import 'world_select_scene.dart';
import 'daily_challenge_scene.dart';
import '../components/persistent_hud.dart';
import '../components/ui/wood_button.dart';
import '../components/ui/parchment_panel.dart';
import '../../core/providers.dart';
import '../../core/settings/settings_service.dart';
import '../../data/content/level_loader.dart';

class DashboardScene extends QueryScene with RiverpodComponentMixin {
  late PersistentHudComponent hud;
  late PositionComponent layoutContainer;
  
  String currentWorldId = 'world_01';
  String currentWorldTitle = 'Archive Vaults';
  int currentWorldNumber = 1;

  int initialStreak = 0;
  int initialXp = 0;
  int initialAchievements = 0;
  
  dynamic _currentPlayerProfile;
  _StatsRowComponent? _statsRow;

  @override
  Future<void> onLoad() async { 
    // Warm wood desk background (gradient-like via multiple rectangles or just solid)
    final bg = RectangleComponent(
      size: game.size,
      paint: Paint()..color = const Color(0xFF3D2817), // wood-800
    );
    add(bg);
    
    hud = PersistentHudComponent();
    add(hud);

    layoutContainer = PositionComponent(
      size: Vector2(game.size.x, game.size.y - 100), // account for top HUD
      position: Vector2(0, 110), // offset below HUD
    );
    add(layoutContainer);

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final playerDao = ref.read(playerDaoProvider);
      await playerDao.checkDailyStreak(prefs, increment: false);

      final profile = await ref.read(playerProfileProvider.future);
      _currentPlayerProfile = profile;
      if (profile != null) {
        initialStreak = profile.streakCount;
        initialXp = profile.totalXp;
      }
      
      final achList = await ref.read(allAchievementsProvider.future);
      initialAchievements = achList.length;
      
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

    } catch (e) {
      // Fallback or ignore
    }

    _buildLayout();
  }

  @override
  void onMount() {
    super.onMount();
    addToGameWidgetBuild(() {
      ref.listen(playerProfileProvider, (previous, next) {
        if (next.hasValue && next.value != null) {
          _statsRow?.updateStats(
            streak: next.value!.streakCount,
            xp: next.value!.totalXp,
          );
        }
      });
      
      ref.listen(allAchievementsProvider, (previous, next) {
        if (next.hasValue) {
          _statsRow?.updateStats(achievements: next.value!.length);
        }
      });
    });
  }

  void _buildLayout() { 
    final availableWidth = game.size.x;
    final contentWidth = availableWidth > 440 ? 400.0 : availableWidth - 32;
    final centerX = availableWidth / 2;
    var yPos = 10.0; // Start padding

    // 1. WANDERWOOD Plaque
    final plaqueWidth = contentWidth * 0.8;
    final plaqueHeight = 60.0;
    
    // Plaque background using a custom component for RRect
    final plaqueBg = _RoundedPlaqueComponent(
      size: Vector2(plaqueWidth, plaqueHeight),
      position: Vector2(centerX - plaqueWidth / 2, yPos),
    );

    final title = TextComponent(
      text: 'WANDERWOOD',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA),
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          shadows: [const Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 4)]
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(plaqueWidth / 2, plaqueHeight / 2 - 6),
    );
    plaqueBg.add(title);
    
    final subTitle = TextComponent(
      text: 'TALES OF THE WILD',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFE59B28), // amber-300 ish
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(plaqueWidth / 2, plaqueHeight - 14),
    );
    plaqueBg.add(subTitle);
    
    layoutContainer.add(plaqueBg);
    yPos += plaqueHeight + 16;

    // 1.5 Stats Row
    final statsHeight = 40.0;
    _statsRow = _StatsRowComponent(
      initialStreak: initialStreak,
      initialXp: initialXp,
      initialAchievements: initialAchievements,
      profile: _currentPlayerProfile,
      size: Vector2(contentWidth, statsHeight),
      position: Vector2(centerX - contentWidth / 2, yPos),
    );
    layoutContainer.add(_statsRow!);
    yPos += statsHeight + 16;

    // 2. EXPEDITION MAP (Journal Folio)
    final illusWidth = contentWidth - 32;
    final illusHeight = illusWidth * 0.8; // 5:4 aspect ratio
    final journalHeight = 50 + illusHeight + 10 + 40 + 16;
    
    final journal = ParchmentPanel(
      size: Vector2(contentWidth, journalHeight),
      position: Vector2(centerX - contentWidth / 2, yPos),
    );

    // Journal Content
    final jTitle = TextComponent(
      text: 'EXPEDITION MAP',
      textRenderer: TextPaint(style: GoogleFonts.nunitoSans(color: const Color(0xFF2A180E), fontSize: 14, fontWeight: FontWeight.w900)),
      position: Vector2(16, 16),
    );
    journal.add(jTitle);

    final jSubtitle = TextComponent(
      text: 'ACT I - MISTY VALE',
      textRenderer: TextPaint(style: GoogleFonts.publicSans(color: const Color(0xFF2D5A3A), fontSize: 10, fontWeight: FontWeight.bold)),
      position: Vector2(contentWidth - 16, 18),
      anchor: Anchor.topRight,
    );
    journal.add(jSubtitle);

    // Divider line
    journal.add(RectangleComponent(
      size: Vector2(contentWidth - 32, 1),
      position: Vector2(16, 40),
      paint: Paint()..color = const Color(0xFFDFD1B8),
    ));

    // Illustration placeholder
    final illusBg = RectangleComponent(
      size: Vector2(illusWidth, illusHeight),
      position: Vector2(16, 50),
      paint: Paint()..color = const Color(0xFFDFD1B8), // parchment-300
    );
    journal.add(illusBg);

    final textBg = RectangleComponent(
      size: Vector2(illusWidth, 30),
      position: Vector2(0, illusHeight - 30),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.5),
      priority: 1, // Draw on top of the image
    );
    illusBg.add(textBg);

    textBg.add(TextComponent(
      text: 'Chapter $currentWorldNumber: $currentWorldTitle',
      position: Vector2(10, 5),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA), 
          fontSize: 14, 
          fontWeight: FontWeight.bold,
        )
      ),
    ));

    // Load the image asynchronously and apply cropping
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
      }
    }).catchError((_) {
      // Fallback if image not found
    });

    // Discovery panel
    final discBg = RectangleComponent(
      size: Vector2(contentWidth - 32, 40),
      position: Vector2(16, 50 + illusHeight + 10),
      paint: Paint()..color = const Color(0xFFF9F5EA),
    );
    discBg.add(TextComponent(
      text: 'Flora Discovered: Golden Morel',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: GoogleFonts.publicSans(color: const Color(0xFF3D2817), fontSize: 12, fontWeight: FontWeight.w600)),
    ));
    journal.add(discBg);

    layoutContainer.add(journal); 
    yPos += journalHeight + 20;

    // 3. Action Buttons
    final btnWidth = contentWidth;
    final continueBtn = WoodButton(
      text: 'CONTINUE',
      secondaryText: 'Stage 3-4 - The Whispering Brook',
      position: Vector2(centerX - btnWidth / 2, yPos),
      size: Vector2(btnWidth, 70),
      primaryColor: const Color(0xFF4A7C59), // Forest Green
      onPressed: () {
        game.pushScene(WorldSelectScene());
      },
    );
    layoutContainer.add(continueBtn);
    yPos += 70 + 15;

    final dailyBtn = WoodButton(
      text: 'DAILY FORAGE',
      secondaryText: 'Ends in 05h 22m',
      position: Vector2(centerX - btnWidth / 2, yPos),
      size: Vector2(btnWidth, 70),
      primaryColor: const Color(0xFFD48B3E), // Amber
      onPressed: () {
        game.pushScene(DailyChallengeScene());
      },
    );
    layoutContainer.add(dailyBtn);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Adjust background
    for (final child in children) {
      if (child is RectangleComponent && child.paint.color == const Color(0xFF3D2817)) {
        child.size = size;
      }
    }
    
    // We can rebuild layout on resize for simplicity
    if (isLoaded) {
      layoutContainer.removeAll(layoutContainer.children);
      layoutContainer.size = Vector2(size.x, size.y - 100);
      _buildLayout();
    }
  }

  @override
  List<String> get activeOverlays => [];
}

class _RoundedPlaqueComponent extends PositionComponent {
  _RoundedPlaqueComponent({super.size, super.position});

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF5C3D2E));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE59B28).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }
}

class _StatsRowComponent extends PositionComponent {
  late TextComponent _streakText;
  late TextComponent _achText;
  late TextComponent _xpText;

  final int initialStreak;
  final int initialXp;
  final int initialAchievements;
  final dynamic profile;

  _StatsRowComponent({
    required this.initialStreak,
    required this.initialXp,
    required this.initialAchievements,
    this.profile,
    required super.size,
    required super.position,
  });

  void updateStats({int? streak, int? xp, int? achievements}) {
    if (streak != null) _streakText.text = '🔥 $streak';
    if (xp != null) _xpText.text = '✨ $xp XP';
    if (achievements != null) _achText.text = '🏆 $achievements';
  }

  @override
  Future<void> onLoad() async { 
    final bg = _RoundedPlaqueComponent(size: size);
    add(bg);

    final colWidth = size.x / 3;
    final textStyle = GoogleFonts.nunitoSans(
      color: const Color(0xFFF9F5EA),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    // Streak
    final streakBtn = _StatButton(
      size: Vector2(colWidth, size.y),
      position: Vector2(0, 0),
      onTap: () {
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
                  builder: (_, controller) => StreakCalendarModal(scrollController: controller, profile: profile),
                ),
              ),
            ),
          );
        }
      },
    );
    _streakText = TextComponent(
      text: '🔥 $initialStreak',
      textRenderer: TextPaint(style: textStyle),
      position: Vector2(10, size.y / 2),
      anchor: Anchor.centerLeft,
    );
    streakBtn.add(_streakText);
    add(streakBtn);

    // Divider 1
    add(RectangleComponent(
      size: Vector2(1, size.y - 16),
      position: Vector2(colWidth, 8),
      paint: Paint()..color = const Color(0xFF8B5A2B),
    ));

    // Achievements
    final achBtn = _StatButton(
      size: Vector2(colWidth, size.y),
      position: Vector2(colWidth, 0),
      onTap: () {
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          );
        }
      },
    );
    _achText = TextComponent(
      text: '🏆 $initialAchievements',
      textRenderer: TextPaint(style: textStyle),
      position: Vector2(colWidth * 0.5, size.y / 2),
      anchor: Anchor.center,
    );
    achBtn.add(_achText);
    add(achBtn);

    // Divider 2
    add(RectangleComponent(
      size: Vector2(1, size.y - 16),
      position: Vector2(colWidth * 2, 8),
      paint: Paint()..color = const Color(0xFF8B5A2B),
    ));

    // XP
    _xpText = TextComponent(
      text: '✨ $initialXp XP',
      textRenderer: TextPaint(style: textStyle),
      position: Vector2(colWidth * 2.5, size.y / 2),
      anchor: Anchor.center,
    );
    add(_xpText);
  }
}

class _StatButton extends PositionComponent with TapCallbacks {
  final VoidCallback? onTap;

  _StatButton({required super.size, required super.position, this.onTap});

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
    super.onTapDown(event);
  }
}




