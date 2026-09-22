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
      backgroundColor: GameTokens.background, // Solid background
      appBar: GameAppBar(
        title: 'GLOBAL RANKINGS',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: topPlayersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
        error: (e, st) {
          // Fallback to mock data if Firestore is inaccessible
          return _buildLeaderboardContent([
            const LeaderboardEntry(uid: '1', displayName: 'QueryMaster99', totalXp: 15420, rankTitle: 'Chief Investigator'),
            const LeaderboardEntry(uid: '2', displayName: 'DropTableStudent', totalXp: 12050, rankTitle: 'Senior Detective'),
            const LeaderboardEntry(uid: '3', displayName: 'SelectStar', totalXp: 9800, rankTitle: 'Investigator'),
            const LeaderboardEntry(uid: '4', displayName: 'JoinWizard', totalXp: 8100, rankTitle: 'Junior Analyst'),
            const LeaderboardEntry(uid: '5', displayName: 'IndexHero', totalXp: 4500, rankTitle: 'Intern'),
            const LeaderboardEntry(uid: '6', displayName: 'Karan', totalXp: 4200, rankTitle: 'Intern'),
          ], '6');
        },
        data: (players) {
          if (players.isEmpty) {
            return Center(
              child: Text('No agents found in global network.', style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText)),
            );
          }
          // Default mock current user ID for highlighting
          return _buildLeaderboardContent(players, '6');
        },
      ),
    );
  }

  Widget _buildLeaderboardContent(List<LeaderboardEntry> players, String currentUserId) {
    final topThree = players.take(3).toList();
    final theRest = players.skip(3).toList();

    return Column(
      children: [
        if (topThree.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: GameTokens.spaceXl, bottom: GameTokens.spaceLg),
            child: _buildPodium(topThree),
          ),
        Expanded(
          child: _buildLeaderboardList(theRest, currentUserId, startIndex: topThree.length),
        ),
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    // 2nd, 1st, 3rd layout
    LeaderboardEntry? first = topThree.isNotEmpty ? topThree[0] : null;
    LeaderboardEntry? second = topThree.length > 1 ? topThree[1] : null;
    LeaderboardEntry? third = topThree.length > 2 ? topThree[2] : null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (second != null) _buildPodiumPlace(second, 2, 140, GameTokens.secondaryText, 200.ms),
            if (first != null) _buildPodiumPlace(first, 1, 180, GameTokens.accent, 0.ms),
            if (third != null) _buildPodiumPlace(third, 3, 110, const Color(0xFFCD7F32), 400.ms), // Bronze
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int rank, double height, Color color, Duration delay) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.workspace_premium, color: color, size: 40)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.1, duration: 1.seconds),
          const SizedBox(height: GameTokens.spaceSm),
          Text(
            entry.displayName,
            style: GameTokens.bodyMedium.copyWith(color: GameTokens.primaryText, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.totalXp} XP',
            style: GameTokens.code.copyWith(color: color, fontSize: 12),
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              border: Border(
                top: BorderSide(color: color, width: 3),
                left: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
                right: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, -10),
                )
              ],
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: GameTokens.spaceSm),
            child: Text(
              '#$rank',
              style: GameTokens.headlineMedium.copyWith(color: color.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ).animate().slideY(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: delay).fadeIn(),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> players, String currentUserId, {int startIndex = 0}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceMd),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            final rank = startIndex + index + 1;
            final isCurrentUser = player.uid == currentUserId;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
              child: SlantedPanel(
                borderColorOverride: isCurrentUser ? GameTokens.accent : GameTokens.accentDim.withValues(alpha: 0.5),
                colorOverride: isCurrentUser ? GameTokens.accent.withValues(alpha: 0.1) : null,
                padding: const EdgeInsets.all(GameTokens.spaceMd),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '#$rank',
                        style: GameTokens.headlineMedium.copyWith(
                          color: isCurrentUser ? GameTokens.accent : GameTokens.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: GameTokens.spaceMd),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCurrentUser ? GameTokens.accent.withValues(alpha: 0.2) : GameTokens.background,
                        border: Border.all(color: isCurrentUser ? GameTokens.accent : GameTokens.accentDim, width: 1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Icon(Icons.person, color: isCurrentUser ? GameTokens.accent : GameTokens.secondaryText, size: 20),
                    ),
                    const SizedBox(width: GameTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.displayName.toUpperCase(),
                            style: GameTokens.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser ? GameTokens.primaryText : GameTokens.secondaryText,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            player.rankTitle.toUpperCase(),
                            style: GameTokens.bodySmall.copyWith(
                              color: isCurrentUser ? GameTokens.accent : GameTokens.accentDim,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${player.totalXp} XP',
                      style: GameTokens.code.copyWith(
                        color: isCurrentUser ? GameTokens.accent : GameTokens.secondaryText,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (50 + index * 30).ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
            );
          },
        ),
      ),
    );
  }
}
