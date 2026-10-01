import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gameplay_provider.dart';
import 'widgets/code_mode_workspace.dart';
import 'widgets/result_pane.dart';
import 'widgets/flutter_block_workspace.dart';

class GameplayScreenOverlay extends ConsumerWidget {
  const GameplayScreenOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameplayProvider);

    if (state.level == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Offsets to align with the Flame HUD drawn on-canvas
        const topFlameUIBottom = 270.0;
        const bottomFlameUITop = 110.0;

        final availableHeight = math.max(
            0.0, constraints.maxHeight - topFlameUIBottom - bottomFlameUITop);
        final resultsHeight = (availableHeight * 0.4).clamp(100.0, 280.0);

        final hasResults = state.lastReport?.resultRows != null;
        final bottomOffset = hasResults
            ? bottomFlameUITop + resultsHeight + 16
            : bottomFlameUITop + 16;
        final workspaceHeight =
            math.max(0.0, constraints.maxHeight - topFlameUIBottom - bottomOffset);

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // ── Block mode: Flutter-native workspace ──────────────────────
              if (state.queryMode == QueryMode.block)
                Positioned(
                  top: topFlameUIBottom,
                  left: 0,
                  right: 0,
                  height: workspaceHeight,
                  child: const FlutterBlockWorkspace(
                    key: ValueKey('block_workspace'),
                  ),
                ),

              // ── Code mode: text editor ────────────────────────────────────
              if (state.queryMode == QueryMode.code)
                Positioned(
                  top: topFlameUIBottom,
                  left: 16,
                  right: 16,
                  height: workspaceHeight,
                  child: CodeModeWorkspace(
                    key: const ValueKey('code'),
                    schema: state.level!.schema,
                    currentQuery: state.currentQuery,
                    onQueryChanged: (q) =>
                        ref.read(gameplayProvider.notifier).updateQuery(q),
                  ),
                ),

              // ── Results pane ──────────────────────────────────────────────
              if (hasResults)
                Positioned(
                  bottom: bottomFlameUITop,
                  left: 16,
                  right: 16,
                  height: resultsHeight,
                  child: ResultPane(rows: state.lastReport!.resultRows!),
                ),
            ],
          ),
        );
      },
    );
  }
}
