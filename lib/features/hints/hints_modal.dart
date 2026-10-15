import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../data/content/models/level_model.dart';
import '../../core/scoring/level_scorer.dart';
import '../../core/providers.dart';

/// 3-tier hint modal (Section 5.7).
///
/// Tiers: Nudge → Partial Reveal → Full Solution
/// - Each tier must be used in order before the next unlocks
/// - Shows XP cost up front
/// - Real-time XP balance in the top right corner
/// - Turns red when balance is insufficient
/// - After 3 failed attempts: grace hint (Nudge for free)
/// - Full solution caps star rating at 1 star
class HintsModal extends ConsumerStatefulWidget {
  final List<HintModel> hints;
  final HintTier highestUsed;
  final int attemptCount;
  final Future<bool> Function(HintTier) onHintUsed;

  const HintsModal({
    super.key,
    required this.hints,
    required this.highestUsed,
    required this.attemptCount,
    required this.onHintUsed,
  });

  @override
  ConsumerState<HintsModal> createState() => _HintsModalState();
}

class _HintsModalState extends ConsumerState<HintsModal> {
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

  void _revealHint(HintTierType tier, HintModel hint, int cost, int currentBalance) async {
    if (cost > 0 && currentBalance < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance! You have $currentBalance XP, but need $cost XP.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final hintTier = _hintTierFromType(tier);
    final success = await widget.onHintUsed(hintTier);
    if (success && mounted) {
      setState(() => _revealedTier = hintTier);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough XP to reveal this hint.', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF3A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    final profileAsync = ref.watch(playerProfileProvider);
    final profile = profileAsync.valueOrNull;
    final int xpBalance = profile?.totalXp ?? (profile?.insightPoints ?? 0);

    // Determine the next active hint tier to evaluate balance sufficiency
    HintTierType? activeTier;
    for (final tier in HintTierType.values) {
      final isUnlocked = _isUnlocked(tier);
      final isRevealed = _revealedTier?.index != null &&
          _revealedTier!.index >= _hintTierFromType(tier).index;
      if (isUnlocked && !isRevealed) {
        activeTier = tier;
        break;
      }
    }

    final isGrace = activeTier == HintTierType.nudge && _graceHintAvailable;
    final activeCost = isGrace ? 0 : (activeTier?.insightPointCost ?? 0);
    final isTopBalanceInsufficient = activeTier != null && !isGrace && (xpBalance < activeCost);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(GameTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Real-time XP Balance at top right corner
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: GameTokens.warning, size: 20),
                  const SizedBox(width: GameTokens.spaceSm),
                  Text('HINTS', style: GameTokens.headlineMedium),
                  const Spacer(),
                  if (_graceHintAvailable) ...[
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
                    const SizedBox(width: 8),
                  ],
                  // Top Right XP Balance Badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isTopBalanceInsufficient
                          ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                          : GameTokens.accent.withValues(alpha: 0.12),
                      border: Border.all(
                        color: isTopBalanceInsufficient
                            ? const Color(0xFFDC2626)
                            : GameTokens.accent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 15,
                          color: isTopBalanceInsufficient
                              ? const Color(0xFFDC2626)
                              : GameTokens.accent,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$xpBalance XP',
                          style: GameTokens.bodyMedium.copyWith(
                            color: isTopBalanceInsufficient
                                ? const Color(0xFFDC2626)
                                : GameTokens.accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameTokens.spaceMd),
              Text(
                'Hints cost XP. Using a Full Solution caps your rating at 1 star.',
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
                  xpBalance: xpBalance,
                  onReveal: (hint, cost) => _revealHint(tier, hint, cost, xpBalance),
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
  final int xpBalance;
  final void Function(HintModel hint, int cost) onReveal;

  const _HintTierRow({
    required this.tier,
    required this.hint,
    required this.isUnlocked,
    required this.isFree,
    required this.isRevealed,
    required this.xpBalance,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final tierLabel = switch (tier) {
      HintTierType.nudge => '1 — NUDGE',
      HintTierType.partialReveal => '2 — PARTIAL REVEAL',
      HintTierType.fullSolution => '3 — FULL SOLUTION',
    };

    final cost = isFree ? 'FREE' : '${tier.insightPointCost} XP';
    final int costInt = isFree ? 0 : tier.insightPointCost;
    final bool isInsufficient = !isFree && (xpBalance < costInt);

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
                          : GameTokens.secondaryText.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  if (!isUnlocked)
                    Icon(Icons.lock_outline,
                        color: GameTokens.secondaryText.withValues(alpha: 0.6), size: 14)
                  else if (!isRevealed && hint != null)
                    ActionButton(
                      onPressed: () => onReveal(hint!, costInt),
                      isPrimary: !isInsufficient,
                      colorOverride: isInsufficient ? const Color(0xFFDC2626) : null,
                      borderColorOverride: isInsufficient ? const Color(0xFFEF4444) : null,
                      textColorOverride: isInsufficient ? Colors.white : null,
                      child: Text(
                        'REVEAL — $cost',
                        style: GameTokens.bodySmall.copyWith(
                          color: isInsufficient ? Colors.white : GameTokens.background,
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
