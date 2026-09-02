import 'package:flutter/material.dart';
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
        ? GameTokens.success
        : GameTokens.error;

    return SlantedPanel(
      borderColorOverride: accentColor,
      colorOverride: GameTokens.surface,
      child: SafeArea(
        top: false,
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
              ),

              // Common mistake explainer
              if (!isSuccess && _hasCommonMistake())
                _CommonMistakeCard(
                  mistake: _getCommonMistake()!,
                ),

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
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: isSuccess
              ? GameTokens.success
              : GameTokens.error,
          size: 24,
        )
            .animate(target: isSuccess ? 1 : 0)
            .scale(duration: 400.ms, curve: Curves.bounceOut),
        const SizedBox(width: GameTokens.spaceSm),
        Text(
          isSuccess ? 'CASE CRACKED!' : 'NOT QUITE.',
          style: GameTokens.headlineLarge.copyWith(
            color: isSuccess
                ? GameTokens.success
                : GameTokens.error,
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

    return SlantedPanel(
      borderColorOverride: isSuccess ? GameTokens.success : GameTokens.error,
      colorOverride: isSuccess ? GameTokens.successSurface : GameTokens.errorSurface,
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '> ',
            style: GameTokens.code.copyWith(
              color: isSuccess
                  ? GameTokens.success
                  : GameTokens.error,
            ),
          ),
          Expanded(
            child: Text(
              message,
              style: GameTokens.bodyMedium,
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
        const SizedBox(height: 4),
        Text(
          '+${score.xpEarned} XP earned',
          style: GameTokens.bodySmall.copyWith(
            color: GameTokens.accent,
          ),
        ),
        if (score.hintCapApplied)
          Text(
            '(Full solution hint used ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â capped at 1 star)',
            style: GameTokens.bodySmall.copyWith(
              color: GameTokens.warning,
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
