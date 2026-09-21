import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../data/content/models/level_model.dart';
import '../../core/scoring/level_scorer.dart';
import 'gameplay_provider.dart';
import 'widgets/data_browser.dart';
import 'widgets/code_mode_workspace.dart';
import 'widgets/result_pane.dart';
import 'widgets/concept_lesson_dialog.dart';
import '../feedback_overlay/feedback_overlay.dart';
import '../hints/hints_modal.dart';
import 'widgets/query_history_sheet.dart';
import 'widgets/notes_sheet.dart';
import '../../game/scenes/gameplay_scene.dart';
import '../../main.dart';

/// Core Gameplay Screen (Section 5.5).
///
/// Phone layout:
///   - Schema browser: swipe-up drawer
///   - Workspace: full width
///   - Results: bottom sheet on run
///
/// Tablet layout:
///   - Schema browser: left side panel (collapsible)
///   - Workspace: main area
///   - Results: below workspace
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
    final isTablet = MediaQuery.of(context).size.width > 720;

    ref.listen<GameplayState>(gameplayProvider, (previous, next) {
      if ((previous == null || !previous.showFeedback) && next.showFeedback) {
        _showFeedback(context, next);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
            children: [
              // Ã¢â€â‚¬Ã¢â€â‚¬ HUD / Top bar Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
              _GameplayHUD(level: widget.level, state: state),

              // Ã¢â€â‚¬Ã¢â€â‚¬ Main area Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
              Expanded(
                child: isTablet
                    ? _TabletLayout(level: widget.level, state: state)
                    : _PhoneLayout(level: widget.level, state: state),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
            ],
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

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ HUD Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

class _GameplayHUD extends ConsumerStatefulWidget {
  final LevelModel level;
  final GameplayState state;

  const _GameplayHUD({required this.level, required this.state});

  @override
  ConsumerState<_GameplayHUD> createState() => _GameplayHUDState();
}

class _GameplayHUDState extends ConsumerState<_GameplayHUD> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final startTime = widget.state.levelStartTime;
      if (startTime != null && !widget.state.levelCompleted) {
        setState(() {
          _elapsed = DateTime.now().difference(startTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final level = widget.level;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceSm),
      decoration: BoxDecoration(
        color: GameTokens.surface,
        border: Border(
          bottom: BorderSide(color: GameTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.close,
                color: GameTokens.secondaryText, size: 18),
            onPressed: () => _confirmExit(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          const SizedBox(width: GameTokens.spaceSm),

          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        level.title,
                        style: GameTokens.bodySmall.copyWith(
                          color: GameTokens.accent,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (state.isDailyChallenge) ...[  
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: GameTokens.warning.withValues(alpha: 0.2),
                          borderRadius: GameTokens.borderRadiusSm,
                          border: Border.all(color: GameTokens.warning, width: 1),
                        ),
                        child: Text(
                          '2× XP',
                          style: GameTokens.bodySmall.copyWith(
                            color: GameTokens.warning,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (level.type == LevelType.debugging)
                  Text(
                    'DEBUGGING CHALLENGE',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.error,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (level.type == LevelType.optimizationChallenge)
                  Text(
                    'OPTIMIZATION CHALLENGE',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.warning,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Mode toggle
          if (!level.type.isBlockModeOnly)
            _ModeToggle(state: state),

          const SizedBox(width: GameTokens.spaceSm),

          // Star preview (best earned so far for this level)
          if (level.type.hasStarRating) StarRow(starCount: state.existingStars),

          // Attempts indicator
          const SizedBox(width: GameTokens.spaceSm),
          Text(
            '#${state.attemptCount}',
            style: GameTokens.bodySmall.copyWith(
              color: GameTokens.secondaryText,
              fontSize: 10,
            ),
          ),

          // Live elapsed timer
          const SizedBox(width: GameTokens.spaceSm),
          Icon(Icons.timer_outlined, color: GameTokens.accent, size: 12),
          const SizedBox(width: 2),
          Text(
            _formatDuration(_elapsed),
            style: GameTokens.codeSmall.copyWith(
              color: GameTokens.accent,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GameTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: GameTokens.borderRadiusSm,
          side: BorderSide(color: GameTokens.accentDim),
        ),
        title: Text('Exit level?', style: GameTokens.headlineMedium),
        content: Text(
          'Your progress on this attempt won\'t be saved.',
          style: GameTokens.bodyMedium.copyWith(
            color: GameTokens.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('KEEP PLAYING', style: GameTokens.labelLarge),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'EXIT',
              style: GameTokens.labelLarge
                  .copyWith(color: GameTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends ConsumerWidget {
  final GameplayState state;

  const _ModeToggle({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(gameplayProvider.notifier).toggleQueryMode(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: GameTokens.accentDim, width: 1),
          borderRadius: GameTokens.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BLOCK',
              style: GameTokens.bodySmall.copyWith(
                color: state.queryMode == QueryMode.block
                    ? GameTokens.accent
                    : GameTokens.disabledText,
                fontSize: 9,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(width: 1, height: 10, color: GameTokens.accentDim),
            ),
            Text(
              'CODE',
              style: GameTokens.bodySmall.copyWith(
                color: state.queryMode == QueryMode.code
                    ? GameTokens.accent
                    : GameTokens.disabledText,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Phone Layout ─────────────────────────────────────────────────────────────

class _PhoneLayout extends ConsumerWidget {
  final LevelModel level;
  final GameplayState state;

  const _PhoneLayout({required this.level, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Level objective
                  _LevelNarrative(level: level),

                  // Workspace (fills available space)
                  Expanded(
                    child: _WorkspaceArea(level: level, state: state),
                  ),

                  // Results area (shows after run)
                  if (state.lastReport?.resultRows != null)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ResultPane(rows: state.lastReport!.resultRows!),
                    ),

                  // Bottom action bar
                  _ActionBar(level: level, state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Tablet Layout ────────────────────────────────────────────────────────────

class _TabletLayout extends ConsumerWidget {
  final LevelModel level;
  final GameplayState state;

  const _TabletLayout({required this.level, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Schema browser panel
        if (state.schemaExpanded)
          SizedBox(
            width: 220,
            child: DataBrowser(level: level),
          ),

        Container(width: 1, color: GameTokens.accentDim),

        // Main area
        Expanded(
          child: Column(
            children: [
              // Schema toggle button (tablet)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    state.schemaExpanded
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: GameTokens.secondaryText,
                  ),
                  onPressed: () =>
                      ref.read(gameplayProvider.notifier).toggleSchemaPanel(),
                ),
              ),

              // Level objective
              _LevelNarrative(level: level),

              // Workspace
              Expanded(child: _WorkspaceArea(level: level, state: state)),

              // Results
              if (state.lastReport?.resultRows != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ResultPane(rows: state.lastReport!.resultRows!),
                ),

              _ActionBar(level: level, state: state),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Workspace area ----------------------------------------------

class _WorkspaceArea extends ConsumerWidget {
  final LevelModel level;
  final GameplayState state;

  const _WorkspaceArea({required this.level, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: GameTokens.durationNormal,
      child: state.queryMode == QueryMode.block
          ? SizedBox.expand(key: const ValueKey('block')) // Flame engine handles block mode
          : CodeModeWorkspace(
              key: const ValueKey('code'),
              schema: level.schema,
              currentQuery: state.currentQuery,
              onQueryChanged: (q) =>
                  ref.read(gameplayProvider.notifier).updateQuery(q),
            ),
    );
  }
}

// ─── Action bar ───────────────────────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  final LevelModel level;
  final GameplayState state;

  const _ActionBar({required this.level, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameTokens.spaceMd,
        vertical: GameTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: GameTokens.surface,
        border: Border(
          top: BorderSide(color: GameTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Hints
          ActionButton(
            onPressed: () => _showHints(context, level, state, ref),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: GameTokens.warning, size: 16),
                if (MediaQuery.of(context).size.width > 720) ...[
                  const SizedBox(width: 4),
                  Text('HINT', style: GameTokens.labelLarge.copyWith(color: GameTokens.warning)),
                ],
              ],
            ),
          ),

          // Schema (phone only — opens drawer)
          if (MediaQuery.of(context).size.width <= 720)
            ActionButton(
              onPressed: () => _showSchemaBrowser(context, level),
              child: Row(
                children: [
                  const Icon(Icons.table_chart_outlined,
                      color: GameTokens.info, size: 16),
                  if (MediaQuery.of(context).size.width > 380) ...[
                    const SizedBox(width: 4),
                    Text('SCHEMA', style: GameTokens.labelLarge.copyWith(color: GameTokens.info)),
                  ]
                ],
              ),
            ),

          const SizedBox(width: GameTokens.spaceSm),

          // Query history
          ActionButton(
            onPressed: () => _showQueryHistory(context, level),
            child: Row(
              children: [
                const Icon(Icons.history,
                    color: GameTokens.secondaryText, size: 16),
                if (MediaQuery.of(context).size.width > 500) ...[
                  const SizedBox(width: 4),
                  Text('HISTORY', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
                ],
              ],
            ),
          ),

          const SizedBox(width: GameTokens.spaceSm),

          // Notes
          ActionButton(
            onPressed: () => _showNotes(context, level),
            child: Row(
              children: [
                const Icon(Icons.note_alt_outlined,
                    color: GameTokens.secondaryText, size: 16),
                if (MediaQuery.of(context).size.width > 600) ...[
                  const SizedBox(width: 4),
                  Text('NOTES', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Run button
          ActionButton(
            isPrimary: true,
            onPressed: state.isRunning
                ? null
                : () => ref.read(gameplayProvider.notifier).runQuery(),
            child: Row(
              children: [
                if (state.isRunning)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: GameTokens.background),
                  )
                else
                  const Icon(Icons.play_arrow_rounded,
                      color: GameTokens.background, size: 16),
                const SizedBox(width: 8),
                Text(MediaQuery.of(context).size.width <= 380 ? 'RUN' : 'RUN QUERY', style: GameTokens.labelLarge.copyWith(color: GameTokens.background)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHints(
    BuildContext context,
    LevelModel level,
    GameplayState state,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameTokens.surface,
      isScrollControlled: true,
      builder: (_) => HintsModal(
        hints: level.hints,
        highestUsed: state.highestHintUsed,
        attemptCount: state.attemptCount,
        onHintUsed: (HintTier tier) async =>
            await ref.read(gameplayProvider.notifier).useHint(tier),
      ),
    );
  }

  void _showSchemaBrowser(BuildContext context, LevelModel level) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
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
  }

  void _showQueryHistory(BuildContext context, LevelModel level) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QueryHistorySheet(levelId: level.id),
      ),
    );
  }

  void _showNotes(BuildContext context, LevelModel level) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const NotesSheet(),
      ),
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Level Narrative (Question) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

class _LevelNarrative extends StatelessWidget {
  final LevelModel level;

  const _LevelNarrative({required this.level});

  @override
  Widget build(BuildContext context) {
    if (level.narrative.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(GameTokens.spaceSm),
      child: SlantedPanel(
        // Subdued so it doesn't distract from interactive elements
        padding: const EdgeInsets.all(GameTokens.spaceMd),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    color: GameTokens.accent,
                    child: Text(
                      'TARGET',
                      style: GameTokens.labelLarge.copyWith(
                        color: GameTokens.background,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              MarkdownBody(
                data: level.narrative,
                styleSheet: MarkdownStyleSheet(
                  p: GameTokens.bodyMedium.copyWith(
                    color: GameTokens.primaryText,
                    height: 1.4,
                  ),
                  tableBody: GameTokens.codeSmall.copyWith(color: GameTokens.primaryText),
                  tableHead: GameTokens.codeSmall.copyWith(color: GameTokens.accent, fontWeight: FontWeight.bold),
                  tableBorder: TableBorder.all(color: GameTokens.accentDim, width: 1),
                ),
              ),
              const SizedBox(height: GameTokens.spaceMd),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: GameTokens.accentDim, width: 1),
                  borderRadius: GameTokens.borderRadiusSm,
                ),
                child: DataBrowser(level: level),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
