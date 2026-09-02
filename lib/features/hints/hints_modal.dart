import 'package:flutter/material.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../theming/components/holo_button.dart';
import '../../data/content/models/level_model.dart';
import '../../core/scoring/level_scorer.dart';

/// 3-tier hint modal (Section 5.7).
///
/// Tiers: Nudge → Partial Reveal → Full Solution
/// - Each tier must be used in order before the next unlocks
/// - Shows Insight Point cost up front
/// - After 3 failed attempts: grace hint (Nudge for free)
/// - Full solution caps star rating at 1 star
class HintsModal extends StatefulWidget {
  final List<HintModel> hints;
  final HintTier highestUsed;
  final int attemptCount;
  final ValueChanged<HintTier> onHintUsed;

  const HintsModal({
    super.key,
    required this.hints,
    required this.highestUsed,
    required this.attemptCount,
    required this.onHintUsed,
  });

  @override
  State<HintsModal> createState() => _HintsModalState();
}

class _HintsModalState extends State<HintsModal> {
  HintTier? _revealedTier;

  bool get _graceHintAvailable => widget.attemptCount >= 3;

  List<HintModel> get _hints => widget.hints;

  HintModel? _hintForTier(HintTierType tier) {
    try {
      return _hints.firstWhere((h) => h.tier == tier);
    } catch (_) {
      return null;
    }
  }

  bool _isUnlocked(HintTierType tier) {
    switch (tier) {
      case HintTierType.nudge:
        return true; // Always accessible
      case HintTierType.partialReveal:
        return widget.highestUsed.index >= HintTier.nudge.index;
      case HintTierType.fullSolution:
        return widget.highestUsed.index >= HintTier.partialReveal.index;
    }
  }

  void _revealHint(HintTierType tier, HintModel hint) {
    setState(() => _revealedTier = _hintTierFromType(tier));

    // Notify parent (for scoring / insight point tracking)
    widget.onHintUsed(_hintTierFromType(tier));
  }

  HintTier _hintTierFromType(HintTierType type) {
    switch (type) {
      case HintTierType.nudge:
        return HintTier.nudge;
      case HintTierType.partialReveal:
        return HintTier.partialReveal;
      case HintTierType.fullSolution:
        return HintTier.fullSolution;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(SciFiTokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: SciFiTokens.warning, size: 20),
                const SizedBox(width: SciFiTokens.spaceSm),
                Text('HINTS', style: SciFiTokens.headlineMedium),
                const Spacer(),
                if (_graceHintAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: SciFiTokens.accent, width: 1),
                      borderRadius: SciFiTokens.borderRadiusSm,
                    ),
                    child: Text(
                      'GRACE HINT ACTIVE',
                      style: SciFiTokens.bodySmall.copyWith(
                        color: SciFiTokens.accent,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SciFiTokens.spaceMd),
            Text(
              'Hints cost Insight Points. Using a Full Solution caps your rating at 1 star.',
              style: SciFiTokens.bodySmall.copyWith(
                color: SciFiTokens.secondaryText,
              ),
            ),
            const SizedBox(height: SciFiTokens.spaceLg),

            // Hint tiers
            for (final tier in HintTierType.values)
              _HintTierRow(
                tier: tier,
                hint: _hintForTier(tier),
                isUnlocked: _isUnlocked(tier),
                isFree: tier == HintTierType.nudge && _graceHintAvailable,
                isRevealed: _revealedTier?.index != null &&
                    _revealedTier!.index >= _hintTierFromType(tier).index,
                onReveal: (hint) => _revealHint(tier, hint),
              ),

            const SizedBox(height: SciFiTokens.spaceSm),
          ],
        ),
      ),
    );
  }
}

class _HintTierRow extends StatelessWidget {
  final HintTierType tier;
  final HintModel? hint;
  final bool isUnlocked;
  final bool isFree;
  final bool isRevealed;
  final ValueChanged<HintModel> onReveal;

  const _HintTierRow({
    required this.tier,
    required this.hint,
    required this.isUnlocked,
    required this.isFree,
    required this.isRevealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final tierLabel = switch (tier) {
      HintTierType.nudge => '1 — NUDGE',
      HintTierType.partialReveal => '2 — PARTIAL REVEAL',
      HintTierType.fullSolution => '3 — FULL SOLUTION',
    };

    final cost = isFree ? 'FREE' : '${tier.insightPointCost} IP';
    final warningText = tier == HintTierType.fullSolution
        ? 'Using this caps your rating at ★ only.'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: SciFiTokens.spaceSm),
      child: HoloPanel(
        emissionIntensity: 0.15,
        borderColorOverride: isUnlocked
              ? SciFiTokens.accentDim
              : SciFiTokens.disabledText,
        colorOverride: SciFiTokens.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SciFiTokens.spaceMd,
              vertical: SciFiTokens.spaceSm,
            ),
            child: Row(
              children: [
                Text(
                  tierLabel,
                  style: SciFiTokens.bodySmall.copyWith(
                    color: isUnlocked
                        ? SciFiTokens.accent
                        : SciFiTokens.disabledText,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                if (!isUnlocked)
                  const Icon(Icons.lock_outline,
                      color: SciFiTokens.disabledText, size: 14)
                else if (!isRevealed && hint != null)
                  HoloButton(
                    onPressed: () => onReveal(hint!),
                    isPrimary: true,
                    child: Text(
                      'REVEAL — $cost',
                      style: SciFiTokens.bodySmall.copyWith(
                        color: SciFiTokens.background,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    '[ REVEALED ]',
                    style: SciFiTokens.bodySmall.copyWith(
                      color: SciFiTokens.secondaryText,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),

          // Warning for full solution
          if (warningText != null && isUnlocked && !isRevealed)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SciFiTokens.spaceMd,
              ),
              child: Text(
                warningText,
                style: SciFiTokens.bodySmall.copyWith(
                  color: SciFiTokens.warning,
                  fontSize: 10,
                ),
              ),
            ),

          // Revealed content
          if (isRevealed && hint != null) ...[
            const Divider(
              color: SciFiTokens.accentDim,
              height: 1,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(SciFiTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hint!.content, style: SciFiTokens.bodyMedium),
                  if (hint!.codeSnippet != null) ...[
                    const SizedBox(height: SciFiTokens.spaceSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SciFiTokens.spaceSm),
                      decoration: BoxDecoration(
                        color: SciFiTokens.surface,
                        borderRadius: SciFiTokens.borderRadiusSm,
                        border: Border.all(
                            color: SciFiTokens.accentDim, width: 1),
                      ),
                      child: Text(
                        hint!.codeSnippet!,
                        style: SciFiTokens.code.copyWith(
                          color: SciFiTokens.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
