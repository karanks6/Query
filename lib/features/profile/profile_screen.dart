import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/providers.dart';
import '../../data/local/app_database.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'DETECTIVE PROFILE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
          error: (err, stack) => Center(child: Text('Error loading profile: $err', style: const TextStyle(color: GameTokens.error))),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Profile not found', style: TextStyle(color: GameTokens.error)));
            }

            return ListView(
              padding: const EdgeInsets.all(GameTokens.spaceLg),
              children: [
                _buildHeader(profile),
                const SizedBox(height: GameTokens.spaceXl),
                _buildStatsGrid(profile),
                const SizedBox(height: GameTokens.spaceXl),
                _buildMasteryTracker(ref),
              ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(PlayerProfile profile) {
    return SlantedPanel(
      padding: const EdgeInsets.all(GameTokens.spaceLg),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: GameTokens.accent.withValues(alpha: 0.1),
              border: Border.all(color: GameTokens.accent, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Icon(Icons.person, size: 48, color: GameTokens.accent),
          ),
          const SizedBox(width: GameTokens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: GameTokens.headlineLarge.copyWith(color: GameTokens.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.rankTitle,
                  style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(PlayerProfile profile) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('TOTAL XP', profile.totalXp.toString())),
        const SizedBox(width: GameTokens.spaceMd),
        Expanded(child: _buildStatCard('STREAK', '${profile.streakCount} DAYS')),
        const SizedBox(width: GameTokens.spaceMd),
        Expanded(child: _buildStatCard('INSIGHT', profile.insightPoints.toString())),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return SlantedPanel(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        children: [
          Text(label, style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
          const SizedBox(height: GameTokens.spaceSm),
          Text(value, style: GameTokens.headlineMedium.copyWith(color: GameTokens.primaryText)),
        ],
      ),
    );
  }

  Widget _buildMasteryTracker(WidgetRef ref) {
    final masteryAsync = ref.watch(masteryProgressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONCEPT MASTERY', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
        const SizedBox(height: GameTokens.spaceMd),
        SlantedPanel(
          padding: const EdgeInsets.all(GameTokens.spaceLg),
          child: masteryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
            error: (e, st) => Text('Failed to load mastery.', style: const TextStyle(color: GameTokens.error)),
            data: (masteries) {
              if (masteries.isEmpty) {
                return Text('No data yet.', style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText));
              }
              return Column(
                children: masteries.map((m) => _buildMasteryBar(m['concept'] as String, m['progress'] as double)).toList(),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildMasteryBar(String concept, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(concept, style: GameTokens.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: GameTokens.background,
              color: progress >= 1.0 ? GameTokens.success : (progress > 0.5 ? GameTokens.warning : GameTokens.error),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
