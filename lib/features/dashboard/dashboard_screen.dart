import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/providers.dart';
import '../../core/settings/settings_service.dart';
import 'widgets/streak_calendar_modal.dart';
import 'widgets/rank_progress_modal.dart';

/// Main Menu / Dashboard (Section 5.3).
///
/// - Current-world banner with "Continue" CTA
/// - XP/Rank summary + streak flame
/// - Daily challenge card
/// - Quick links: World Map, Sandbox, Achievements, Leaderboard
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(sharedPreferencesProvider);
      ref.read(playerDaoProvider).checkDailyStreak(prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(playerProfileProvider);
    final worldsAsync = ref.watch(allWorldProgressProvider);

    return Scaffold(
      backgroundColor: GameTokens.background,
      body: ParallaxBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
              // Ã¢â€â‚¬Ã¢â€â‚¬ App bar Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
              SliverToBoxAdapter(
                child: _DashboardAppBar(profileAsync: profileAsync),
              ),

              // Ã¢â€â‚¬Ã¢â€â‚¬ Body Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
              SliverPadding(
                padding: const EdgeInsets.all(GameTokens.spaceMd),
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

                    const SizedBox(height: GameTokens.spaceMd),

                    // Streak + XP row
                    profileAsync.when(
                      data: (profile) => profile != null
                          ? _StatsRow(profile: profile)
                          : const SizedBox.shrink(),
                      loading: () => const _LoadingCard(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: GameTokens.spaceMd),

                    // Daily challenge card
                    _DailyChallengeCard(
                      onTap: () => Navigator.of(context).pushNamed('/daily_challenge'),
                    ),

                    const SizedBox(height: GameTokens.spaceLg),
                    const GameDivider(label: '// BUREAU TOOLS'),
                    const SizedBox(height: GameTokens.spaceMd),

                    // Bureau Tools List
                    _BureauToolsList(context: context),

                    const SizedBox(height: GameTokens.spaceLg),
                  ]),
                ),
              ),
            ],
          ),
        ),
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
        horizontal: GameTokens.spaceMd,
        vertical: GameTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: GameTokens.surface,
        border: Border(
          bottom: BorderSide(color: GameTokens.accentDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'QUERY',
            style: GameTokens.displayMedium.copyWith(
              fontSize: 24,
              letterSpacing: 6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: GameTokens.accent.withValues(alpha: 0.5),
                  offset: const Offset(2, 2),
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
                            style: GameTokens.bodyMedium,
                          ),
                          Text(
                            profile.rankTitle,
                            style: GameTokens.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: GameTokens.spaceSm),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/profile'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: GameTokens.accent,
                              width: 1,
                            ),
                            borderRadius: GameTokens.borderRadiusSm,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: GameTokens.accent,
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

    return ActionButton(
      isPrimary: true,
      onPressed: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_arrow_rounded,
                  color: GameTokens.background, size: 20),
              const SizedBox(width: GameTokens.spaceSm),
              Text('CONTINUE', style: GameTokens.labelLarge.copyWith(color: GameTokens.background)),
            ],
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Text(name, style: GameTokens.headlineMedium.copyWith(color: GameTokens.background)),
          const SizedBox(height: GameTokens.spaceSm),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: GameTokens.background.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(GameTokens.background),
          ),
          const SizedBox(height: 4),
          Text(
            '${current.levelsCompleted} / ${current.totalLevels} levels',
            style: GameTokens.bodySmall.copyWith(color: GameTokens.background),
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
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: const StreakCalendarModal(),
                  ),
                ),
              );
            },
            child: SlantedPanel(
              padding: const EdgeInsets.all(GameTokens.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: GameTokens.warning, size: 16),
                      const SizedBox(width: 4),
                      Text('STREAK', style: GameTokens.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.streakCount} days',
                    style: GameTokens.headlineMedium.copyWith(
                      color: GameTokens.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: GameTokens.spaceSm),
        Expanded(
          child: SlantedPanel(
            padding: const EdgeInsets.all(GameTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt,
                        color: GameTokens.accent, size: 16),
                    const SizedBox(width: 4),
                    Text('XP', style: GameTokens.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.totalXp}',
                  style: GameTokens.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: GameTokens.spaceSm),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      maxChildSize: 0.95,
                      minChildSize: 0.5,
                      builder: (_, controller) => RankProgressModal(scrollController: controller),
                    ),
                  ),
                ),
              );
            },
            child: SlantedPanel(
              padding: const EdgeInsets.all(GameTokens.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_outlined,
                          color: GameTokens.accent, size: 16),
                      const SizedBox(width: 4),
                      Text('RANK', style: GameTokens.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.rankTitle,
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.accent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
    return ActionButton(
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border:
                  Border.all(color: GameTokens.warning, width: 1),
              borderRadius: GameTokens.borderRadiusSm,
              color: GameTokens.warning.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.today_outlined,
                color: GameTokens.warning, size: 22),
          ),
          const SizedBox(width: GameTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHALLENGE',
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.warning,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'A new case every day. +2× XP.',
                  style: GameTokens.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: GameTokens.accent),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

class _BureauToolsList extends StatelessWidget {
  final BuildContext context;

  const _BureauToolsList({required this.context});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BureauToolItem(Icons.map_outlined, 'WORLD MAP', 'Access the global case map', '/world_select'),
      _BureauToolItem(Icons.emoji_events_outlined, 'ACHIEVEMENTS', 'View unlocked commendations', '/achievements'),
      _BureauToolItem(Icons.menu_book_outlined, 'SQL REFERENCE', 'Consult the query manual', '/reference'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items
          .asMap()
          .entries
          .map((e) => e.value
              .buildCard(context)
              .animate()
              .fadeIn(delay: (400 + e.key * 60).ms, duration: 300.ms)
              .slideX(begin: 0.1, end: 0))
          .toList(),
    );
  }
}

class _BureauToolItem {
  final IconData icon;
  final String title;
  final String description;
  final String route;

  const _BureauToolItem(this.icon, this.title, this.description, this.route);

  Widget buildCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
      child: ActionButton(
        onPressed: () => Navigator.of(context).pushNamed(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(GameTokens.spaceMd),
                decoration: BoxDecoration(
                  color: GameTokens.accent.withValues(alpha: 0.1),
                  borderRadius: GameTokens.borderRadiusSm,
                  border: Border.all(color: GameTokens.accentDim, width: 1),
                ),
                child: Icon(icon, color: GameTokens.accent, size: 24),
              ),
              const SizedBox(width: GameTokens.spaceLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GameTokens.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: GameTokens.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: GameTokens.accentDim),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return SlantedPanel(
      child: const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation(GameTokens.accent),
          ),
        ),
      ),
    );
  }
}
