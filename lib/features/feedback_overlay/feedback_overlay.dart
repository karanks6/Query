import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../shared/widgets/terminal_widgets.dart';
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

  const FeedbackOverlay({
    super.key,
    this.report,
    this.sandboxError,
    this.score,
    required this.onDismiss,
    this.onNextLevel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = report?.isComplete ?? false;
    final accentColor = isSuccess
        ? TerminalClassicTokens.success
        : TerminalClassicTokens.error;

    return Container(
      decoration: BoxDecoration(
        color: TerminalClassicTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border.all(color: accentColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(TerminalClassicTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _FeedbackHeader(isSuccess: isSuccess, score: score),

              const SizedBox(height: TerminalClassicTokens.spaceMd),
              TerminalDivider(),
              const SizedBox(height: TerminalClassicTokens.spaceMd),

              // Main feedback message
              _FeedbackMessage(
                report: report,
                sandboxError: sandboxError,
                isSuccess: isSuccess,
              ),

              // Common mistake explainer
              if (!isSuccess && _hasCommonMistake())
                _CommonMistakeCard(
                  mistake: _getCommonMistake()!,
                ),

              const SizedBox(height: TerminalClassicTokens.spaceMd),

              // Star breakdown (on success)
              if (isSuccess && score != null)
                _StarBreakdown(score: score!),

              const SizedBox(height: TerminalClassicTokens.spaceLg),

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
    ).animate().slideY(
          begin: 1.0,
          end: 0.0,
          duration: TerminalClassicTokens.durationNormal,
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
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: isSuccess
              ? TerminalClassicTokens.success
              : TerminalClassicTokens.error,
          size: 24,
        )
            .animate(target: isSuccess ? 1 : 0)
            .scale(duration: 400.ms, curve: Curves.bounceOut),
        const SizedBox(width: TerminalClassicTokens.spaceSm),
        Text(
          isSuccess ? 'CASE CRACKED!' : 'NOT QUITE.',
          style: TerminalClassicTokens.headlineLarge.copyWith(
            color: isSuccess
                ? TerminalClassicTokens.success
                : TerminalClassicTokens.error,
          ),
        ),
        if (isSuccess && score != null) ...[
          const Spacer(),
          StarRow(starCount: score!.starCount),
        ],
      ],
    );
  }
}

class _FeedbackMessage extends StatelessWidget {
  final QueryValidationReport? report;
  final SandboxException? sandboxError;
  final bool isSuccess;

  const _FeedbackMessage({
    this.report,
    this.sandboxError,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    String message;

    if (sandboxError != null) {
      message = sandboxError!.toValidationResult().plainEnglishMessage ??
          sandboxError!.message;
    } else if (report == null) {
      message = 'No result yet.';
    } else if (isSuccess) {
      message = 'Your query returned the correct result. Well done, Agent.';
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

    return Container(
      padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
      decoration: BoxDecoration(
        color: isSuccess
            ? TerminalClassicTokens.successSurface
            : TerminalClassicTokens.errorSurface,
        borderRadius: TerminalClassicTokens.borderRadiusSm,
        border: Border.all(
          color: isSuccess
              ? TerminalClassicTokens.success
              : TerminalClassicTokens.error,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '> ',
            style: TerminalClassicTokens.code.copyWith(
              color: isSuccess
                  ? TerminalClassicTokens.success
                  : TerminalClassicTokens.error,
            ),
          ),
          Expanded(
            child: Text(
              message,
              style: TerminalClassicTokens.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommonMistakeCard extends StatelessWidget {
  final CommonMistake mistake;

  const _CommonMistakeCard({required this.mistake});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: TerminalClassicTokens.spaceMd),
      padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
      decoration: BoxDecoration(
        color: TerminalClassicTokens.warningSurface,
        borderRadius: TerminalClassicTokens.borderRadiusSm,
        border: Border.all(color: TerminalClassicTokens.warning, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined,
                  color: TerminalClassicTokens.warning, size: 14),
              const SizedBox(width: 6),
              Text(mistake.title,
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.warning,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(mistake.explanation, style: TerminalClassicTokens.bodySmall),
          if (mistake.example != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TerminalClassicTokens.surface,
                borderRadius: TerminalClassicTokens.borderRadiusSm,
              ),
              child: Text(
                mistake.example!,
                style: TerminalClassicTokens.codeSmall.copyWith(
                  color: TerminalClassicTokens.accent,
                ),
              ),
            ),
          ],
        ],
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
        Text('STARS EARNED', style: TerminalClassicTokens.bodySmall.copyWith(
          color: TerminalClassicTokens.secondaryText,
          letterSpacing: 1.5,
        )),
        const SizedBox(height: TerminalClassicTokens.spaceSm),
        _StarItem('Completion', score.completionStar),
        _StarItem('Optimal Query', score.optimalStar),
        _StarItem('First Attempt', score.firstAttemptStar),
        const SizedBox(height: 4),
        Text(
          '+${score.xpEarned} XP earned',
          style: TerminalClassicTokens.bodySmall.copyWith(
            color: TerminalClassicTokens.accent,
          ),
        ),
        if (score.hintCapApplied)
          Text(
            '(Full solution hint used â€” capped at 1 star)',
            style: TerminalClassicTokens.bodySmall.copyWith(
              color: TerminalClassicTokens.warning,
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
                ? TerminalClassicTokens.accent
                : TerminalClassicTokens.disabledText,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TerminalClassicTokens.bodySmall.copyWith(
              color: earned
                  ? TerminalClassicTokens.primaryText
                  : TerminalClassicTokens.disabledText,
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
          OutlinedButton(
            onPressed: onDismiss,
            child: Text('REVIEW QUERY',
                style: TerminalClassicTokens.labelLarge.copyWith(
                  color: TerminalClassicTokens.secondaryText,
                )),
          ),
          const SizedBox(width: TerminalClassicTokens.spaceMd),
          TerminalButton(label: 'RETRY', onPressed: onRetry),
        ] else ...[
          if (onNextLevel != null)
            TerminalButton(label: 'NEXT LEVEL', onPressed: onNextLevel),
          const SizedBox(width: TerminalClassicTokens.spaceSm),
          OutlinedButton(
            onPressed: onDismiss,
            child: Text('REVIEW', style: TerminalClassicTokens.labelLarge),
          ),
        ],
      ],
    );
  }
}
