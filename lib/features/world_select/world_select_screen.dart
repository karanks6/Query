import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/providers.dart';
import '../../game/scenes/world_select_scene.dart';
import '../../main.dart';

class WorldSelectScreen extends ConsumerStatefulWidget {
  const WorldSelectScreen({super.key});

  @override
  ConsumerState<WorldSelectScreen> createState() => _WorldSelectScreenState();
}

class _WorldSelectScreenState extends ConsumerState<WorldSelectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(queryGameProvider).pushScene(WorldSelectScene());
    });
  }

  @override
  Widget build(BuildContext context) {
    final worldsAsync = ref.watch(allWorldProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GameAppBar(
        title: 'WORLD SELECT',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: worldsAsync.when(
          data: (worlds) {
            if (worlds.isEmpty) {
              return Center(child: Text('NO DATA', style: GameTokens.bodyMedium));
            }

          return ListView.separated(
            padding: const EdgeInsets.all(GameTokens.spaceMd),
            itemCount: worlds.length,
            separatorBuilder: (context, index) => const SizedBox(height: GameTokens.spaceMd),
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

              return ActionButton(
                onPressed: isUnlocked
                    ? () {
                        Navigator.of(context).pushNamed('/level_map', arguments: world.worldId);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: GameTokens.spaceSm),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isUnlocked 
                            ? GameTokens.accent.withValues(alpha: 0.1)
                            : GameTokens.background,
                          border: Border.all(
                            color: isUnlocked ? GameTokens.accent : GameTokens.accentDim,
                          ),
                          borderRadius: GameTokens.borderRadiusSm,
                        ),
                        child: Icon(
                          isUnlocked ? Icons.explore_outlined : Icons.lock_outline,
                          color: isUnlocked ? GameTokens.accent : GameTokens.accentDim,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: GameTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GameTokens.headlineMedium.copyWith(
                                color: isUnlocked ? GameTokens.accent : GameTokens.accentDim,
                              ),
                            ),
                            const SizedBox(height: GameTokens.spaceXs),
                            if (isUnlocked)
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: GameTokens.background.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation(GameTokens.accent),
                              )
                            else
                              Text(
                                'ENCRYPTED - COMPLETE PREVIOUS SECTOR',
                                style: GameTokens.bodySmall.copyWith(
                                  color: GameTokens.accentDim,
                                  letterSpacing: 1.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(
                          Icons.chevron_right,
                          color: GameTokens.accent,
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
            valueColor: AlwaysStoppedAnimation(GameTokens.accent),
            strokeWidth: 2,
          ),
        ),
          error: (err, stack) => Center(
            child: Text('ERROR: $err', style: GameTokens.bodyMedium.copyWith(color: GameTokens.error)),
          ),
        ),
    );
  }
}
