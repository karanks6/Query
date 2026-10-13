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
import '../../core/providers.dart';

/// High-end Unity-style Level Map Scene.
///
/// Features:
/// - Flowing enchanted river connecting all stages with moving animations & sparkles
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
    final bg = await ParallaxComponent.load(
      [ParallaxImageData("jungle_pattern.jpg")],
      baseVelocity: Vector2(0, -4),
      repeat: ImageRepeat.repeat,
    );
    bg.size = game.size;
    add(bg);

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

    // 4. Load World content and player progress
    try {
      final world = await LevelLoader.instance.loadWorld(worldId);

      // Fetch player progress for this world
      final progressDao = ref.read(progressDaoProvider);
      final completedIds = await progressDao.getCompletedLevelIds(worldId);
      final starsMap = <String, int>{};
      int totalEarnedStars = 0;

      for (final levelId in completedIds) {
        final completion = await progressDao.getLevelCompletion(levelId);
        if (completion != null) {
          starsMap[levelId] = completion.starsEarned;
          totalEarnedStars += completion.starsEarned;
        }
      }

      // Determine active/current level
      String? currentLevelId;
      for (final lvl in world.levels) {
        if (!completedIds.contains(lvl.id)) {
          currentLevelId = lvl.id;
          break;
        }
      }
      // If all cleared, mark the last level as current or null
      currentLevelId ??= world.levels.isNotEmpty ? world.levels.last.id : null;

      // 5. Build Responsive Layout for Stage Nodes
      final screenWidth = game.size.x;
      const margin = 18.0;
      final nodeWidth = (screenWidth * 0.58).clamp(195.0, 235.0);
      const nodeHeight = 74.0;
      final leftX = margin;
      final rightX = (screenWidth - nodeWidth - margin).clamp(margin, screenWidth - nodeWidth - margin);

      final riverPoints = <Vector2>[];

      // Initial river inlet point at top of scroll view
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

        // Add stage medallion center to the river path
        riverPoints.add(stageNode.riverAnchorPoint);
      }

      // Final river outlet point flowing downstream past the last stage
      if (world.levels.isNotEmpty) {
        final lastY = 115.0 + ((world.levels.length - 1) * 125.0) + nodeHeight;
        riverPoints.add(Vector2(screenWidth / 2.0, lastY + 80.0));
      }

      riverComponent.setPoints(riverPoints);

      // Calculate max scroll bounds
      final totalContentHeight = 115.0 + (world.levels.length * 125.0) + 120.0;
      _maxScroll = totalContentHeight > game.size.y ? (totalContentHeight - game.size.y) : 0.0;

      // 6. Fixed Top HUD Header
      headerComponent = LevelMapHeaderComponent(
        worldTitle: world.title,
        worldSubtitle: 'Chapter ${world.number} • ${world.levels.length} Stages',
        earnedStars: totalEarnedStars,
        totalPossibleStars: world.levels.length * 3,
        onBackPressed: () => game.popScene(),
        size: Vector2(screenWidth, 82),
      );
      add(headerComponent!);

    } catch (e, st) {
      debugPrint('LevelMapScene load error: $e\n$st');
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
    headerComponent?.size = Vector2(size.x, 82);
  }
}
