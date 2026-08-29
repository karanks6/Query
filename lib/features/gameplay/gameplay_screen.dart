import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../data/content/models/level_model.dart';
import '../../core/scoring/level_scorer.dart';
import 'gameplay_provider.dart';
import 'widgets/schema_browser.dart';
import 'widgets/block_mode_workspace.dart';
import 'widgets/code_mode_workspace.dart';
import 'widgets/result_pane.dart';
import '../feedback_overlay/feedback_overlay.dart';
import '../hints/hints_modal.dart';

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
      ref.read(gameplayProvider.notifier).loadLevel(widget.level);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameplayProvider);
    final isTablet = MediaQuery.of(context).size.width > 720;

    // Show feedback overlay when triggered
    if (state.showFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.showFeedback) {
          _showFeedback(context, state);
        }
      });
    }

    return Scaffold(
      backgroundColor: TerminalClassicTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── HUD / Top bar ─────────────────────────────────────────────
            _GameplayHUD(level: widget.level, state: state),

            // ── Main area ─────────────────────────────────────────────────
            Expanded(
              child: isTablet
                  ? _TabletLayout(level: widget.level, state: state)
                  : _PhoneLayout(level: widget.level, state: state),
            ),
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
        onDismiss: () {
          ref.read(gameplayProvider.notifier).dismissFeedback();
          Navigator.of(ctx).pop();
        },
        onNextLevel: state.levelCompleted
            ? () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              }
            : null,
        onRetry: () {
          ref.read(gameplayProvider.notifier).dismissFeedback();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

// ─── HUD ──────────────────────────────────────────────────────────────────────

class _GameplayHUD extends ConsumerWidget {
  final LevelModel level;
  final GameplayState state;

  const _GameplayHUD({required this.level, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: TerminalClassicTokens.spaceSm),
      decoration: BoxDecoration(
        color: TerminalClassicTokens.surface,
        border: Border(
          bottom: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.close,
                color: TerminalClassicTokens.secondaryText, size: 18),
            onPressed: () => _confirmExit(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          const SizedBox(width: TerminalClassicTokens.spaceSm),

          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  level.title,
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.accent,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Mode toggle
          if (!level.type.isBlockModeOnly)
            _ModeToggle(state: state),

          const SizedBox(width: TerminalClassicTokens.spaceSm),

          // Star preview
          if (level.type.hasStarRating) StarRow(starCount: 0),

          // Attempts indicator
          const SizedBox(width: TerminalClassicTokens.spaceSm),
          Text(
            '#${state.attemptCount}',
            style: TerminalClassicTokens.bodySmall.copyWith(
              color: TerminalClassicTokens.secondaryText,
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
        backgroundColor: TerminalClassicTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: TerminalClassicTokens.borderRadiusSm,
          side: BorderSide(color: TerminalClassicTokens.accentDim),
        ),
        title: Text('Exit level?', style: TerminalClassicTokens.headlineMedium),
        content: Text(
          'Your progress on this attempt won\'t be saved.',
          style: TerminalClassicTokens.bodyMedium.copyWith(
            color: TerminalClassicTokens.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('KEEP PLAYING', style: TerminalClassicTokens.labelLarge),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'EXIT',
              style: TerminalClassicTokens.labelLarge
                  .copyWith(color: TerminalClassicTokens.error),
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
          border: Border.all(color: TerminalClassicTokens.accentDim, width: 1),
          borderRadius: TerminalClassicTokens.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BLOCK',
              style: TerminalClassicTokens.bodySmall.copyWith(
                color: state.queryMode == QueryMode.block
                    ? TerminalClassicTokens.accent
                    : TerminalClassicTokens.disabledText,
                fontSize: 9,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(width: 1, height: 10, color: TerminalClassicTokens.accentDim),
            ),
            Text(
              'CODE',
              style: TerminalClassicTokens.bodySmall.copyWith(
                color: state.queryMode == QueryMode.code
                    ? TerminalClassicTokens.accent
                    : TerminalClassicTokens.disabledText,
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
    return Column(
      children: [
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
            child: SchemaBrowser(schema: level.schema),
          ),

        Container(width: 1, color: TerminalClassicTokens.accentDim),

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
                    color: TerminalClassicTokens.secondaryText,
                  ),
                  onPressed: () =>
                      ref.read(gameplayProvider.notifier).toggleSchemaPanel(),
                ),
              ),

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

// ─── Workspace area ───────────────────────────────────────────────────────────

class _WorkspaceArea extends ConsumerWidget {
  final LevelModel level;
  final GameplayState state;

  const _WorkspaceArea({required this.level, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: TerminalClassicTokens.durationNormal,
      child: state.queryMode == QueryMode.block
          ? BlockModeWorkspace(
              key: const ValueKey('block'),
              schema: level.schema,
              currentQuery: state.currentQuery,
              onQueryChanged: (q) =>
                  ref.read(gameplayProvider.notifier).updateQuery(q),
            )
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
        horizontal: TerminalClassicTokens.spaceMd,
        vertical: TerminalClassicTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: TerminalClassicTokens.surface,
        border: Border(
          top: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Hints
          TextButton.icon(
            onPressed: () => _showHints(context, level, state, ref),
            icon: const Icon(Icons.lightbulb_outline,
                color: TerminalClassicTokens.warning, size: 16),
            label: Text(
              'HINT',
              style: TerminalClassicTokens.bodySmall.copyWith(
                color: TerminalClassicTokens.warning,
                letterSpacing: 1,
              ),
            ),
          ),

          // Schema (phone only — opens drawer)
          if (MediaQuery.of(context).size.width <= 720)
            TextButton.icon(
              onPressed: () => _showSchemaBrowser(context, level),
              icon: const Icon(Icons.table_chart_outlined,
                  color: TerminalClassicTokens.info, size: 16),
              label: Text(
                'SCHEMA',
                style: TerminalClassicTokens.bodySmall.copyWith(
                  color: TerminalClassicTokens.info,
                  letterSpacing: 1,
                ),
              ),
            ),

          const Spacer(),

          // Run button
          TerminalButton(
            label: 'RUN QUERY',
            onPressed: state.isRunning
                ? null
                : () => ref.read(gameplayProvider.notifier).runQuery(),
            isLoading: state.isRunning,
            icon: const Icon(Icons.play_arrow_rounded,
                color: TerminalClassicTokens.accent, size: 16),
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
      backgroundColor: TerminalClassicTokens.surface,
      isScrollControlled: true,
      builder: (_) => HintsModal(
        hints: level.hints,
        highestUsed: state.highestHintUsed,
        attemptCount: state.attemptCount,
        onHintUsed: (HintTier tier) => ref.read(gameplayProvider.notifier).useHint(tier),
      ),
    );
  }

  void _showSchemaBrowser(BuildContext context, LevelModel level) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TerminalClassicTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => SchemaBrowser(
          schema: level.schema,
          scrollController: controller,
        ),
      ),
    );
  }
}
