import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../theming/components/holo_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../core/providers.dart';

class WorldSelectScreen extends ConsumerWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worldsAsync = ref.watch(allWorldProgressProvider);

    return Scaffold(
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'WORLD SELECT',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: worldsAsync.when(
          data: (worlds) {
            if (worlds.isEmpty) {
              return Center(child: Text('NO DATA', style: SciFiTokens.bodyMedium));
            }

          return ListView.separated(
            padding: const EdgeInsets.all(SciFiTokens.spaceMd),
            itemCount: worlds.length,
            separatorBuilder: (context, index) => const SizedBox(height: SciFiTokens.spaceMd),
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

              return HoloButton(
                onPressed: isUnlocked
                    ? () {
                        Navigator.of(context).pushNamed('/level_map', arguments: world.worldId);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SciFiTokens.spaceSm),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isUnlocked 
                            ? SciFiTokens.accent.withValues(alpha: 0.1)
                            : SciFiTokens.background,
                          border: Border.all(
                            color: isUnlocked ? SciFiTokens.accent : SciFiTokens.accentDim,
                          ),
                          borderRadius: SciFiTokens.borderRadiusSm,
                        ),
                        child: Icon(
                          isUnlocked ? Icons.explore_outlined : Icons.lock_outline,
                          color: isUnlocked ? SciFiTokens.accent : SciFiTokens.accentDim,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: SciFiTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: SciFiTokens.headlineMedium.copyWith(
                                color: isUnlocked ? SciFiTokens.accent : SciFiTokens.accentDim,
                              ),
                            ),
                            const SizedBox(height: SciFiTokens.spaceXs),
                            if (isUnlocked)
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: SciFiTokens.background.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation(SciFiTokens.accent),
                              )
                            else
                              Text(
                                'ENCRYPTED - COMPLETE PREVIOUS SECTOR',
                                style: SciFiTokens.bodySmall.copyWith(
                                  color: SciFiTokens.accentDim,
                                  letterSpacing: 1.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(
                          Icons.chevron_right,
                          color: SciFiTokens.accent,
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (100 + index * 50).ms, duration: 300.ms).slideX(begin: -0.1, end: 0);
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
