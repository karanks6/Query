import 'package:flutter/material.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(GameTokens.spaceLg),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: GameTokens.warning, size: 20),
                const SizedBox(width: GameTokens.spaceSm),
                Text('HINTS', style: GameTokens.headlineMedium),
                const Spacer(),
                if (_graceHintAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: GameTokens.accent, width: 1),
                      borderRadius: GameTokens.borderRadiusSm,
                    ),
                    child: Text(
                      'GRACE HINT ACTIVE',
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.accent,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: GameTokens.spaceMd),
            Text(
              'Hints cost Insight Points. Using a Full Solution caps your rating at 1 star.',
              style: GameTokens.bodySmall.copyWith(
                color: GameTokens.secondaryText,
              ),
            ),
            const SizedBox(height: GameTokens.spaceLg),

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

            const SizedBox(height: GameTokens.spaceSm),
          ],
        ),
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
      HintTierType.nudge => '1 Ã¢â‚¬â€ NUDGE',
      HintTierType.partialReveal => '2 Ã¢â‚¬â€ PARTIAL REVEAL',
      HintTierType.fullSolution => '3 Ã¢â‚¬â€ FULL SOLUTION',
    };

    final cost = isFree ? 'FREE' : '${tier.insightPointCost} IP';
    final warningText = tier == HintTierType.fullSolution
        ? 'Using this caps your rating at ★ only.'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: GameTokens.spaceSm),
      child: SlantedPanel(
        borderColorOverride: isUnlocked
              ? GameTokens.accentDim
              : GameTokens.disabledText,
        colorOverride: GameTokens.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceMd,
              vertical: GameTokens.spaceSm,
            ),
            child: Row(
              children: [
                Text(
                  tierLabel,
                  style: GameTokens.bodySmall.copyWith(
                    color: isUnlocked
                        ? GameTokens.accent
                        : GameTokens.disabledText,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                if (!isUnlocked)
                  const Icon(Icons.lock_outline,
                      color: GameTokens.disabledText, size: 14)
                else if (!isRevealed && hint != null)
                  ActionButton(
                    onPressed: () => onReveal(hint!),
                    isPrimary: true,
                    child: Text(
                      'REVEAL Ã¢â‚¬â€ $cost',
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.background,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    '[ REVEALED ]',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.secondaryText,
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
                horizontal: GameTokens.spaceMd,
              ),
              child: Text(
                warningText,
                style: GameTokens.bodySmall.copyWith(
                  color: GameTokens.warning,
                  fontSize: 10,
                ),
              ),
            ),

          // Revealed content
          if (isRevealed && hint != null) ...[
            const Divider(
              color: GameTokens.accentDim,
              height: 1,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(GameTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hint!.content, style: GameTokens.bodyMedium),
                  if (hint!.codeSnippet != null) ...[
                    const SizedBox(height: GameTokens.spaceSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(GameTokens.spaceSm),
                      decoration: BoxDecoration(
                        color: GameTokens.surface,
                        borderRadius: GameTokens.borderRadiusSm,
                        border: Border.all(
                            color: GameTokens.accentDim, width: 1),
                      ),
                      child: Text(
                        hint!.codeSnippet!,
                        style: GameTokens.code.copyWith(
                          color: GameTokens.accent,
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
