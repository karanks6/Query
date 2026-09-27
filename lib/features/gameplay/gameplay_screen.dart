import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gameplay_provider.dart';
import 'widgets/code_mode_workspace.dart';
import 'widgets/result_pane.dart';

class GameplayScreenOverlay extends ConsumerWidget {
  const GameplayScreenOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameplayProvider);

    if (state.level == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Hardcode offsets to perfectly align with Flame scene fixed pixel positions
        const topFlameUIBottom = 270.0; 
        const bottomFlameUITop = 110.0; 

        final availableHeight = math.max(0.0, constraints.maxHeight - topFlameUIBottom - bottomFlameUITop);
        final resultsHeight = (availableHeight * 0.4).clamp(100.0, 300.0);
        
        final hasResults = state.lastReport?.resultRows != null;
        final bottomOffset = hasResults ? bottomFlameUITop + resultsHeight + 16 : bottomFlameUITop + 16;
        final codeHeight = math.max(0.0, constraints.maxHeight - topFlameUIBottom - bottomOffset);

        return Material(
          type: MaterialType.transparency,
          child: Stack(
          children: [
            if (state.queryMode == QueryMode.code)
              Positioned(
                top: topFlameUIBottom,
                left: 16,
                right: 16,
                height: codeHeight,
                child: CodeModeWorkspace(
                  key: const ValueKey('code'),
                  schema: state.level!.schema,
                  currentQuery: state.currentQuery,
                  onQueryChanged: (q) =>
                      ref.read(gameplayProvider.notifier).updateQuery(q),
                ),
              ),

            if (state.lastReport?.resultRows != null)
              Positioned(
                bottom: bottomFlameUITop,
                left: 16,
                right: 16,
                height: resultsHeight,
                child: ResultPane(rows: state.lastReport!.resultRows!),
              ),
          ],
        ));
      },
    );
  }
}
