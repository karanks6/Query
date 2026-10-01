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
      return const Positioned.fill(
        child: Center(
          child: Material(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'LOADING LEVEL...',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      );
    }

    final hasResults = state.lastReport?.resultRows != null;

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transparent top gap — Flame HUD, tab bar and briefing show through
            const SizedBox(height: _kTopOffset),

            // ── Active input workspace ────────────────────────────────────────
            Expanded(
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
              SizedBox(
                height: 200,
                child: ResultPane(rows: state.lastReport!.resultRows!),
              ),

            // Transparent bottom gap — Flame action buttons show through
            const SizedBox(height: _kBottomOffset),
          ],
        ),
      ),
    );
  }
}
