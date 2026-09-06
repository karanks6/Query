import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../core/providers.dart';
import '../../../core/settings/settings_service.dart';

class StreakCalendarModal extends ConsumerWidget {
  const StreakCalendarModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);
    final prefs = ref.watch(sharedPreferencesProvider);

    return Container(
      padding: const EdgeInsets.all(GameTokens.spaceLg),
      decoration: const BoxDecoration(
        color: GameTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading profile')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();

          final longestStreak = prefs.getInt('longest_streak') ?? profile.streakCount;
          final history = prefs.getStringList('streak_history') ?? [];
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GameTokens.secondaryText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: GameTokens.spaceXl),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: GameTokens.warning, size: 32),
                  const SizedBox(width: GameTokens.spaceMd),
                  Text(
                    'STREAK HISTORY',
                    style: GameTokens.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: GameTokens.spaceXl),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'CURRENT',
                      value: '${profile.streakCount}',
                      icon: Icons.whatshot,
                      color: GameTokens.warning,
                    ),
                  ),
                  const SizedBox(width: GameTokens.spaceMd),
                  Expanded(
                    child: _buildStatCard(
                      title: 'LONGEST',
                      value: '$longestStreak',
                      icon: Icons.emoji_events,
                      color: GameTokens.accent,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: GameTokens.spaceXl),
              Text(
                'LAST 30 DAYS',
                style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText),
              ),
              const SizedBox(height: GameTokens.spaceMd),
              
              _buildActivityGrid(history),
              
              const SizedBox(height: GameTokens.spaceLg),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      decoration: BoxDecoration(
        color: GameTokens.background,
        border: Border.all(color: GameTokens.surfaceHighlight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: GameTokens.bodySmall),
            ],
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Text(
            value,
            style: GameTokens.headlineMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityGrid(List<String> history) {
    // Generate the last 30 days
    final now = DateTime.now();
    final days = List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      return date;
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final date = days[index];
        final dateStr = date.toIso8601String().substring(0, 10);
        final isActive = history.contains(dateStr);
        final isToday = index == 29;

        return Tooltip(
          message: DateFormat.yMMMd().format(date),
          child: Container(
            decoration: BoxDecoration(
              color: isActive 
                  ? GameTokens.warning.withValues(alpha: isToday ? 1.0 : 0.8)
                  : GameTokens.background,
              border: Border.all(
                color: isToday 
                    ? GameTokens.primaryText 
                    : (isActive ? GameTokens.warning : GameTokens.surfaceHighlight),
                width: isToday ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}
