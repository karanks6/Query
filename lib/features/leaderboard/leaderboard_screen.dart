import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../data/remote/leaderboard_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPlayersAsync = ref.watch(topPlayersProvider);

    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'LEADERBOARD',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: topPlayersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
          error: (e, st) => Center(
            child: Text('Failed to connect to global network.', style: GameTokens.bodyMedium.copyWith(color: GameTokens.error)),
          ),
          data: (players) {
            if (players.isEmpty) {
              return Center(
                child: Text('No agents found in global network.', style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText)),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(GameTokens.spaceLg),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isTopThree = index < 3;
                return Padding(
                  padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
                  child: SlantedPanel(
                    borderColorOverride: isTopThree ? GameTokens.accent : GameTokens.accentDim,
                    padding: const EdgeInsets.all(GameTokens.spaceMd),
                    child: Row(
                      children: [
                        Text(
                          '#${index + 1}',
                          style: GameTokens.headlineMedium.copyWith(
                            color: isTopThree ? GameTokens.accent : GameTokens.secondaryText,
                          ),
                        ),
                        const SizedBox(width: GameTokens.spaceLg),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: GameTokens.accent.withValues(alpha: 0.1),
                            border: Border.all(color: GameTokens.accentDim, width: 1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.person, color: GameTokens.primaryText, size: 20),
                        ),
                        const SizedBox(width: GameTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.displayName,
                                style: GameTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                player.rankTitle,
                                style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${player.totalXp} XP',
                          style: GameTokens.code.copyWith(color: GameTokens.secondaryText),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (50 + index * 30).ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
