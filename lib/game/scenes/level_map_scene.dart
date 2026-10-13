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
import '../../core/providers.dart';

/// High-end Unity-style Level Map Scene.
///
/// Features:
/// - Flowing enchanted river connecting all stages with moving water animations & sparkles
/// - 3D tactile stage node medallions with star ratings, lock states & pulsing active glow
/// - Fixed Unity-style top HUD with gold-trimmed Back button & Star trophy counter
/// - Strictly clamped responsive layouts ensuring zero screen overflow
class LevelMapScene extends QueryScene with RiverpodComponentMixin, DragCallbacks {
  final String worldId;
  late PositionComponent scrollContainer;
  late FlowingRiverComponent riverComponent;
  LevelMapHeaderComponent? headerComponent;
  RectangleComponent? _overlayComponent;

  double _scrollY = 0;
  double _maxScroll = 0;

  LevelMapScene({required this.worldId});

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    // 1. Parallax jungle background with dark mysterious vignette
    try {
      final bg = await ParallaxComponent.load(
        [ParallaxImageData("jungle_pattern.jpg")],
        baseVelocity: Vector2(0, -4),
        repeat: ImageRepeat.repeat,
      );
      bg.size = game.size;
      add(bg);
    } catch (_) {}

    _overlayComponent = RectangleComponent(
      size: game.size,
      paint: Paint()..color = const Color(0xB8050E12),
    );
    add(_overlayComponent!);

    // 2. Scroll Container for interactive map content
    scrollContainer = PositionComponent(size: game.size);
    add(scrollContainer);

    // 3. Flowing River Component (renders underneath stage nodes)
    riverComponent = FlowingRiverComponent();
    scrollContainer.add(riverComponent);

    // 4. Load World Model
    WorldModel? world;
    try {
      world = await LevelLoader.instance.loadWorld(worldId);
    } catch (e) {
      debugPrint('[LevelMapScene] Error loading worldId=$worldId: $e');
    }

    // Try fallback normalization if world was not found (e.g. world_01_archive_vaults -> world_01)
    if (world == null) {
      for (final avail in LevelLoader.instance.availableWorlds) {
        if (worldId.startsWith(avail) || avail.startsWith(worldId)) {
          try {
            world = await LevelLoader.instance.loadWorld(avail);
            break;
          } catch (_) {}
        }
      }
    }

    // If still null, load world_01 as safety net
    world ??= await LevelLoader.instance.loadWorld('world_01');

    // 5. Query Player Progress (strictly isolated so failure never affects UI rendering)
    List<String> completedIds = [];
    final starsMap = <String, int>{};
    int totalEarnedStars = 0;

    try {
      final progressDao = ref.read(progressDaoProvider);
      completedIds = await progressDao.getCompletedLevelIds(world.id);
      for (final levelId in completedIds) {
        final comp = await progressDao.getLevelCompletion(levelId);
        if (comp != null) {
          starsMap[levelId] = comp.starsEarned;
          totalEarnedStars += comp.starsEarned;
        }
      }
    } catch (e) {
      debugPrint('[LevelMapScene] Progress lookup skipped: $e');
    }

    // Determine active/current level
    String? currentLevelId;
    for (final lvl in world.levels) {
      if (!completedIds.contains(lvl.id)) {
        currentLevelId = lvl.id;
        break;
      }
    }
    currentLevelId ??= world.levels.isNotEmpty ? world.levels.last.id : null;

    // 6. Build Responsive Layout for Stage Nodes
    final screenWidth = game.size.x > 0 ? game.size.x : 360.0;
    const margin = 18.0;
    final nodeWidth = (screenWidth * 0.58).clamp(195.0, 235.0);
    const nodeHeight = 74.0;
    final leftX = margin;
    final rightX = (screenWidth - nodeWidth - margin).clamp(margin, screenWidth - nodeWidth - margin);

    final riverPoints = <Vector2>[];
    riverPoints.add(Vector2(screenWidth / 2.0, 90.0));

    for (int i = 0; i < world.levels.length; i++) {
      final level = world.levels[i];
      final isLeft = i % 2 == 0;
      final x = isLeft ? leftX : rightX;
      final y = 115.0 + (i * 125.0);

      final isCompleted = completedIds.contains(level.id);
      final isUnlocked = i == 0 || completedIds.contains(world.levels[i - 1].id) || isCompleted;
      final isCurrent = level.id == currentLevelId;
      final stars = starsMap[level.id] ?? 0;

      final stageNode = StageNodeComponent(
        stageNumber: i + 1,
        title: level.title,
        stars: stars,
        isUnlocked: isUnlocked,
        isCurrent: isCurrent,
        isLeftAligned: isLeft,
        size: Vector2(nodeWidth, nodeHeight),
        position: Vector2(x, y),
        onPressed: () {
          game.pushScene(GameplayScene(level: level));
        },
      );

      scrollContainer.add(stageNode);
      riverPoints.add(stageNode.riverAnchorPoint);
    }

    if (world.levels.isNotEmpty) {
      final lastY = 115.0 + ((world.levels.length - 1) * 125.0) + nodeHeight;
      riverPoints.add(Vector2(screenWidth / 2.0, lastY + 80.0));
    }

    riverComponent.setPoints(riverPoints);

    final totalContentHeight = 115.0 + (world.levels.length * 125.0) + 120.0;
    _maxScroll = totalContentHeight > game.size.y ? (totalContentHeight - game.size.y) : 0.0;

    // 7. Fixed Top HUD Header
    headerComponent = LevelMapHeaderComponent(
      worldTitle: world.title,
      worldSubtitle: 'Chapter ${world.number} • ${world.levels.length} Stages',
      earnedStars: totalEarnedStars,
      totalPossibleStars: world.levels.length * 3,
      onBackPressed: () => game.popScene(),
      size: Vector2(screenWidth, 82),
    );
    add(headerComponent!);
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
    headerComponent?.size = Vector2(size.x, 82);
  }
}
