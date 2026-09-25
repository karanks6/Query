import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

import '../../data/content/models/level_model.dart';
import 'gameplay_provider.dart';
import 'widgets/code_mode_workspace.dart';
import 'widgets/result_pane.dart';
import 'widgets/concept_lesson_dialog.dart';
import '../feedback_overlay/feedback_overlay.dart';
import '../../game/scenes/gameplay_scene.dart';
import '../../game/scenes/victory_scene.dart';
import '../../main.dart';

/// Core Gameplay Screen.
/// In Phase 5, this is just a transparent overlay that holds the Flame engine,
/// and occasionally renders the Code Mode text editor or Results pane.
class GameplayScreen extends ConsumerStatefulWidget {
  final LevelModel level;

  const GameplayScreen({super.key, required this.level});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  @override
  void initState() {
    super.initState();
    // Load level into gameplay notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we were launched from the daily challenge route
      final route = ModalRoute.of(context);
      final isDailyChallenge =
          route?.settings.name == '/daily_challenge_gameplay';
      ref.read(gameplayProvider.notifier).loadLevel(
            widget.level,
            isDailyChallenge: isDailyChallenge,
          );
          
      // Push GameplayScene to Flame Engine
      ref.read(queryGameProvider).pushScene(
            GameplayScene(level: widget.level),
          );

      if (widget.level.type == LevelType.tutorial || widget.level.levelNumber == 1) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => ConceptLessonDialog(level: widget.level),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameplayProvider);

    ref.listen<GameplayState>(gameplayProvider, (previous, next) {
      if ((previous == null || !previous.showFeedback) && next.showFeedback) {
        if (next.levelCompleted) {
          ref.read(queryGameProvider).pushScene(
            VictoryScene(
              level: widget.level,
              state: next,
              onNextLevel: () async {
                final loader = ref.read(levelLoaderProvider);
                try {
                  final world = await loader.loadWorld(widget.level.worldId);
                  if (!context.mounted) return;
                  final currentIndex = world.levels.indexWhere((l) => l.id == widget.level.id);
                  if (currentIndex >= 0 && currentIndex < world.levels.length - 1) {
                    final nextLevel = world.levels[currentIndex + 1];
                    ref.read(queryGameProvider).popScene();
                    Navigator.of(context).pushReplacementNamed('/gameplay', arguments: nextLevel);
                  } else {
                    ref.read(queryGameProvider).popScene();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ref.read(queryGameProvider).popScene();
                  Navigator.of(context).pop();
                }
              },
              onReplay: () {
                ref.read(queryGameProvider).popScene();
                ref.read(gameplayProvider.notifier).dismissFeedback();
              },
              onMap: () {
                ref.read(queryGameProvider).popScene();
                Navigator.of(context).pop();
              },
            ),
          );
        } else {
          _showFeedback(context, next);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Hardcode offsets to perfectly align with Flame scene fixed pixel positions
            // Briefing panel ends at y=260 (120 + 140)
            const topFlameUIBottom = 270.0; 
            // Action buttons are at y = size.y - 70. Block palette is at size.y - 100.
            const bottomFlameUITop = 110.0; 

            final availableHeight = constraints.maxHeight - topFlameUIBottom - bottomFlameUITop;
            // The result pane takes about 40% of the middle space
            final resultsHeight = (availableHeight * 0.4).clamp(100.0, 300.0);

            return Stack(
              children: [
                // Only show Flutter Code Editor if in Code mode
                if (state.queryMode == QueryMode.code)
                  Positioned(
                    top: topFlameUIBottom,
                    left: 16,
                    right: 16,
                    bottom: (state.lastReport?.resultRows != null) 
                        ? bottomFlameUITop + resultsHeight + 16 // Leave gap above results
                        : bottomFlameUITop + 16, 
                    child: CodeModeWorkspace(
                      key: const ValueKey('code'),
                      schema: widget.level.schema,
                      currentQuery: state.currentQuery,
                      onQueryChanged: (q) =>
                          ref.read(gameplayProvider.notifier).updateQuery(q),
                    ),
                  ),

                // Only show Result Pane if we have results
                if (state.lastReport?.resultRows != null)
                  Positioned(
                    bottom: bottomFlameUITop,
                    left: 16,
                    right: 16,
                    height: resultsHeight,
                    child: ResultPane(rows: state.lastReport!.resultRows!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context, GameplayState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FeedbackOverlay(
        report: state.lastReport,
        sandboxError: state.sandboxError,
        score: state.levelScore,
        newlyEarnedAchievements: state.newlyEarnedAchievements,
        onDismiss: () {
          Navigator.of(ctx).pop();
        },
        onNextLevel: state.levelCompleted
            ? () async {
                final loader = ref.read(levelLoaderProvider);
                try {
                  final world = await loader.loadWorld(state.level!.worldId);
                  if (!context.mounted) return;
                  final currentIndex = world.levels.indexWhere((l) => l.id == state.level!.id);
                  if (currentIndex >= 0 && currentIndex < world.levels.length - 1) {
                    final nextLevel = world.levels[currentIndex + 1];
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushReplacementNamed('/gameplay', arguments: nextLevel);
                  } else {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                }
              }
            : null,
        onRetry: () {
          Navigator.of(ctx).pop();
        },
      ),
    ).whenComplete(() {
      if (mounted) {
        ref.read(gameplayProvider.notifier).dismissFeedback();
      }
    });
  }
}
