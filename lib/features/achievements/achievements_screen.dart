import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
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
      backgroundColor: TerminalClassicTokens.background,
      appBar: TerminalAppBar(
        title: 'ACHIEVEMENTS',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: achievementsAsync.when(
        data: (earnedList) {
          final earnedIds = earnedList.map((e) => e.achievementId).toSet();
          
          return ListView.separated(
            padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
            itemCount: _kAchievements.length,
            separatorBuilder: (context, index) => const SizedBox(height: TerminalClassicTokens.spaceMd),
            itemBuilder: (context, index) {
              final def = _kAchievements[index];
              final isEarned = earnedIds.contains(def.id);

              return TerminalCard(
                borderColor: isEarned ? TerminalClassicTokens.accent : TerminalClassicTokens.accentDim,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isEarned 
                          ? TerminalClassicTokens.accent.withValues(alpha: 0.1)
                          : TerminalClassicTokens.background,
                        border: Border.all(
                          color: isEarned ? TerminalClassicTokens.accent : TerminalClassicTokens.accentDim,
                        ),
                        borderRadius: TerminalClassicTokens.borderRadiusSm,
                      ),
                      child: Icon(
                        isEarned ? def.icon : Icons.lock_outline,
                        color: isEarned ? TerminalClassicTokens.accent : TerminalClassicTokens.accentDim,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: TerminalClassicTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            def.title,
                            style: TerminalClassicTokens.headlineMedium.copyWith(
                              color: isEarned ? TerminalClassicTokens.primaryText : TerminalClassicTokens.accentDim,
                            ),
                          ),
                          const SizedBox(height: TerminalClassicTokens.spaceXs),
                          Text(
                            isEarned ? def.description : '???',
                            style: TerminalClassicTokens.bodyMedium.copyWith(
                              color: isEarned ? TerminalClassicTokens.secondaryText : TerminalClassicTokens.accentDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEarned)
                      Icon(
                        Icons.check_circle_outline,
                        color: TerminalClassicTokens.accent,
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: (50 + index * 50).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(TerminalClassicTokens.accent),
            strokeWidth: 2,
          ),
        ),
        error: (err, stack) => Center(
          child: Text('ERROR: $err', style: TerminalClassicTokens.bodyMedium.copyWith(color: TerminalClassicTokens.error)),
        ),
      ),
    );
  }
}
