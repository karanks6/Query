import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/validation/validation_result.dart';
import '../../core/sandbox_engine/sandbox_engine.dart';
import '../../core/scoring/level_scorer.dart';
import '../../core/validation/common_mistakes.dart';

/// Feedback overlay (Section 5.6).
///
/// Surfaces the 4-layer feedback loop without leaving gameplay context.
/// Shows on top of the Gameplay Screen as a bottom sheet.
class FeedbackOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isSuccess = report?.isComplete ?? false;
    final accentColor = isSuccess
        ? GameTokens.success
        : GameTokens.error;

    return SlantedPanel(
      borderColorOverride: accentColor,
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

                const SizedBox(height: GameTokens.spaceMd),

                // Star breakdown (on success)
                if (isSuccess && score != null)
                  _StarBreakdown(score: score!),

                const SizedBox(height: GameTokens.spaceLg),

                // CTAs
                _FeedbackActions(
                  isSuccess: isSuccess,
                  onDismiss: onDismiss,
                  onNextLevel: onNextLevel,
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
  final bool isSuccess;
  final LevelScore? score;

  const _FeedbackHeader({required this.isSuccess, this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isSuccess ? GameTokens.success : GameTokens.error,
              size: 24,
            )
                .animate(target: isSuccess ? 1 : 0)
                .scale(duration: 400.ms, curve: Curves.bounceOut),
            const SizedBox(width: GameTokens.spaceSm),
            Text(
              isSuccess ? 'CASE CRACKED!' : 'NOT QUITE.',
              style: GameTokens.headlineLarge.copyWith(
                color: isSuccess ? GameTokens.success : GameTokens.error,
              ),
            ),
          ],
        ),
        // Animated star pop-in on success
        if (isSuccess && score != null) ...[
          const SizedBox(height: GameTokens.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final earned = i < score!.starCount;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  earned ? Icons.star_rounded : Icons.star_border_rounded,
                  color: earned ? GameTokens.accent : GameTokens.disabledText,
                  size: 40,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      delay: (400 + i * 200).ms,
                      duration: 350.ms,
                      curve: Curves.bounceOut,
                    )
                    .fadeIn(delay: (400 + i * 200).ms, duration: 200.ms),
              );
            }),
          ),
          // Time medal row
          if (score!.timeMedal != null)
            Padding(
              padding: const EdgeInsets.only(top: GameTokens.spaceSm),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _medalColor(score!.timeMedal!).withValues(alpha: 0.15),
                    border: Border.all(color: _medalColor(score!.timeMedal!)),
                    borderRadius: GameTokens.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined,
                          color: _medalColor(score!.timeMedal!), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${score!.timeMedal!.name.toUpperCase()} TIME MEDAL  +${score!.timeMedal!.xpBonus} XP',
                        style: GameTokens.bodySmall.copyWith(
                          color: _medalColor(score!.timeMedal!),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
              ),
            ),
        ],
      ],
    );
  }

  Color _medalColor(TimeMedal medal) {
    switch (medal) {
      case TimeMedal.gold:
        return GameTokens.warning;
      case TimeMedal.silver:
        return const Color(0xFFB0BEC5);
      case TimeMedal.bronze:
        return const Color(0xFFBF8A60);
    }
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

  static const _successMessages = [
    'Your query returned the correct result. Well done, Agent.',
    'Case closed. Impeccable work, Detective.',
    'Query executed flawlessly. The Bureau is impressed.',
    'Target data extracted. Another case in the books.',
    'Textbook execution. The Archive is updated.',
  ];

  static const _successMessages3Stars = [
    'Perfect execution. You\'re a senior analyst in the making.',
    'Flawless. Not a single clause out of place.',
    'Outstanding. You handled that like a field veteran.',
  ];

  static const _successMessagesHint = [
    'Case closed — but your methods raised some eyebrows at the Bureau.',
    'Query solved, though the hint logs will be reviewed.',
    'Result correct. The full solution hint won\'t appear in your official record.',
  ];

  @override
  Widget build(BuildContext context) {
    String message;

    if (sandboxError != null) {
      message = sandboxError!.toValidationResult().plainEnglishMessage ??
          sandboxError!.message;
    } else if (report == null) {
      message = 'No result yet.';
    } else if (isSuccess) {
      final hintUsed = score?.hintCapApplied ?? false;
      final perfect = (score?.starCount ?? 0) == 3;
      final pool = perfect && !hintUsed
          ? _successMessages3Stars
          : hintUsed
              ? _successMessagesHint
              : _successMessages;
      message = pool[(pool.length * DateTime.now().millisecond ~/ 1000).clamp(0, pool.length - 1)];
      if (report!.efficiencyScore != null) {
        final pct = (report!.efficiencyScore! * 100).toStringAsFixed(0);
        message += '\nEfficiency: $pct%';
      }
    } else {
      final failure = report!.firstFailure;
      message = failure.plainEnglishMessage ?? failure.errorMessage ?? 'Unknown error.';
    }

    // Diff summary (if result failed)
    if (!isSuccess && report?.resultDiff != null) {
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
              if (!isSuccess)
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

class _FeedbackActions extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.share, color: GameTokens.accent),
            onPressed: () {
              // ignore: deprecated_member_use
              Share.share('I just cracked a SQL case in Query!\nLevel passed with flying colors. #QueryGame #SQL');
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
