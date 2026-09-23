import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/validation/validation_result.dart';
import '../../core/sandbox_engine/sandbox_engine.dart';
import '../../core/scoring/level_scorer.dart';
import '../../core/validation/common_mistakes.dart';
import '../../core/audio/audio_controller.dart';
import '../gameplay/gameplay_provider.dart';
import '../reference/codex_screen.dart';
import '../gameplay/replay_screen.dart';

/// Feedback overlay (Section 5.6).
///
/// Surfaces the 4-layer feedback loop without leaving gameplay context.
/// Shows on top of the Gameplay Screen as a bottom sheet.
class FeedbackOverlay extends ConsumerWidget {
  final QueryValidationReport? report;
  final SandboxException? sandboxError;
  final LevelScore? score;
  final VoidCallback onDismiss;
  final VoidCallback? onNextLevel;
  final VoidCallback onRetry;
  final List<String> newlyEarnedAchievements;

  const FeedbackOverlay({
    super.key,
    this.report,
    this.sandboxError,
    this.score,
    required this.onDismiss,
    this.onNextLevel,
    required this.onRetry,
    this.newlyEarnedAchievements = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuccess = report?.isComplete ?? false;
    
    // Play sound effect on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider).playSfx(isSuccess ? 'level_success' : 'level_failure');
    });

    final state = ref.watch(gameplayProvider);
    final offerDetectiveMode = state.attemptCount >= 3 && 
                               state.level?.detectiveStarterQuery != null && 
                               !state.isDetectiveMode;

    return SlantedPanel(
      borderColorOverride: GameTokens.error,
      colorOverride: GameTokens.surface,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(GameTokens.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _FeedbackHeader(isSuccess: isSuccess, score: score),

                const SizedBox(height: GameTokens.spaceMd),
                GameDivider(),
                const SizedBox(height: GameTokens.spaceMd),

                // Main feedback message
                _FeedbackMessage(
                  report: report,
                  sandboxError: sandboxError,
                  isSuccess: isSuccess,
                  score: score,
                ),

                // Common mistake explainer
                if (!isSuccess && _hasCommonMistake())
                  _CommonMistakeCard(
                    mistake: _getCommonMistake()!,
                  ),

                // Achievement toasts
                if (newlyEarnedAchievements.isNotEmpty) ...[  
                  const SizedBox(height: GameTokens.spaceSm),
                  _AchievementUnlockedRow(
                    achievementIds: newlyEarnedAchievements,
                  ),
                ],

                if (offerDetectiveMode) ...[
                  const SizedBox(height: GameTokens.spaceMd),
                  _DetectiveModeOfferCard(
                    onAccept: () {
                      ref.read(gameplayProvider.notifier).enableDetectiveMode();
                      onDismiss();
                    },
                  ),
                ],

                const SizedBox(height: GameTokens.spaceMd),

                // CTAs
                _FeedbackActions(
                  onDismiss: onDismiss,
                  onRetry: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(
          begin: 1.0,
          end: 0.0,
          duration: GameTokens.durationNormal,
          curve: Curves.easeOut,
        );
  }

  bool _hasCommonMistake() {
    final key = report?.firstFailure.commonMistakeKey;
    return key != null && CommonMistakes.lookup(key) != null;
  }

  CommonMistake? _getCommonMistake() {
    final key = report?.firstFailure.commonMistakeKey;
    if (key == null) return null;
    return CommonMistakes.lookup(key);
  }
}

class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: GameTokens.error,
              size: 24,
            ).animate().scale(duration: 400.ms, curve: Curves.bounceOut),
            const SizedBox(width: GameTokens.spaceSm),
            Text(
              'NOT QUITE.',
              style: GameTokens.headlineLarge.copyWith(
                color: GameTokens.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackMessage extends StatelessWidget {
  final QueryValidationReport? report;
  final SandboxException? sandboxError;
  final bool isSuccess;
  final LevelScore? score;

  const _FeedbackMessage({
    this.report,
    this.sandboxError,
    required this.isSuccess,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    String message;

    if (sandboxError != null) {
      message = sandboxError!.toValidationResult().plainEnglishMessage ??
          sandboxError!.message;
    } else if (report == null) {
      message = 'No result yet.';
    } else {
      final failure = report!.firstFailure;
      message = failure.plainEnglishMessage ?? failure.errorMessage ?? 'Unknown error.';
    }

    // Diff summary (if result failed)
    if (report?.resultDiff != null) {
      message = report!.resultDiff!.plainEnglishSummary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlantedPanel(
          borderColorOverride: isSuccess ? GameTokens.success : GameTokens.error,
          colorOverride: isSuccess ? GameTokens.successSurface : GameTokens.errorSurface,
          padding: const EdgeInsets.all(GameTokens.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '> ',
                style: GameTokens.code.copyWith(
                  color: isSuccess ? GameTokens.success : GameTokens.error,
                ),
              ),
              Expanded(
                child: Text(message, style: GameTokens.bodyMedium),
              ),
              // Copy error message to clipboard
              if (!isSuccess) ...[
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message));
                  },
                  child: Tooltip(
                    message: 'Copy error message',
                    child: const Icon(Icons.copy_outlined,
                        color: GameTokens.secondaryText, size: 14),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CodexScreen(),
                      ),
                    );
                  },
                  child: Tooltip(
                    message: 'See in Codex',
                    child: const Icon(Icons.menu_book,
                        color: GameTokens.warning, size: 14),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Side-by-side diff view on failure
        if (!isSuccess && report?.resultDiff != null && report!.resultDiff!.missingRows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: GameTokens.spaceMd),
            child: _DiffTable(diff: report!.resultDiff!),
          ),
      ],
    );
  }
}

class _DiffTable extends StatelessWidget {
  final ResultDiff diff;
  const _DiffTable({required this.diff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXPECTED RESULT', style: GameTokens.bodySmall.copyWith(
          color: GameTokens.secondaryText,
          letterSpacing: 1.5,
        )),
        const SizedBox(height: GameTokens.spaceSm),
        SlantedPanel(
          borderColorOverride: GameTokens.info,
          colorOverride: GameTokens.surfaceVariant,
          padding: EdgeInsets.zero,
          child: diff.missingRows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(GameTokens.spaceMd),
                  child: Text('(no missing rows)', style: TextStyle(color: GameTokens.secondaryText)),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 28,
                    dataRowMinHeight: 24,
                    dataRowMaxHeight: 32,
                    headingTextStyle: GameTokens.codeSmall.copyWith(
                      color: GameTokens.info,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    dataTextStyle: GameTokens.codeSmall.copyWith(fontSize: 11),
                    dividerThickness: 0.5,
                    columns: diff.missingRows.first.keys
                        .map((col) => DataColumn(label: Text(col)))
                        .toList(),
                    rows: diff.missingRows.map((row) => DataRow(
                      color: WidgetStateProperty.all(GameTokens.info.withValues(alpha: 0.08)),
                      cells: row.values.map((val) => DataCell(
                        Text(val?.toString() ?? 'NULL'),
                      )).toList(),
                    )).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CommonMistakeCard extends StatelessWidget {
  final CommonMistake mistake;

  const _CommonMistakeCard({required this.mistake});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: GameTokens.spaceMd),
      child: SlantedPanel(
        borderColorOverride: GameTokens.warning,
        colorOverride: GameTokens.warningSurface,
        padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined,
                  color: GameTokens.warning, size: 14),
              const SizedBox(width: 6),
              Text(mistake.title,
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.warning,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(mistake.explanation, style: GameTokens.bodySmall),
          if (mistake.example != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GameTokens.surface,
                borderRadius: GameTokens.borderRadiusSm,
              ),
              child: Text(
                mistake.example!,
                style: GameTokens.codeSmall.copyWith(
                  color: GameTokens.accent,
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _StarBreakdown extends StatelessWidget {
  final LevelScore score;

  const _StarBreakdown({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STARS EARNED', style: GameTokens.bodySmall.copyWith(
          color: GameTokens.secondaryText,
          letterSpacing: 1.5,
        )),
        const SizedBox(height: GameTokens.spaceSm),
        _StarItem('Completion', score.completionStar),
        _StarItem('Optimal Query', score.optimalStar),
        _StarItem('First Attempt', score.firstAttemptStar),
        const SizedBox(height: GameTokens.spaceSm),
        // Big XP display
        Container(
          padding: const EdgeInsets.all(GameTokens.spaceMd),
          decoration: BoxDecoration(
            color: GameTokens.accent.withValues(alpha: 0.08),
            border: Border.all(color: GameTokens.accent.withValues(alpha: 0.3)),
            borderRadius: GameTokens.borderRadiusSm,
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: GameTokens.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '+${score.xpEarned} XP',
                style: GameTokens.headlineMedium.copyWith(
                  color: GameTokens.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (score.dailyBonusApplied) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameTokens.warning.withValues(alpha: 0.15),
                    borderRadius: GameTokens.borderRadiusSm,
                    border: Border.all(color: GameTokens.warning, width: 1),
                  ),
                  child: Text(
                    '2× DAILY',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.warning,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (score.hintCapApplied)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '(Full solution hint used — capped at 1 star)',
              style: GameTokens.bodySmall.copyWith(color: GameTokens.warning),
            ),
          ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _StarItem extends StatelessWidget {
  final String label;
  final bool earned;

  const _StarItem(this.label, this.earned);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            earned ? Icons.star_rounded : Icons.star_border_rounded,
            color: earned
                ? GameTokens.accent
                : GameTokens.disabledText,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GameTokens.bodySmall.copyWith(
              color: earned
                  ? GameTokens.primaryText
                  : GameTokens.disabledText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackActions extends ConsumerWidget {
  final bool isSuccess;
  final VoidCallback onDismiss;
  final VoidCallback? onNextLevel;
  final VoidCallback onRetry;

  const _FeedbackActions({
    required this.isSuccess,
    required this.onDismiss,
    this.onNextLevel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isSuccess) ...[
          TextButton(
            onPressed: onDismiss,
            child: Text('REVIEW QUERY',
                style: GameTokens.labelLarge.copyWith(
                  color: GameTokens.secondaryText,
                )),
          ),
          const SizedBox(width: GameTokens.spaceMd),
          ActionButton(
            isPrimary: true,
            onPressed: onRetry,
            child: const Text('RETRY'),
          ),
        ] else ...[
          if (onNextLevel != null)
            ActionButton(
              isPrimary: true,
              onPressed: onNextLevel,
              child: const Text('NEXT LEVEL'),
            ),
          const SizedBox(width: GameTokens.spaceSm),
          TextButton(
            onPressed: onDismiss,
            child: Text('REVIEW', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
          ),
          const SizedBox(width: GameTokens.spaceSm),
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: GameTokens.accent),
            tooltip: 'Watch Pro Solution',
            onPressed: () {
              final state = ref.read(gameplayProvider);
              if (state.level != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReplayScreen(level: state.level!),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: GameTokens.accent),
            onPressed: () {
              final state = ref.read(gameplayProvider);
              final level = state.level?.title ?? 'Unknown Case';
              final query = state.currentQuery.trim();
              
              final score = state.levelScore;
              final stars = score != null 
                  ? '⭐' * score.starCount + '☆' * (3 - score.starCount)
                  : '';
              final timeMedal = score?.timeMedal?.name.toUpperCase() ?? 'NO MEDAL';

              final text = '''
I just cracked the "$level" case in Query! 🔍

Score: $stars
Medal: $timeMedal

My Solution:
```sql
$query
```

Can you write a faster query? #QueryGame #SQL
''';
              // ignore: deprecated_member_use
              Share.share(text.trim());
            },
          ),
        ],
      ],
    );
  }
}

// ─── Achievement unlocked row ─────────────────────────────────────────────────

class _AchievementUnlockedRow extends StatelessWidget {
  final List<String> achievementIds;
  const _AchievementUnlockedRow({required this.achievementIds});

  static const _labels = <String, String>{
    'first_query': '🔍 First Query',
    'three_stars': '⭐ Three Stars',
    'no_hints': '🧠 No Hints',
    'speedrun': '⚡ Speedrun',
    'comeback': '🔥 Comeback',
    'perfect_optimization': '🏆 Perfect Optimizer',
  };

  static const _icons = <String, IconData>{
    'first_query': Icons.search,
    'three_stars': Icons.star,
    'no_hints': Icons.psychology_outlined,
    'speedrun': Icons.flash_on,
    'comeback': Icons.local_fire_department,
    'perfect_optimization': Icons.emoji_events,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACHIEVEMENT UNLOCKED',
          style: GameTokens.bodySmall.copyWith(
            color: GameTokens.warning,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: achievementIds.map((id) {
            final label = _labels[id] ?? id;
            final icon = _icons[id] ?? Icons.emoji_events;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: GameTokens.warning.withValues(alpha: 0.12),
                borderRadius: GameTokens.borderRadiusSm,
                border: Border.all(color: GameTokens.warning, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: GameTokens.warning, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3);
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Detective Mode Offer ─────────────────────────────────────────────────────

class _DetectiveModeOfferCard extends StatelessWidget {
  final VoidCallback onAccept;
  const _DetectiveModeOfferCard({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return SlantedPanel(
      borderColorOverride: GameTokens.warning,
      colorOverride: GameTokens.warningSurface,
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search_outlined, color: GameTokens.warning, size: 16),
              const SizedBox(width: 8),
              Text(
                'DETECTIVE MODE AVAILABLE',
                style: GameTokens.headlineMedium.copyWith(color: GameTokens.warning),
              ),
            ],
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Text(
            'Stuck? Enter Detective Mode to get a partially complete starter query, but the database schema will be redacted.',
            style: GameTokens.bodyMedium,
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Align(
            alignment: Alignment.centerRight,
            child: ActionButton(
              isPrimary: true,
              onPressed: onAccept,
              child: const Text('ENABLE DETECTIVE MODE'),
            ),
          ),
        ],
      ),
    );
  }
}
