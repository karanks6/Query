import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/app_theme.dart';
import '../../core/providers.dart';
import '../../data/local/app_database.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(activeTokensProvider);
    final profileAsync = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Detective Profile', style: TextStyle(color: tokens.primaryText)),
        backgroundColor: tokens.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: tokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: tokens.accent)),
        error: (err, stack) => Center(child: Text('Error loading profile: $err', style: TextStyle(color: tokens.error))),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text('Profile not found', style: TextStyle(color: tokens.error)));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(profile, tokens),
              const SizedBox(height: 24),
              _buildStatsGrid(profile, tokens),
              const SizedBox(height: 24),
              _buildMasteryTracker(tokens),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(PlayerProfile profile, AppThemeTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.surfaceVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: tokens.accent.withValues(alpha: 0.2),
            child: Icon(Icons.person, size: 40, color: tokens.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: TextStyle(
                    color: tokens.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.rankTitle,
                  style: TextStyle(color: tokens.secondaryText, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(PlayerProfile profile, AppThemeTokens tokens) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total XP', profile.totalXp.toString(), tokens)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Streak', '${profile.streakCount} Days', tokens)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Insight Pts', profile.insightPoints.toString(), tokens)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, AppThemeTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.surfaceVariant),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: tokens.secondaryText, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: tokens.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMasteryTracker(AppThemeTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONCEPT MASTERY', style: TextStyle(color: tokens.secondaryText, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.surfaceVariant),
          ),
          child: Column(
            children: [
              _buildMasteryBar('Basic Selects', 1.0, tokens),
              _buildMasteryBar('Filtering & Logic', 0.85, tokens),
              _buildMasteryBar('Aggregations', 0.60, tokens),
              _buildMasteryBar('JOINs', 0.40, tokens),
              _buildMasteryBar('Subqueries', 0.10, tokens),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMasteryBar(String concept, double progress, AppThemeTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(concept, style: TextStyle(color: tokens.primaryText)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: tokens.background,
              color: progress > 0.8 ? tokens.success : (progress > 0.5 ? tokens.warning : tokens.error),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
