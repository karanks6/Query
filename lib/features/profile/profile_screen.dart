import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../core/providers.dart';
import '../../data/local/app_database.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'DETECTIVE PROFILE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: SciFiTokens.accent)),
          error: (err, stack) => Center(child: Text('Error loading profile: $err', style: const TextStyle(color: SciFiTokens.error))),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Profile not found', style: TextStyle(color: SciFiTokens.error)));
            }

            return ListView(
              padding: const EdgeInsets.all(SciFiTokens.spaceLg),
              children: [
                _buildHeader(profile),
                const SizedBox(height: SciFiTokens.spaceXl),
                _buildStatsGrid(profile),
                const SizedBox(height: SciFiTokens.spaceXl),
                _buildMasteryTracker(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(PlayerProfile profile) {
    return HoloPanel(
      emissionIntensity: 0.2,
      padding: const EdgeInsets.all(SciFiTokens.spaceLg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: SciFiTokens.accent.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 40, color: SciFiTokens.accent),
          ),
          const SizedBox(width: SciFiTokens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: SciFiTokens.headlineLarge.copyWith(color: SciFiTokens.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.rankTitle,
                  style: SciFiTokens.bodyMedium.copyWith(color: SciFiTokens.secondaryText),
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
        const SizedBox(width: SciFiTokens.spaceMd),
        Expanded(child: _buildStatCard('STREAK', '${profile.streakCount} DAYS')),
        const SizedBox(width: SciFiTokens.spaceMd),
        Expanded(child: _buildStatCard('INSIGHT', profile.insightPoints.toString())),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return HoloPanel(
      emissionIntensity: 0.1,
      padding: const EdgeInsets.all(SciFiTokens.spaceMd),
      child: Column(
        children: [
          Text(label, style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText)),
          const SizedBox(height: SciFiTokens.spaceSm),
          Text(value, style: SciFiTokens.headlineMedium.copyWith(color: SciFiTokens.primaryText)),
        ],
      ),
    );
  }

  Widget _buildMasteryTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONCEPT MASTERY', style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText)),
        const SizedBox(height: SciFiTokens.spaceMd),
        HoloPanel(
          emissionIntensity: 0.1,
          padding: const EdgeInsets.all(SciFiTokens.spaceLg),
          child: Column(
            children: [
              _buildMasteryBar('Basic Selects', 1.0),
              _buildMasteryBar('Filtering & Logic', 0.85),
              _buildMasteryBar('Aggregations', 0.60),
              _buildMasteryBar('JOINs', 0.40),
              _buildMasteryBar('Subqueries', 0.10),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMasteryBar(String concept, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SciFiTokens.spaceMd),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(concept, style: SciFiTokens.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: SciFiTokens.background,
              color: progress > 0.8 ? SciFiTokens.success : (progress > 0.5 ? SciFiTokens.warning : SciFiTokens.error),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
