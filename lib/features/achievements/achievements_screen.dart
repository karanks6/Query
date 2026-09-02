import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../core/providers.dart';

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<AchievementDef> _kAchievements = [
  AchievementDef(id: 'first_query', title: 'Hello World', description: 'Execute your first SQL query.', icon: Icons.keyboard_return),
  AchievementDef(id: 'world_1_complete', title: 'Archivist', description: 'Complete The Archive Vaults.', icon: Icons.folder_special),
  AchievementDef(id: 'world_2_complete', title: 'Filter Specialist', description: 'Complete Filter District.', icon: Icons.filter_alt),
  AchievementDef(id: 'world_3_complete', title: 'Aggregator', description: 'Complete Aggregation District.', icon: Icons.functions),
  AchievementDef(id: 'world_4_complete', title: 'Nexus Weaver', description: 'Complete The JOIN Nexus.', icon: Icons.account_tree),
  AchievementDef(id: 'perfect_optimization', title: '100% Efficiency', description: 'Solve a performance level perfectly.', icon: Icons.speed),
  AchievementDef(id: 'daily_streak_3', title: 'Consistency', description: 'Achieve a 3-day streak.', icon: Icons.local_fire_department),
  AchievementDef(id: 'rank_silver', title: 'Moving Up', description: 'Reach Silver Rank.', icon: Icons.workspace_premium),
];

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);

    return Scaffold(
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'ACHIEVEMENTS',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: achievementsAsync.when(
          data: (earnedList) {
            final earnedIds = earnedList.map((e) => e.achievementId).toSet();
            
            return ListView.separated(
              padding: const EdgeInsets.all(SciFiTokens.spaceMd),
              itemCount: _kAchievements.length,
              separatorBuilder: (context, index) => const SizedBox(height: SciFiTokens.spaceMd),
              itemBuilder: (context, index) {
                final def = _kAchievements[index];
                final isEarned = earnedIds.contains(def.id);

                return HoloPanel(
                  emissionIntensity: isEarned ? 0.3 : 0.05,
                  borderColorOverride: isEarned ? SciFiTokens.accent : SciFiTokens.accentDim,
                  padding: const EdgeInsets.all(SciFiTokens.spaceMd),
                  child: Row(
                    children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isEarned 
                          ? SciFiTokens.accent.withValues(alpha: 0.1)
                          : SciFiTokens.background,
                        border: Border.all(
                          color: isEarned ? SciFiTokens.accent : SciFiTokens.accentDim,
                        ),
                        borderRadius: SciFiTokens.borderRadiusSm,
                      ),
                      child: Icon(
                        isEarned ? def.icon : Icons.lock_outline,
                        color: isEarned ? SciFiTokens.accent : SciFiTokens.accentDim,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: SciFiTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            def.title,
                            style: SciFiTokens.headlineMedium.copyWith(
                              color: isEarned ? SciFiTokens.primaryText : SciFiTokens.accentDim,
                            ),
                          ),
                          const SizedBox(height: SciFiTokens.spaceXs),
                          Text(
                            isEarned ? def.description : '???',
                            style: SciFiTokens.bodyMedium.copyWith(
                              color: isEarned ? SciFiTokens.secondaryText : SciFiTokens.accentDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEarned)
                      Icon(
                        Icons.check_circle_outline,
                        color: SciFiTokens.accent,
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: (50 + index * 50).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(SciFiTokens.accent),
            strokeWidth: 2,
          ),
        ),
        error: (err, stack) => Center(
            child: Text('ERROR: $err', style: SciFiTokens.bodyMedium.copyWith(color: SciFiTokens.error)),
          ),
        ),
      ),
    );
  }
}
