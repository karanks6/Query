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
import 'widgets/weekly_case_card.dart';
import 'widgets/rank_progress_modal.dart';
import '../../data/content/models/rank_system.dart';
import '../../game/scenes/dashboard_scene.dart';
import '../../main.dart';

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
      final achievementsDao = ref.read(achievementsDaoProvider);
      ref.read(playerDaoProvider).checkDailyStreak(prefs, achievementsDao: achievementsDao);
      
      ref.read(queryGameProvider).pushScene(DashboardScene());
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(playerProfileProvider);
    final worldsAsync = ref.watch(allWorldProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
              // ─── Body ────────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(GameTokens.spaceMd),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Builder(
                    builder: (context) {
                      // Use MediaQuery instead of LayoutBuilder: LayoutBuilder triggers
                      // intrinsic dimension queries which SliverFillRemaining forbids.
                      final isDesktop = MediaQuery.sizeOf(context).width > 720;
                      
                      final continueBanner = profileAsync.when(
                        data: (profile) => worldsAsync.when(
                          data: (worlds) => _ContinueBanner(
                            worlds: worlds,
                            onContinue: () => _navigateToCurrentWorld(context, worlds),
                          ),
                          loading: () => const _LoadingCard(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        loading: () => const _LoadingCard(),
                        error: (_, __) => const SizedBox.shrink(),
                      );

                      final statsRow = profileAsync.when(
                        data: (profile) => profile != null ? _StatsRow(profile: profile) : const SizedBox.shrink(),
                        loading: () => const _LoadingCard(),
                        error: (_, __) => const SizedBox.shrink(),
                      );

                      final dailyChallenge = _DailyChallengeCard(
                        onTap: () => Navigator.of(context).pushNamed('/daily_challenge'),
                      );
                      
                      final weeklyCase = const WeeklyCaseCard();

                      if (isDesktop) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 1),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      continueBanner,
                                      const SizedBox(height: GameTokens.spaceLg),
                                      statsRow,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: GameTokens.spaceLg),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      dailyChallenge,
                                      const SizedBox(height: GameTokens.spaceLg),
                                      weeklyCase,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 2),
                            const GameDivider(label: '// BUREAU TOOLS'),
                            const SizedBox(height: GameTokens.spaceMd),
                            _BureauToolsList(context: context),
                            const Spacer(flex: 1),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 1),
                          continueBanner,
                          const SizedBox(height: GameTokens.spaceLg),
                          const Spacer(flex: 1),
                          statsRow,
                          const SizedBox(height: GameTokens.spaceLg),
                          const Spacer(flex: 1),
                          dailyChallenge,
                          const SizedBox(height: GameTokens.spaceMd),
                          weeklyCase,
                          const SizedBox(height: GameTokens.spaceLg),
                          const Spacer(flex: 2),
                          const GameDivider(label: '// BUREAU TOOLS'),
                          const SizedBox(height: GameTokens.spaceMd),
                          _BureauToolsList(context: context),
                          const Spacer(flex: 1),
                        ],
                      );
                    },
                  ),
                ),
              ),
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
      'world_05': 'The Subquery Labyrinth',
      'world_06': 'Window Function District',
      'world_07': 'Data Modification Zone',
      'world_08': 'Transaction Vault',
      'world_09': 'The Optimization Engine',
      'world_10': 'Advanced Analytics Bureau',
    };

    final name = worldNames[current.worldId] ?? current.worldId;
    final progress = current.totalLevels > 0
        ? current.levelsCompleted / current.totalLevels
        : 0.0;

    return ActionButton(
      isPrimary: true,
      onPressed: onContinue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceLg),
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
    // IntrinsicHeight removed: it forces a 2-pass layout that can crash inside
    // SliverFillRemaining. Cards use mainAxisAlignment to distribute space.
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.85,
                      maxChildSize: 0.95,
                      minChildSize: 0.5,
                      builder: (_, controller) => StreakCalendarModal(scrollController: controller),
                    ),
                  ),
                ),
              );
            },
            child: SlantedPanel(
              padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: GameTokens.warning, size: 20),
                      const SizedBox(width: 4),
                      Text('STREAK', style: GameTokens.bodyMedium),
                      const Spacer(),
                      // Streak freeze badge
                      if ((profile.streakFreezeAvailable as int? ?? 0) > 0)
                        Tooltip(
                          message: '${profile.streakFreezeAvailable} Streak Freeze available',
                          child: const Icon(Icons.ac_unit, color: GameTokens.info, size: 13),
                        ),
                    ],
                  ),
                  Text(
                    '${profile.streakCount} days',
                    style: GameTokens.headlineMedium.copyWith(
                      color: GameTokens.warning,
                      fontSize: 24,
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
            padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: GameTokens.accent, size: 20),
                    const SizedBox(width: 4),
                    Text('XP', style: GameTokens.bodyMedium),
                  ],
                ),
                Text(
                  '${profile.totalXp}',
                  style: GameTokens.headlineMedium.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                _XpProgressBar(totalXp: profile.totalXp as int),
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
                builder: (context) => Align(
                  alignment: Alignment.bottomCenter,
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
              padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_outlined,
                          color: GameTokens.accent, size: 20),
                      const SizedBox(width: 4),
                      Text('RANK', style: GameTokens.bodyMedium),
                    ],
                  ),
                  Text(
                    profile.rankTitle,
                    style: GameTokens.bodyMedium.copyWith(
                      color: GameTokens.accent,
                      fontWeight: FontWeight.bold,
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
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DailyChallengeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceSm, vertical: GameTokens.spaceLg),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
    )).animate().fadeIn(delay: 300.ms, duration: 400.ms);
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
      _BureauToolItem(Icons.person_outline, 'AGENT PROFILE', 'View your career stats', '/profile'),
      _BureauToolItem(Icons.settings_outlined, 'SETTINGS', 'System configuration', '/settings'),
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

/// Compact XP progress bar showing progress toward the next rank.
class _XpProgressBar extends StatelessWidget {
  final int totalXp;
  const _XpProgressBar({required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final tiers = RankSystem.tiers;
    final isMaxRank = totalXp >= tiers.last.requiredXp;

    // Find the index of the current tier (the highest tier the player has reached).
    // indexWhere returns the first tier whose XP requirement exceeds totalXp.
    // Subtracting 1 gives the tier the player is currently in.
    final nextTierIndex = tiers.indexWhere((t) => t.requiredXp > totalXp);
    // If nextTierIndex == -1, player has exceeded all tiers (max rank).
    // If nextTierIndex == 0, player hasn't reached the first tier threshold yet.
    final currentIndex = nextTierIndex == -1
        ? tiers.length - 1
        : (nextTierIndex - 1).clamp(0, tiers.length - 2);

    if (isMaxRank) {
      return Row(
        children: [
          Icon(Icons.all_inclusive, color: tiers.last.color, size: 10),
          const SizedBox(width: 4),
          Text(
            'MAX RANK',
            style: GameTokens.bodySmall.copyWith(
              fontSize: 9, color: tiers.last.color, letterSpacing: 1,
            ),
          ),
        ],
      );
    }

    final currentTier = tiers[currentIndex];
    final nextTier = tiers[currentIndex + 1];
    final rangeXp = nextTier.requiredXp - currentTier.requiredXp;
    final earnedXp = totalXp - currentTier.requiredXp;
    final progress = (earnedXp / rangeXp).clamp(0.0, 1.0);
    final xpLeft = nextTier.requiredXp - totalXp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: GameTokens.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(GameTokens.accent),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$xpLeft XP to ${nextTier.title}',
          style: GameTokens.bodySmall.copyWith(
            fontSize: 9,
            color: GameTokens.secondaryText,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
