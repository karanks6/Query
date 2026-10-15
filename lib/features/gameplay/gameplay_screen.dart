import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gameplay_provider.dart';
import 'widgets/code_mode_workspace.dart';
import 'widgets/result_pane.dart';
import 'widgets/flutter_block_workspace.dart';

// Distance from top to leave transparent (Flame HUD + tab bar + briefing panel).
const double _kTopOffset = 305.0;
// Distance from bottom to leave transparent (Flame action buttons + run button).
const double _kBottomOffset = 100.0;

class GameplayScreenOverlay extends ConsumerWidget {
  const GameplayScreenOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameplayProvider);
    if (state.level == null) {
      return const SizedBox.shrink();
    }

    final hasResults = state.lastReport?.resultRows != null;

    return Positioned(
      top: _kTopOffset,
      bottom: _kBottomOffset,
      left: 0,
      right: 0,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Active input workspace ────────────────────────────────────────
            Expanded(
              flex: 5,
              child: state.queryMode == QueryMode.block
                  ? const FlutterBlockWorkspace(key: ValueKey('blocks'))
                  : CodeModeWorkspace(
                      key: const ValueKey('code'),
                      schema: state.level!.schema,
                      currentQuery: state.currentQuery,
                      onQueryChanged: (q) =>
                          ref.read(gameplayProvider.notifier).updateQuery(q),
                    ),
            ),

            // ── Results pane (shown below workspace when available) ───────────
            if (hasResults)
              Flexible(
                flex: 3,
                child: ResultPane(rows: state.lastReport!.resultRows!),
              ),
          ],
        ),
      ),
    );
  }
}
