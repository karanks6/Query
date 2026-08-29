import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../core/providers.dart';

/// Main Menu / Dashboard (Section 5.3).
///
/// - Current-world banner with "Continue" CTA
/// - XP/Rank summary + streak flame
/// - Daily challenge card
/// - Quick links: World Map, Sandbox, Achievements, Leaderboard
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);
    final worldsAsync = ref.watch(allWorldProgressProvider);

    return Scaffold(
      backgroundColor: TerminalClassicTokens.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // â”€â”€ App bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(
              child: _DashboardAppBar(profileAsync: profileAsync),
            ),

            // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverPadding(
              padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Continue banner
                  profileAsync.when(
                    data: (profile) => worldsAsync.when(
                      data: (worlds) => _ContinueBanner(
                        worlds: worlds,
                        onContinue: () =>
                            _navigateToCurrentWorld(context, worlds),
                      ),
                      loading: () => const _LoadingCard(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    loading: () => const _LoadingCard(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: TerminalClassicTokens.spaceMd),

                  // Streak + XP row
                  profileAsync.when(
                    data: (profile) => profile != null
                        ? _StatsRow(profile: profile)
                        : const SizedBox.shrink(),
                    loading: () => const _LoadingCard(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: TerminalClassicTokens.spaceMd),

                  // Daily challenge card
                  _DailyChallengeCard(
                    onTap: () => Navigator.of(context).pushNamed('/daily_challenge'),
                  ),

                  const SizedBox(height: TerminalClassicTokens.spaceLg),
                  const TerminalDivider(label: '// BUREAU TOOLS'),
                  const SizedBox(height: TerminalClassicTokens.spaceMd),

                  // Nav grid
                  _NavGrid(context: context),

                  const SizedBox(height: TerminalClassicTokens.spaceLg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCurrentWorld(BuildContext context, List<dynamic> worlds) {
    // Find the last unlocked world
    final unlocked = worlds.where((w) => w.unlocked).toList();
    if (unlocked.isEmpty) return;
    final currentWorld = unlocked.last;
    Navigator.of(context).pushNamed('/level_map', arguments: currentWorld.worldId);
  }
}

class _DashboardAppBar extends StatelessWidget {
  final AsyncValue profileAsync;

  const _DashboardAppBar({required this.profileAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TerminalClassicTokens.spaceMd,
        vertical: TerminalClassicTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: TerminalClassicTokens.surface,
        border: Border(
          bottom: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'QUERY',
            style: TerminalClassicTokens.titleLarge.copyWith(
              fontSize: 20,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: TerminalClassicTokens.accentGlow,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const Spacer(),

          // Player info
          profileAsync.when(
            data: (profile) => profile != null
                ? Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.displayName,
                            style: TerminalClassicTokens.bodyMedium,
                          ),
                          Text(
                            profile.rankTitle,
                            style: TerminalClassicTokens.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: TerminalClassicTokens.spaceSm),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/profile'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TerminalClassicTokens.accent,
                              width: 1,
                            ),
                            borderRadius: TerminalClassicTokens.borderRadiusSm,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: TerminalClassicTokens.accent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ContinueBanner extends StatelessWidget {
  final List<dynamic> worlds;
  final VoidCallback onContinue;

  const _ContinueBanner({required this.worlds, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    if (worlds.isEmpty) return const SizedBox.shrink();
    final unlocked = worlds.where((w) => w.unlocked).toList();
    if (unlocked.isEmpty) return const SizedBox.shrink();
    final current = unlocked.last;

    final worldNames = {
      'world_01': 'The Archive Vaults',
      'world_02': 'Filter District',
      'world_03': 'The Aggregation Exchange',
      'world_04': 'Junction City',
    };

    final name = worldNames[current.worldId] ?? current.worldId;
    final progress = current.totalLevels > 0
        ? current.levelsCompleted / current.totalLevels
        : 0.0;

    return TerminalCard(
      onTap: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_arrow_rounded,
                  color: TerminalClassicTokens.accent, size: 20),
              const SizedBox(width: TerminalClassicTokens.spaceSm),
              Text('CONTINUE', style: TerminalClassicTokens.labelLarge),
            ],
          ),
          const SizedBox(height: TerminalClassicTokens.spaceSm),
          Text(name, style: TerminalClassicTokens.headlineMedium),
          const SizedBox(height: TerminalClassicTokens.spaceSm),
          TerminalProgressBar(
            value: progress,
            label:
                '${current.levelsCompleted} / ${current.totalLevels} levels',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TerminalCard(
            padding: const EdgeInsets.all(TerminalClassicTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: TerminalClassicTokens.warning, size: 16),
                    const SizedBox(width: 4),
                    Text('STREAK', style: TerminalClassicTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.streakCount} days',
                  style: TerminalClassicTokens.headlineMedium.copyWith(
                    color: TerminalClassicTokens.warning,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: TerminalClassicTokens.spaceSm),
        Expanded(
          child: TerminalCard(
            padding: const EdgeInsets.all(TerminalClassicTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt,
                        color: TerminalClassicTokens.accent, size: 16),
                    const SizedBox(width: 4),
                    Text('XP', style: TerminalClassicTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.totalXp}',
                  style: TerminalClassicTokens.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: TerminalClassicTokens.spaceSm),
        Expanded(
          child: TerminalCard(
            padding: const EdgeInsets.all(TerminalClassicTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined,
                        color: TerminalClassicTokens.accent, size: 16),
                    const SizedBox(width: 4),
                    Text('RANK', style: TerminalClassicTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.rankTitle,
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.accent,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DailyChallengeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TerminalCard(
      onTap: onTap,
      borderColor: TerminalClassicTokens.warning,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border:
                  Border.all(color: TerminalClassicTokens.warning, width: 1),
              borderRadius: TerminalClassicTokens.borderRadiusSm,
              color: TerminalClassicTokens.warning.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.today_outlined,
                color: TerminalClassicTokens.warning, size: 22),
          ),
          const SizedBox(width: TerminalClassicTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHALLENGE',
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.warning,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'A new case every day. +2Ã— XP.',
                  style: TerminalClassicTokens.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: TerminalClassicTokens.secondaryText),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

class _NavGrid extends StatelessWidget {
  final BuildContext context;

  const _NavGrid({required this.context});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.map_outlined, 'WORLD MAP', '/world_select'),
      _NavItem(Icons.code_outlined, 'SANDBOX', '/sandbox'),
      _NavItem(Icons.emoji_events_outlined, 'ACHIEVEMENTS', '/achievements'),
      _NavItem(Icons.leaderboard_outlined, 'LEADERBOARD', '/leaderboard'),
      _NavItem(Icons.menu_book_outlined, 'SQL REFERENCE', '/reference'),
      _NavItem(Icons.settings_outlined, 'SETTINGS', '/settings'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: TerminalClassicTokens.spaceSm,
      mainAxisSpacing: TerminalClassicTokens.spaceSm,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .asMap()
          .entries
          .map((e) => e.value
              .buildCard(context)
              .animate()
              .fadeIn(delay: (400 + e.key * 60).ms, duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9)))
          .toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.label, this.route);

  Widget buildCard(BuildContext context) {
    return TerminalCard(
      onTap: () => Navigator.of(context).pushNamed(route),
      padding: const EdgeInsets.all(TerminalClassicTokens.spaceSm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: TerminalClassicTokens.accent, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TerminalClassicTokens.bodySmall.copyWith(
              fontSize: 9,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return TerminalCard(
      child: const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation(TerminalClassicTokens.accent),
          ),
        ),
      ),
    );
  }
}
