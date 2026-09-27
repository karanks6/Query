import 'package:flame/components.dart';
import '../../data/content/models/level_model.dart';
import 'query_scene.dart';

import 'package:flame_riverpod/flame_riverpod.dart';
import '../../features/gameplay/gameplay_provider.dart';
import '../components/gameplay/block_workspace_component.dart';
import '../components/gameplay/gameplay_hud_component.dart';
import '../components/gameplay/briefing_panel_component.dart';
import '../components/gameplay/run_button_component.dart';
import '../components/gameplay/tab_bar_component.dart';
import '../components/gameplay/icon_button_component.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
import '../effects/particle_effects.dart';

import '../../main.dart'; // for navigatorKey
import '../../features/hints/hints_modal.dart';
import '../../features/gameplay/widgets/data_browser.dart';
import '../../features/gameplay/widgets/query_history_sheet.dart';
import '../../features/gameplay/widgets/concept_lesson_dialog.dart';
import 'victory_scene.dart';

enum GameplayStatus { initial, success, failed }

class GameplayScene extends QueryScene with RiverpodComponentMixin {
  final LevelModel level;
  late BlockWorkspaceComponent blockWorkspace;
  late GameplayHudComponent hud;
  late BriefingPanelComponent briefingPanel;
  late RunButtonComponent runButton;
  late TabBarComponent tabBar;
  
  GameplayScene({required this.level});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background (Dark Wood base)
    final bg = RectangleComponent(
      size: game.size,
      paint: Paint()..color = const Color(0xFF2C1B10), // Very dark wood
    );
    add(bg);

    // Add HUD
    hud = GameplayHudComponent(
      level: level,
      state: const GameplayState(),
      onBackTap: () {
        game.popScene();
      },
    );
    add(hud);

    // Add Tab Bar (centered, at top)
    tabBar = TabBarComponent(
      state: const GameplayState(),
      onToggle: () {},
      size: Vector2(160, 40),
      position: Vector2(game.size.x / 2 - 80, 108), // 68 + 40 safeArea
    );
    add(tabBar);

    // Add Briefing Panel (below HUD + tab bar)
    briefingPanel = BriefingPanelComponent(
      level: level,
      size: Vector2(game.size.x - 40, 140),
      position: Vector2(20, 160), // 120 + 40 safeArea
    );
    add(briefingPanel);

    // Action buttons (left side bottom)
    final btnY = game.size.y - 80; // slightly higher
    add(IconButtonComponent(
      label: 'HINT',
      primaryColor: const Color(0xFF5A7C8A), // Slate blue for hint
      onTap: () {
        final state = ref.read(gameplayProvider);
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          backgroundColor: const Color(0xFFEFE6D5),
          isScrollControlled: true,
          builder: (_) => HintsModal(
            hints: level.hints,
            highestUsed: state.highestHintUsed,
            attemptCount: state.attemptCount,
            onHintUsed: (tier) async => await ref.read(gameplayProvider.notifier).useHint(tier),
          ),
        );
      },
      size: Vector2(60, 48),
      position: Vector2(20, btnY),
    ));

    add(IconButtonComponent(
      label: 'SCHEMA',
      primaryColor: const Color(0xFFD48B3E),
      onTap: () {
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFEFE6D5),
          builder: (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (_, controller) => DataBrowser(
              level: level,
              scrollController: controller,
            ),
          ),
        );
      },
      size: Vector2(70, 48),
      position: Vector2(90, btnY),
    ));

    add(IconButtonComponent(
      label: 'HISTORY',
      primaryColor: const Color(0xFF8B5A2B),
      onTap: () {
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFEFE6D5),
          builder: (_) => QueryHistorySheet(levelId: level.id),
        );
      },
      size: Vector2(70, 48),
      position: Vector2(170, btnY),
    ));

    // Add Block Workspace
    blockWorkspace = BlockWorkspaceComponent();
    add(blockWorkspace);

    // Add Run Button
    runButton = RunButtonComponent(
      onRun: () {
        ref.read(gameplayProvider.notifier).runQuery();
      },
      size: Vector2(120, 60), // slightly more compact
      position: Vector2(game.size.x - 140, game.size.y - 90), // shifted up
    );
    add(runButton);
  }

  @override
  Future<void> onEnter() async {
    super.onEnter();
    // Load level into state
    ref.read(gameplayProvider.notifier).loadLevel(level);

    if (level.type == LevelType.tutorial || level.levelNumber == 1) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (ctx) => ConceptLessonDialog(level: level),
      );
    }
  }

  @override
  void onMount() {
    super.onMount();
    // Wire up tab bar toggle now that ref is available
    tabBar.onToggleCallback = () {
      ref.read(gameplayProvider.notifier).toggleQueryMode();
    };
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (final child in children) {
      if (child is RectangleComponent && child.paint.color == const Color(0xFF2C1B10)) {
        child.size = size;
        break;
      }
    }
    if (isLoaded) {
      briefingPanel.size = Vector2(size.x - 40, 140);
      briefingPanel.position = Vector2(20, 160);
      tabBar.position = Vector2(size.x / 2 - 80, 108);
      runButton.position = Vector2(size.x - 140, size.y - 90);
      // Ideally update icon buttons positions here too
    }
  }

  GameplayStatus _lastStatus = GameplayStatus.initial;

  GameplayStatus _deriveStatus(GameplayState state) {
    if (state.levelCompleted) return GameplayStatus.success;
    if (state.lastReport != null && !state.lastReport!.isComplete) return GameplayStatus.failed;
    if (state.sandboxError != null) return GameplayStatus.failed;
    return GameplayStatus.initial;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final state = ref.read(gameplayProvider);
    if (state.queryMode == QueryMode.block) {
      blockWorkspace.priority = 10;
    } else {
      blockWorkspace.priority = -10;
    }

    final currentStatus = _deriveStatus(state);
    if (currentStatus != _lastStatus) {
      _lastStatus = currentStatus;
      if (currentStatus == GameplayStatus.success) {
        // Success Explosion from center of screen
        add(ParticleEffects.successExplosion(game.size / 2.0));
        
        // Push VictoryScene after a short delay to see explosion
        Future.delayed(const Duration(seconds: 1), () {
          if (!isMounted) return;
          game.pushScene(
            VictoryScene(
              level: level,
              state: state,
              onNextLevel: () {
                 // Dummy transition for now since we removed Flutter Navigator
                 game.popScene();
              },
              onReplay: () {
                game.popScene();
                ref.read(gameplayProvider.notifier).dismissFeedback();
              },
              onMap: () {
                game.popScene(); // Pop Victory
                game.popScene(); // Pop Gameplay to go back to LevelMap
              },
            ),
          );
        });
      } else if (currentStatus == GameplayStatus.failed) {
        // Error sparks from run button
        add(ParticleEffects.errorSparks(runButton.position + runButton.size / 2.0));
        
        // Shake run button
        runButton.add(
          MoveEffect.by(
            Vector2(10, 0),
            EffectController(
              duration: 0.05,
              reverseDuration: 0.05,
              repeatCount: 4,
            ),
          ),
        );
      }
    }
  }

  @override
  List<String> get activeOverlays => ['flutter_code_editor'];
}

