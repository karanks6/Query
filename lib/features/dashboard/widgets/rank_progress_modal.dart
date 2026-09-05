import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../data/content/models/rank_system.dart';
import '../../../shared/widgets/rank_badge.dart';
import '../../../core/providers.dart';

class RankProgressModal extends ConsumerWidget {
  const RankProgressModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);

    return Container(
      padding: const EdgeInsets.all(GameTokens.spaceLg),
      decoration: const BoxDecoration(
        color: GameTokens.panelBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading profile')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();

          final currentRank = RankSystem.getRankForXp(profile.totalXp);
          final currentIndex = RankSystem.tiers.indexOf(currentRank);
          
          final nextRank = currentIndex < RankSystem.tiers.length - 1 
              ? RankSystem.tiers[currentIndex + 1] 
              : null;
              
          final xpForCurrent = currentRank.requiredXp;
          final xpForNext = nextRank?.requiredXp ?? currentRank.requiredXp;
          final progress = nextRank != null 
              ? (profile.totalXp - xpForCurrent) / (xpForNext - xpForCurrent)
              : 1.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GameTokens.secondaryText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: GameTokens.spaceXl),
              
              // Current Rank Highlight
              Center(
                child: RankBadge(
                  rank: currentRank,
                  size: 100,
                ),
              ),
              const SizedBox(height: GameTokens.spaceLg),
              Text(
                currentRank.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: GameTokens.headlineMedium.copyWith(color: currentRank.color),
              ),
              const SizedBox(height: GameTokens.spaceSm),
              Text(
                '${profile.totalXp} XP',
                textAlign: TextAlign.center,
                style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText),
              ),
              const SizedBox(height: GameTokens.spaceLg),
              
              // Progress Bar
              if (nextRank != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${currentRank.requiredXp} XP', style: GameTokens.bodySmall),
                    Text('${nextRank.requiredXp} XP', style: GameTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: GameTokens.spaceXs),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: GameTokens.background,
                  color: nextRank.color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: GameTokens.spaceSm),
                Text(
                  '${nextRank.requiredXp - profile.totalXp} XP until ${nextRank.title}',
                  textAlign: TextAlign.center,
                  style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText),
                ),
              ],
              
              const SizedBox(height: GameTokens.spaceXl),
              Text(
                'ALL RANKS',
                style: GameTokens.labelLarge,
              ),
              const SizedBox(height: GameTokens.spaceMd),
              
              // Rank Timeline
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: RankSystem.tiers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: GameTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final tier = RankSystem.tiers[index];
                    final isUnlocked = profile.totalXp >= tier.requiredXp;
                    final isCurrent = tier == currentRank;
                    
                    return Container(
                      padding: const EdgeInsets.all(GameTokens.spaceMd),
                      decoration: BoxDecoration(
                        color: isCurrent 
                            ? tier.color.withValues(alpha: 0.1) 
                            : GameTokens.background,
                        border: Border.all(
                          color: isCurrent ? tier.color : GameTokens.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: isUnlocked ? 1.0 : 0.3,
                            child: RankBadge(
                              rank: tier,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: GameTokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tier.title,
                                  style: GameTokens.bodyMedium.copyWith(
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    color: isUnlocked ? GameTokens.primaryText : GameTokens.secondaryText,
                                  ),
                                ),
                                Text(
                                  '${tier.requiredXp} XP',
                                  style: GameTokens.bodySmall.copyWith(
                                    color: isUnlocked ? tier.color : GameTokens.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            const Icon(Icons.check_circle, color: GameTokens.success)
                          else if (!isUnlocked)
                            const Icon(Icons.lock_outline, color: GameTokens.secondaryText),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
