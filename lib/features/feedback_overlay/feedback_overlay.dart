import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../theming/components/holo_button.dart';
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
        ? SciFiTokens.success
        : SciFiTokens.error;

    return HoloPanel(
      emissionIntensity: 0.6,
      borderColorOverride: accentColor,
      glowColorOverride: accentColor,
      colorOverride: SciFiTokens.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(SciFiTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _FeedbackHeader(isSuccess: isSuccess, score: score),

              const SizedBox(height: SciFiTokens.spaceMd),
              TerminalDivider(),
              const SizedBox(height: SciFiTokens.spaceMd),

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

              const SizedBox(height: SciFiTokens.spaceMd),

              // Star breakdown (on success)
              if (isSuccess && score != null)
                _StarBreakdown(score: score!),

              const SizedBox(height: SciFiTokens.spaceLg),

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
          duration: SciFiTokens.durationNormal,
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
              ? SciFiTokens.success
              : SciFiTokens.error,
          size: 24,
        )
            .animate(target: isSuccess ? 1 : 0)
            .scale(duration: 400.ms, curve: Curves.bounceOut),
        const SizedBox(width: SciFiTokens.spaceSm),
        Text(
          isSuccess ? 'CASE CRACKED!' : 'NOT QUITE.',
          style: SciFiTokens.headlineLarge.copyWith(
            color: isSuccess
                ? SciFiTokens.success
                : SciFiTokens.error,
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

    return HoloPanel(
      emissionIntensity: 0.2,
      borderColorOverride: isSuccess ? SciFiTokens.success : SciFiTokens.error,
      colorOverride: isSuccess ? SciFiTokens.successSurface : SciFiTokens.errorSurface,
      padding: const EdgeInsets.all(SciFiTokens.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '> ',
            style: SciFiTokens.code.copyWith(
              color: isSuccess
                  ? SciFiTokens.success
                  : SciFiTokens.error,
            ),
          ),
          Expanded(
            child: Text(
              message,
              style: SciFiTokens.bodyMedium,
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
      padding: const EdgeInsets.only(top: SciFiTokens.spaceMd),
      child: HoloPanel(
        emissionIntensity: 0.2,
        borderColorOverride: SciFiTokens.warning,
        colorOverride: SciFiTokens.warningSurface,
        padding: const EdgeInsets.all(SciFiTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined,
                  color: SciFiTokens.warning, size: 14),
              const SizedBox(width: 6),
              Text(mistake.title,
                  style: SciFiTokens.bodySmall.copyWith(
                    color: SciFiTokens.warning,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(mistake.explanation, style: SciFiTokens.bodySmall),
          if (mistake.example != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SciFiTokens.surface,
                borderRadius: SciFiTokens.borderRadiusSm,
              ),
              child: Text(
                mistake.example!,
                style: SciFiTokens.codeSmall.copyWith(
                  color: SciFiTokens.accent,
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
        Text('STARS EARNED', style: SciFiTokens.bodySmall.copyWith(
          color: SciFiTokens.secondaryText,
          letterSpacing: 1.5,
        )),
        const SizedBox(height: SciFiTokens.spaceSm),
        _StarItem('Completion', score.completionStar),
        _StarItem('Optimal Query', score.optimalStar),
        _StarItem('First Attempt', score.firstAttemptStar),
        const SizedBox(height: 4),
        Text(
          '+${score.xpEarned} XP earned',
          style: SciFiTokens.bodySmall.copyWith(
            color: SciFiTokens.accent,
          ),
        ),
        if (score.hintCapApplied)
          Text(
            '(Full solution hint used â€” capped at 1 star)',
            style: SciFiTokens.bodySmall.copyWith(
              color: SciFiTokens.warning,
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
                ? SciFiTokens.accent
                : SciFiTokens.disabledText,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: SciFiTokens.bodySmall.copyWith(
              color: earned
                  ? SciFiTokens.primaryText
                  : SciFiTokens.disabledText,
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
                style: SciFiTokens.labelLarge.copyWith(
                  color: SciFiTokens.secondaryText,
                )),
          ),
          const SizedBox(width: SciFiTokens.spaceMd),
          HoloButton(
            isPrimary: true,
            onPressed: onRetry,
            child: const Text('RETRY'),
          ),
        ] else ...[
          if (onNextLevel != null)
            HoloButton(
              isPrimary: true,
              onPressed: onNextLevel,
              child: const Text('NEXT LEVEL'),
            ),
          const SizedBox(width: SciFiTokens.spaceSm),
          TextButton(
            onPressed: onDismiss,
            child: Text('REVIEW', style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText)),
          ),
          const SizedBox(width: SciFiTokens.spaceSm),
          IconButton(
            icon: Icon(Icons.share, color: SciFiTokens.accent),
            onPressed: () {
              Share.share('I just cracked a SQL case in Query!\nLevel passed with flying colors. #QueryGame #SQL');
            },
          ),
        ],
      ],
    );
  }
}
