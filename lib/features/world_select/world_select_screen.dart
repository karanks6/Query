import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../core/providers.dart';

class WorldSelectScreen extends ConsumerWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worldsAsync = ref.watch(allWorldProgressProvider);

    return Scaffold(
      backgroundColor: TerminalClassicTokens.background,
      appBar: TerminalAppBar(
        title: 'WORLD SELECT',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: worldsAsync.when(
        data: (worlds) {
          if (worlds.isEmpty) {
            return Center(child: Text('NO DATA', style: TerminalClassicTokens.bodyMedium));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
            itemCount: worlds.length,
            separatorBuilder: (context, index) => const SizedBox(height: TerminalClassicTokens.spaceMd),
            itemBuilder: (context, index) {
              final world = worlds[index];
              final isUnlocked = world.unlocked;
              
              final worldTitles = {
                'world_01': 'The Archive Vaults',
                'world_02': 'Filter District',
                'world_03': 'Aggregation District',
                'world_04': 'The JOIN Nexus',
                'world_05': 'Set City',
                'world_06': 'Subquery Sector',
                'world_07': 'Window Peak',
                'world_08': 'Modification Hub',
                'world_09': 'Index Core',
                'world_10': 'The Master Frame',
              };

              final title = worldTitles[world.worldId] ?? world.worldId;
              final progress = world.totalLevels > 0 ? world.levelsCompleted / world.totalLevels : 0.0;
              final displayProgress = (progress * 100).toInt();

              return TerminalCard(
                borderColor: isUnlocked ? TerminalClassicTokens.accent : TerminalClassicTokens.accentDim,
                onTap: isUnlocked
                    ? () {
                        Navigator.of(context).pushNamed('/level_map', arguments: world.worldId);
                      }
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked 
                          ? TerminalClassicTokens.accent.withValues(alpha: 0.1)
                          : TerminalClassicTokens.background,
                        border: Border.all(
                          color: isUnlocked ? TerminalClassicTokens.accent : TerminalClassicTokens.accentDim,
                        ),
                        borderRadius: TerminalClassicTokens.borderRadiusSm,
                      ),
                      child: Icon(
                        isUnlocked ? Icons.explore_outlined : Icons.lock_outline,
                        color: isUnlocked ? TerminalClassicTokens.accent : TerminalClassicTokens.accentDim,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: TerminalClassicTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TerminalClassicTokens.headlineMedium.copyWith(
                              color: isUnlocked ? TerminalClassicTokens.primaryText : TerminalClassicTokens.accentDim,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: TerminalClassicTokens.secondaryText),
                            onPressed: () => Navigator.pushNamed(context, '/settings'),
                          ),
                          const SizedBox(height: TerminalClassicTokens.spaceXs),
                          if (isUnlocked)
                            TerminalProgressBar(
                              value: progress,
                              label: '${world.levelsCompleted} / ${world.totalLevels} ($displayProgress%)',
                            )
                          else
                            Text(
                              'ENCRYPTED - COMPLETE PREVIOUS SECTOR',
                              style: TerminalClassicTokens.bodySmall.copyWith(
                                color: TerminalClassicTokens.accentDim,
                                letterSpacing: 1.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.chevron_right,
                        color: TerminalClassicTokens.accent,
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: (100 + index * 50).ms, duration: 300.ms).slideX(begin: -0.1, end: 0);
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
