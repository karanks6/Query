import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide Image;

import 'query_scene.dart';
import 'gameplay_scene.dart';
import '../components/ui/flowing_river_component.dart';
import '../components/ui/stage_node_component.dart';
import '../components/ui/level_map_header_component.dart';
import '../../data/content/level_loader.dart';
import '../../data/content/models/level_model.dart';
import '../../data/local/daos/progress_dao.dart';
import '../../core/providers.dart';

/// Soft, animated adventure game Level Map Scene.
///
/// Features:
/// - Naturally curving meandering river connecting all stages with moving water currents & foam
/// - Soft animated game tablets (Zelda/Ori/Genshin style) matching warm app nature theme
/// - Fixed top HUD with comfortable 46px+ safe spacing preventing notch/status bar collisions
/// - Reactive, bulletproof level unlocking on level completion
/// - Strictly clamped responsive layouts ensuring zero overflow
class LevelMapScene extends QueryScene with RiverpodComponentMixin, DragCallbacks {
  final String worldId;
  late PositionComponent scrollContainer;
  late FlowingRiverComponent riverComponent;
  LevelMapHeaderComponent? headerComponent;
  RectangleComponent? _overlayComponent;

  WorldModel? _world;
  final List<StageNodeComponent> _stageNodes = [];

  double _scrollY = 0;
  double _maxScroll = 0;
  bool _needsRefresh = false;

  LevelMapScene({required this.worldId});

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
    // 1. Parallax jungle background with soft warm vignette
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

    // 2. Scroll Container for interactive map content
    scrollContainer = PositionComponent(size: game.size);
    add(scrollContainer);

    // 3. Flowing River Component (renders underneath stage nodes)
    riverComponent = FlowingRiverComponent();
    scrollContainer.add(riverComponent);

    // 4. Load World Model
    try {
      _world = await LevelLoader.instance.loadWorld(worldId);
    } catch (e) {
      debugPrint('[LevelMapScene] Error loading worldId=$worldId: $e');
    }

    // Fallback normalization if world was not found
    if (_world == null) {
      for (final avail in LevelLoader.instance.availableWorlds) {
        if (worldId.startsWith(avail) || avail.startsWith(worldId)) {
          try {
            _world = await LevelLoader.instance.loadWorld(avail);
            break;
          } catch (_) {}
        }
      }
    }

    _world ??= await LevelLoader.instance.loadWorld('world_01');
    final world = _world!;

    // 5. Query Initial Player Progress
    final completedIds = <String>{};
    final starsMap = <String, int>{};
    int totalEarnedStars = 0;
    int levelsCompletedCount = 0;

    try {
      final progressDao = _resolveProgressDao();
      if (progressDao != null) {
        final allComps = await progressDao.getAllLevelCompletions();
        for (final comp in allComps) {
          completedIds.add(comp.levelId);
          starsMap[comp.levelId] = comp.starsEarned;
        }
        try {
          final byWorld = await progressDao.getCompletedLevelIds(world.id);
          completedIds.addAll(byWorld);
        } catch (_) {}
        try {
          final wp = await progressDao.getWorldProgress(world.id);
          if (wp != null) {
            levelsCompletedCount = wp.levelsCompleted;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[LevelMapScene] Progress lookup skipped: $e');
    }

    for (final lvl in world.levels) {
      if (starsMap.containsKey(lvl.id)) {
        totalEarnedStars += starsMap[lvl.id]!;
      }
    }

    // Determine active/current level
    String? currentLevelId;
    for (int i = 0; i < world.levels.length; i++) {
      final lvl = world.levels[i];
      final isCompleted = completedIds.contains(lvl.id) ||
          (starsMap[lvl.id] ?? 0) > 0 ||
          i < levelsCompletedCount;
      if (!isCompleted) {
        currentLevelId = lvl.id;
        break;
      }
    }
    currentLevelId ??= world.levels.isNotEmpty ? world.levels.last.id : null;

    // 6. Build Responsive Serpentine Layout for Stage Nodes
    final screenWidth = game.size.x > 0 ? game.size.x : 360.0;
    const margin = 14.0;
    const nodeHeight = 72.0;

    const startY = 135.0; // Safe clearance below the 106px fixed top header
    const stageSpacing = 125.0;

    final riverPoints = <Vector2>[];
    riverPoints.add(Vector2(screenWidth / 2.0, startY - 45.0));

    _stageNodes.clear();

    for (int i = 0; i < world.levels.length; i++) {
      final level = world.levels[i];
      final isLeft = i % 2 == 0;
      final y = startY + (i * stageSpacing);

      final isCompleted = completedIds.contains(level.id) ||
          (starsMap[level.id] ?? 0) > 0 ||
          i < levelsCompletedCount;

      final prevCompleted = i > 0 &&
          (completedIds.contains(world.levels[i - 1].id) ||
              (starsMap[world.levels[i - 1].id] ?? 0) > 0 ||
              (i - 1) < levelsCompletedCount);

      final isUnlocked = i == 0 ||
          i <= levelsCompletedCount ||
          isCompleted ||
          prevCompleted;

      final isCurrent = level.id == currentLevelId;
      final stars = starsMap[level.id] ?? 0;

      final subText = !isUnlocked
          ? 'STAGE ${i + 1}'
          : (isCurrent ? 'STAGE ${i + 1} • READY' : 'STAGE ${i + 1}');

      final statusText = !isUnlocked
          ? '🔒 LOCKED'
          : (stars == 3
              ? '★★★ CLEARED'
              : (stars == 2
                  ? '★★☆ CLEARED'
                  : (stars == 1 ? '★☆☆ CLEARED' : (isCurrent ? '▶ PLAY NOW' : '☆☆☆ UNLOCKED'))));

      final nodeWidth = StageNodeComponent.calculateRequiredWidth(
        title: level.title,
        subText: subText,
        statusText: statusText,
        screenWidth: screenWidth,
        margin: margin,
      );

      final x = isLeft ? margin : (screenWidth - nodeWidth - margin);

      final stageNode = StageNodeComponent(
        stageNumber: i + 1,
        title: level.title,
        stars: stars,
        isUnlocked: isUnlocked,
        isCurrent: isCurrent,
        isLeftAligned: isLeft,
        screenWidth: screenWidth,
        margin: margin,
        size: Vector2(nodeWidth, nodeHeight),
        position: Vector2(x, y),
        onPressed: () {
          game.pushScene(GameplayScene(level: level));
        },
      );

      _stageNodes.add(stageNode);
      scrollContainer.add(stageNode);
      riverPoints.add(stageNode.riverAnchorPoint);
    }

    if (world.levels.isNotEmpty) {
      final lastY = startY + ((world.levels.length - 1) * stageSpacing) + nodeHeight;
      riverPoints.add(Vector2(screenWidth / 2.0, lastY + 75.0));
    }

    riverComponent.setPoints(riverPoints);

    final totalContentHeight = startY + (world.levels.length * stageSpacing) + 110.0;
    _maxScroll = totalContentHeight > game.size.y ? (totalContentHeight - game.size.y) : 0.0;

    // 7. Fixed Top HUD Header with comfortable safe status bar height (106px)
    headerComponent = LevelMapHeaderComponent(
      worldTitle: world.title,
      worldSubtitle: 'Chapter ${world.number} • ${world.levels.length} Stages',
      earnedStars: totalEarnedStars,
      totalPossibleStars: world.levels.length * 3,
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

  /// Re-evaluates player progress when entering or returning from gameplay.
  /// Unlocks the next level immediately upon level completion.
  Future<void> refreshProgress() async {
    if (_world == null || _stageNodes.isEmpty) return;
    final world = _world!;

    final completedIds = <String>{};
    final starsMap = <String, int>{};
    int totalEarnedStars = 0;
    int levelsCompletedCount = 0;

    try {
      final progressDao = _resolveProgressDao();
      if (progressDao != null) {
        final allComps = await progressDao.getAllLevelCompletions();
        for (final comp in allComps) {
          completedIds.add(comp.levelId);
          starsMap[comp.levelId] = comp.starsEarned;
        }

        try {
          final byWorld = await progressDao.getCompletedLevelIds(world.id);
          completedIds.addAll(byWorld);
        } catch (_) {}

        try {
          final wp = await progressDao.getWorldProgress(world.id);
          if (wp != null) {
            levelsCompletedCount = wp.levelsCompleted;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[LevelMapScene] Progress refresh error: $e');
    }

    for (final lvl in world.levels) {
      if (starsMap.containsKey(lvl.id)) {
        totalEarnedStars += starsMap[lvl.id]!;
      }
    }

    String? currentLevelId;
    for (int i = 0; i < world.levels.length; i++) {
      final lvl = world.levels[i];
      final isCompleted = completedIds.contains(lvl.id) ||
          (starsMap[lvl.id] ?? 0) > 0 ||
          i < levelsCompletedCount;
      if (!isCompleted) {
        currentLevelId = lvl.id;
        break;
      }
    }
    currentLevelId ??= world.levels.isNotEmpty ? world.levels.last.id : null;

    for (int i = 0; i < _stageNodes.length; i++) {
      if (i >= world.levels.length) break;
      final lvl = world.levels[i];

      final isCompleted = completedIds.contains(lvl.id) ||
          (starsMap[lvl.id] ?? 0) > 0 ||
          i < levelsCompletedCount;

      final prevCompleted = i > 0 &&
          (completedIds.contains(world.levels[i - 1].id) ||
              (starsMap[world.levels[i - 1].id] ?? 0) > 0 ||
              (i - 1) < levelsCompletedCount);

      final isUnlocked = i == 0 ||
          i <= levelsCompletedCount ||
          isCompleted ||
          prevCompleted;

      final isCurrent = lvl.id == currentLevelId;
      final stars = starsMap[lvl.id] ?? 0;

      _stageNodes[i].updateProgress(
        stars: stars,
        isUnlocked: isUnlocked,
        isCurrent: isCurrent,
      );
    }

    headerComponent?.updateStars(totalEarnedStars, world.levels.length * 3);
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
