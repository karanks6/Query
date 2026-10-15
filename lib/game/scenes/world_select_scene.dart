import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide Image;

import 'query_scene.dart';
import 'level_map_scene.dart';
import '../components/ui/flowing_river_component.dart';
import '../components/ui/world_node_component.dart';
import '../components/ui/world_select_header_component.dart';
import '../../data/content/level_loader.dart';
import '../../data/content/models/level_model.dart';
import '../../data/local/daos/progress_dao.dart';
import '../../data/local/app_database.dart';
import '../../core/providers.dart';

/// Soft, animated adventure game World Select Scene.
///
/// Features:
/// - Naturally curving meandering river connecting all world expedition nodes
/// - Soft animated game tablets (Zelda/Ori/Genshin style) matching warm app nature theme
/// - Fixed top HUD with comfortable 46px+ safe status bar spacing
/// - Reactive progress tracking for completed stages and star counts
/// - Responsive serpentine layout ensuring smooth scrolling without overflow
class WorldSelectScene extends QueryScene with RiverpodComponentMixin, DragCallbacks {
  late PositionComponent scrollContainer;
  late FlowingRiverComponent riverComponent;
  WorldSelectHeaderComponent? headerComponent;
  RectangleComponent? _overlayComponent;

  final List<WorldNodeComponent> _worldNodes = [];
  final Map<String, WorldModel> _loadedWorlds = {};

  double _scrollY = 0;
  double _maxScroll = 0;
  bool _needsRefresh = false;

  @override
  bool containsLocalPoint(Vector2 point) => true;

  ProgressDao? _resolveProgressDao() {
    try {
      if (isMounted) return ref.read(progressDaoProvider);
    } catch (_) {}
    try {
      return game.ref.read(progressDaoProvider);
    } catch (_) {}
    return null;
  }

  @override
  Future<void> onLoad() async {
    // 1. Parallax jungle background with soft forest vignette
    try {
      final bg = await ParallaxComponent.load(
        [ParallaxImageData("jungle_pattern.jpg")],
        baseVelocity: Vector2(0, -3),
        repeat: ImageRepeat.repeat,
      );
      bg.size = game.size;
      add(bg);
    } catch (_) {}

    _overlayComponent = RectangleComponent(
      size: game.size,
      paint: Paint()..color = const Color(0xC70E1A17), // Rich soft forest shadow
    );
    add(_overlayComponent!);

    // 2. Scroll Container for interactive world content
    scrollContainer = PositionComponent(size: game.size);
    add(scrollContainer);

    // 3. Flowing River Component (renders underneath world cards)
    riverComponent = FlowingRiverComponent();
    scrollContainer.add(riverComponent);

    // 4. Preload available worlds metadata
    final availableWorlds = LevelLoader.instance.availableWorlds;
    for (final worldId in availableWorlds) {
      try {
        final world = await LevelLoader.instance.loadWorld(worldId);
        _loadedWorlds[worldId] = world;
      } catch (_) {}
    }

    // 5. Query Player World & Level Progress
    final worldProgressMap = <String, WorldProgressData>{};
    final allComps = <LevelCompletion>[];
    try {
      final progressDao = _resolveProgressDao();
      if (progressDao != null) {
        final wpList = await progressDao.getAllWorldProgress();
        for (final wp in wpList) {
          worldProgressMap[wp.worldId] = wp;
        }
        final comps = await progressDao.getAllLevelCompletions();
        allComps.addAll(comps);
      }
    } catch (e) {
      debugPrint('[WorldSelectScene] Progress lookup skipped: $e');
    }

    // 6. Build Serpentine Alternating Layout for World Nodes
    final screenWidth = game.size.x > 0 ? game.size.x : 360.0;
    const margin = 14.0;
    const nodeHeight = 76.0;

    const startY = 135.0; // Safe clearance below the 106px fixed top header
    const worldSpacing = 135.0;

    final riverPoints = <Vector2>[];
    riverPoints.add(Vector2(screenWidth / 2.0, startY - 45.0));

    _worldNodes.clear();

    // Determine current active world
    String? currentActiveWorldId;
    for (int i = 0; i < availableWorlds.length; i++) {
      final wid = availableWorlds[i];
      final wp = worldProgressMap[wid];
      final isUnlocked = i == 0 || (wp?.unlocked ?? false);
      final isCompleted = (wp?.levelsCompleted ?? 0) >= (wp?.totalLevels ?? (_loadedWorlds[wid]?.totalLevels ?? 15));
      if (isUnlocked && !isCompleted) {
        currentActiveWorldId = wid;
        break;
      }
    }
    currentActiveWorldId ??= availableWorlds.isNotEmpty ? availableWorlds.first : null;

    int totalEarnedStarsAcrossAll = 0;
    int totalUnlockedWorldsCount = 0;

    for (int i = 0; i < availableWorlds.length; i++) {
      final worldId = availableWorlds[i];
      final isLeft = i % 2 == 0;
      final y = startY + (i * worldSpacing);

      final worldModel = _loadedWorlds[worldId];
      final wp = worldProgressMap[worldId];

      // Check unlock status: first world is always unlocked, or unlocked in DB, or previous world completed
      final prevWorldId = i > 0 ? availableWorlds[i - 1] : null;
      final prevWorldCompleted = prevWorldId != null &&
          ((worldProgressMap[prevWorldId]?.levelsCompleted ?? 0) >=
              (worldProgressMap[prevWorldId]?.totalLevels ?? (_loadedWorlds[prevWorldId]?.totalLevels ?? 15)));

      final isUnlocked = i == 0 || (wp?.unlocked ?? false) || prevWorldCompleted;
      if (isUnlocked) totalUnlockedWorldsCount++;

      final isCurrent = worldId == currentActiveWorldId;

      // Calculate stars earned in this world
      int worldStars = 0;
      int completedStagesInWorld = 0;
      for (final comp in allComps) {
        if (comp.levelId.startsWith('${worldId}_')) {
          worldStars += comp.starsEarned;
          completedStagesInWorld++;
        }
      }
      totalEarnedStarsAcrossAll += worldStars;

      final totalStages = worldModel?.totalLevels ?? (wp?.totalLevels ?? 15);
      final worldTitle = worldModel?.title ?? worldId.replaceAll('_', ' ');

      final subText = !isUnlocked
          ? 'CHAPTER ${i + 1}'
          : (totalStages > 0 && completedStagesInWorld >= totalStages
              ? 'CHAPTER ${i + 1} • EXPEDITION CLEAR'
              : (isCurrent ? 'CHAPTER ${i + 1} • EXPEDITION ACTIVE' : 'CHAPTER ${i + 1}'));

      final statusText = !isUnlocked
          ? '🔒 LOCKED'
          : (totalStages > 0 && completedStagesInWorld >= totalStages
              ? '★ $worldStars STARS • ALL CLEAR'
              : (completedStagesInWorld > 0
                  ? '★ $worldStars STARS • $completedStagesInWorld/$totalStages CLEARED'
                  : (isCurrent ? '▶ EXPLORE NOW' : '☆☆☆ UNLOCKED • $totalStages STAGES')));

      final nodeWidth = WorldNodeComponent.calculateRequiredWidth(
        title: worldTitle,
        subText: subText,
        statusText: statusText,
        screenWidth: screenWidth,
        margin: margin,
      );

      final x = isLeft ? margin : (screenWidth - nodeWidth - margin);

      final worldNode = WorldNodeComponent(
        worldNumber: i + 1,
        worldId: worldId,
        title: worldTitle,
        stagesCompleted: completedStagesInWorld,
        totalStages: totalStages,
        starsEarned: worldStars,
        isUnlocked: isUnlocked,
        isCurrent: isCurrent,
        isLeftAligned: isLeft,
        screenWidth: screenWidth,
        margin: margin,
        size: Vector2(nodeWidth, nodeHeight),
        position: Vector2(x, y),
        onPressed: () {
          game.pushScene(LevelMapScene(worldId: worldId));
        },
      );

      _worldNodes.add(worldNode);
      scrollContainer.add(worldNode);
      riverPoints.add(worldNode.riverAnchorPoint);
    }

    if (availableWorlds.isNotEmpty) {
      final lastY = startY + ((availableWorlds.length - 1) * worldSpacing) + nodeHeight;
      riverPoints.add(Vector2(screenWidth / 2.0, lastY + 75.0));
    }

    riverComponent.setPoints(riverPoints);

    final totalContentHeight = startY + (availableWorlds.length * worldSpacing) + 110.0;
    _maxScroll = totalContentHeight > game.size.y ? (totalContentHeight - game.size.y) : 0.0;

    // 7. Fixed Top HUD Header with comfortable safe status bar height (106px)
    headerComponent = WorldSelectHeaderComponent(
      title: 'WILD WOODS TRAIL',
      subtitle: 'CHOOSE EXPEDITION • ${availableWorlds.length} WORLDS',
      unlockedWorlds: totalUnlockedWorldsCount,
      totalWorlds: availableWorlds.length,
      earnedStars: totalEarnedStarsAcrossAll,
      onBackPressed: () => game.popScene(),
      size: Vector2(screenWidth, 106),
    );
    add(headerComponent!);
  }

  @override
  void onMount() {
    super.onMount();
    refreshProgress();
  }

  /// Re-evaluates world and stage progress when returning to world selection.
  Future<void> refreshProgress() async {
    if (_worldNodes.isEmpty) return;
    final availableWorlds = LevelLoader.instance.availableWorlds;

    final worldProgressMap = <String, WorldProgressData>{};
    final allComps = <LevelCompletion>[];

    try {
      final progressDao = _resolveProgressDao();
      if (progressDao != null) {
        final wpList = await progressDao.getAllWorldProgress();
        for (final wp in wpList) {
          worldProgressMap[wp.worldId] = wp;
        }
        final comps = await progressDao.getAllLevelCompletions();
        allComps.addAll(comps);
      }
    } catch (e) {
      debugPrint('[WorldSelectScene] Progress refresh error: $e');
    }

    // Determine current active world
    String? currentActiveWorldId;
    for (int i = 0; i < availableWorlds.length; i++) {
      final wid = availableWorlds[i];
      final wp = worldProgressMap[wid];
      final isUnlocked = i == 0 || (wp?.unlocked ?? false);
      final isCompleted = (wp?.levelsCompleted ?? 0) >= (wp?.totalLevels ?? (_loadedWorlds[wid]?.totalLevels ?? 15));
      if (isUnlocked && !isCompleted) {
        currentActiveWorldId = wid;
        break;
      }
    }
    currentActiveWorldId ??= availableWorlds.isNotEmpty ? availableWorlds.first : null;

    int totalEarnedStarsAcrossAll = 0;
    int totalUnlockedWorldsCount = 0;

    for (int i = 0; i < _worldNodes.length; i++) {
      if (i >= availableWorlds.length) break;
      final worldId = availableWorlds[i];
      final worldModel = _loadedWorlds[worldId];
      final wp = worldProgressMap[worldId];

      final prevWorldId = i > 0 ? availableWorlds[i - 1] : null;
      final prevWorldCompleted = prevWorldId != null &&
          ((worldProgressMap[prevWorldId]?.levelsCompleted ?? 0) >=
              (worldProgressMap[prevWorldId]?.totalLevels ?? (_loadedWorlds[prevWorldId]?.totalLevels ?? 15)));

      final isUnlocked = i == 0 || (wp?.unlocked ?? false) || prevWorldCompleted;
      if (isUnlocked) totalUnlockedWorldsCount++;

      final isCurrent = worldId == currentActiveWorldId;

      int worldStars = 0;
      int completedStagesInWorld = 0;
      for (final comp in allComps) {
        if (comp.levelId.startsWith('${worldId}_')) {
          worldStars += comp.starsEarned;
          completedStagesInWorld++;
        }
      }
      totalEarnedStarsAcrossAll += worldStars;

      final totalStages = worldModel?.totalLevels ?? (wp?.totalLevels ?? 15);
      final worldTitle = worldModel?.title ?? worldId.replaceAll('_', ' ');

      _worldNodes[i].updateProgress(
        stagesCompleted: completedStagesInWorld,
        totalStages: totalStages,
        starsEarned: worldStars,
        isUnlocked: isUnlocked,
        isCurrent: isCurrent,
        newTitle: worldTitle,
      );
    }

    headerComponent?.updateStats(
      unlocked: totalUnlockedWorldsCount,
      total: availableWorlds.length,
      stars: totalEarnedStarsAcrossAll,
    );
  }

  @override
  Future<void> onEnter() async {
    await super.onEnter();
    _needsRefresh = true;
    await refreshProgress();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_needsRefresh) {
      _needsRefresh = false;
      refreshProgress();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_maxScroll <= 0) return;
    _scrollY += event.localDelta.y;
    _scrollY = _scrollY.clamp(-_maxScroll, 0.0);
    scrollContainer.position.y = _scrollY;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _overlayComponent?.size = size;
    headerComponent?.size = Vector2(size.x, 106);
  }
}
