import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../theming/components/holo_button.dart';
import '../gameplay/widgets/parallax_background.dart';
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
      backgroundColor: SciFiTokens.background,
      body: ParallaxBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _DashboardAppBar(profileAsync: profileAsync),
              ),

              // ── Body ──────────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(SciFiTokens.spaceMd),
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

                    const SizedBox(height: SciFiTokens.spaceMd),

                    // Streak + XP row
                    profileAsync.when(
                      data: (profile) => profile != null
                          ? _StatsRow(profile: profile)
                          : const SizedBox.shrink(),
                      loading: () => const _LoadingCard(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: SciFiTokens.spaceMd),

                    // Daily challenge card
                    _DailyChallengeCard(
                      onTap: () => Navigator.of(context).pushNamed('/daily_challenge'),
                    ),

                    const SizedBox(height: SciFiTokens.spaceLg),
                    const TerminalDivider(label: '// BUREAU TOOLS'),
                    const SizedBox(height: SciFiTokens.spaceMd),

                    // Nav grid
                    _NavGrid(context: context),

                    const SizedBox(height: SciFiTokens.spaceLg),
                  ]),
                ),
              ),
            ],
          ),
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
        horizontal: SciFiTokens.spaceMd,
        vertical: SciFiTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: SciFiTokens.surface,
        border: Border(
          bottom: BorderSide(color: SciFiTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'QUERY',
            style: SciFiTokens.titleLarge.copyWith(
              fontSize: 20,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: SciFiTokens.accentGlow,
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
                            style: SciFiTokens.bodyMedium,
                          ),
                          Text(
                            profile.rankTitle,
                            style: SciFiTokens.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: SciFiTokens.spaceSm),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/profile'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: SciFiTokens.accent,
                              width: 1,
                            ),
                            borderRadius: SciFiTokens.borderRadiusSm,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: SciFiTokens.accent,
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

    return HoloButton(
      isPrimary: true,
      onPressed: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_arrow_rounded,
                  color: SciFiTokens.background, size: 20),
              const SizedBox(width: SciFiTokens.spaceSm),
              Text('CONTINUE', style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.background)),
            ],
          ),
          const SizedBox(height: SciFiTokens.spaceSm),
          Text(name, style: SciFiTokens.headlineMedium.copyWith(color: SciFiTokens.background)),
          const SizedBox(height: SciFiTokens.spaceSm),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: SciFiTokens.background.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(SciFiTokens.background),
          ),
          const SizedBox(height: 4),
          Text(
            '${current.levelsCompleted} / ${current.totalLevels} levels',
            style: SciFiTokens.bodySmall.copyWith(color: SciFiTokens.background),
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
          child: HoloPanel(
            emissionIntensity: 0.3,
            padding: const EdgeInsets.all(SciFiTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: SciFiTokens.warning, size: 16),
                    const SizedBox(width: 4),
                    Text('STREAK', style: SciFiTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.streakCount} days',
                  style: SciFiTokens.headlineMedium.copyWith(
                    color: SciFiTokens.warning,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: SciFiTokens.spaceSm),
        Expanded(
          child: HoloPanel(
            emissionIntensity: 0.3,
            padding: const EdgeInsets.all(SciFiTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt,
                        color: SciFiTokens.accent, size: 16),
                    const SizedBox(width: 4),
                    Text('XP', style: SciFiTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.totalXp}',
                  style: SciFiTokens.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: SciFiTokens.spaceSm),
        Expanded(
          child: HoloPanel(
            emissionIntensity: 0.3,
            padding: const EdgeInsets.all(SciFiTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined,
                        color: SciFiTokens.accent, size: 16),
                    const SizedBox(width: 4),
                    Text('RANK', style: SciFiTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.rankTitle,
                  style: SciFiTokens.bodySmall.copyWith(
                    color: SciFiTokens.accent,
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
    return HoloButton(
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border:
                  Border.all(color: SciFiTokens.warning, width: 1),
              borderRadius: SciFiTokens.borderRadiusSm,
              color: SciFiTokens.warning.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.today_outlined,
                color: SciFiTokens.warning, size: 22),
          ),
          const SizedBox(width: SciFiTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHALLENGE',
                  style: SciFiTokens.bodySmall.copyWith(
                    color: SciFiTokens.warning,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'A new case every day. +2× XP.',
                  style: SciFiTokens.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: SciFiTokens.accent),
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
      crossAxisSpacing: SciFiTokens.spaceSm,
      mainAxisSpacing: SciFiTokens.spaceSm,
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
    return HoloButton(
      onPressed: () => Navigator.of(context).pushNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: SciFiTokens.accent, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: SciFiTokens.bodySmall.copyWith(
                fontSize: 9,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            valueColor: AlwaysStoppedAnimation(SciFiTokens.accent),
          ),
        ),
      ),
    );
  }
}
