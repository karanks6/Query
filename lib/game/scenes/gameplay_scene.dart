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
    
    // Add HUD
    hud = GameplayHudComponent(
      level: level,
      state: const GameplayState(),
      onBackTap: () {},
    );
    add(hud);

    // Add Tab Bar (centered, at top)
    tabBar = TabBarComponent(
      state: const GameplayState(),
      onToggle: () {},
      size: Vector2(160, 40),
      position: Vector2(game.size.x / 2 - 80, 68),
    );
    add(tabBar);

    // Add Briefing Panel (below HUD + tab bar)
    briefingPanel = BriefingPanelComponent(
      level: level,
      size: Vector2(game.size.x - 40, 140),
      position: Vector2(20, 120),
    );
    add(briefingPanel);

    // Action buttons (left side bottom)
    final btnY = game.size.y - 70;
    add(IconButtonComponent(
      label: 'HINT',
      onTap: () {
        final state = ref.read(gameplayProvider);
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          backgroundColor: const Color(0xFF15171E),
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
      onTap: () {
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF15171E),
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
      onTap: () {
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF15171E),
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
      size: Vector2(160, 48),
      position: Vector2(game.size.x - 180, game.size.y - 70),
    );
    add(runButton);
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
    if (isLoaded) {
      briefingPanel.size = Vector2(size.x - 40, 140);
      briefingPanel.position = Vector2(20, 120);
      tabBar.position = Vector2(size.x / 2 - 80, 68);
      runButton.position = Vector2(size.x - 180, size.y - 70);
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
        add(ParticleEffects.successExplosion(game.size / 2));
      } else if (currentStatus == GameplayStatus.failed) {
        // Error sparks from run button
        add(ParticleEffects.errorSparks(runButton.position + runButton.size / 2));
        
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
}

