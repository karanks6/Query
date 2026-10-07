import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../core/providers.dart';
import '../../../core/settings/settings_service.dart';

/// Streak History bottom sheet.
///
/// Shows:
///  - Flame header with current / best / total-active stats
///  - 12-week GitHub-style activity heatmap (colour-coded intensity)
///  - Milestone badges (3 / 7 / 30-day)
///  - Recent activity log (last 5 active days)
class StreakCalendarModal extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final dynamic profile;

  const StreakCalendarModal({
    super.key,
    this.scrollController,
    this.profile,
  });

  @override
  ConsumerState<StreakCalendarModal> createState() => _StreakCalendarModalState();
}

class _StreakCalendarModalState extends ConsumerState<StreakCalendarModal> {
  bool _creatingProfile = false;

  /// If the DB stream emits null, auto-create a profile so the stream
  /// re-emits with a valid row and the modal renders.
  Future<void> _ensureProfile() async {
    if (_creatingProfile) return;
    setState(() => _creatingProfile = true);
    try {
      final dao = ref.read(playerDaoProvider);
      await dao.getProfile(); // getProfile auto-creates if missing
    } finally {
      if (mounted) setState(() => _creatingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(playerProfileProvider);
    final prefs = ref.watch(sharedPreferencesProvider);

    // Prefer live stream data; fall back to the profile passed from the scene
    final currentProfile = profileAsync.valueOrNull ?? widget.profile;

    return Container(
      decoration: const BoxDecoration(
        color: GameTokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Builder(
          builder: (context) {
            // Profile still null after stream loaded → kick off creation
            if (currentProfile == null) {
              if (profileAsync.hasValue && !_creatingProfile) {
                // Stream resolved but emitted null — no profile in DB yet
                WidgetsBinding.instance.addPostFrameCallback((_) => _ensureProfile());
              }
              return const Padding(
                padding: EdgeInsets.all(64),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(GameTokens.accent),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final currentStreak = currentProfile.streakCount as int;
            final longestStreak =
                prefs.getInt('longest_streak') ?? currentStreak;
            final history =
                (prefs.getStringList('streak_history') ?? []).toSet();
            final totalActiveDays = history.length;

            // Determine if today is already recorded
            final todayStr = DateTime.now().toIso8601String().substring(0, 10);
            final isActiveToday = history.contains(todayStr);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ─────────────────────────────────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: GameTokens.disabledText.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // ── Flame header ─────────────────────────────────────────────
                _FlameHeader(
                  currentStreak: currentStreak,
                  isActiveToday: isActiveToday,
                ),

                // ── Stat row ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GameTokens.spaceLg),
                  child: Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                        label: 'CURRENT',
                        value: '$currentStreak',
                        unit: 'days',
                        icon: Icons.local_fire_department,
                        color: GameTokens.warning,
                      )),
                      const SizedBox(width: GameTokens.spaceMd),
                      Expanded(
                          child: _StatCard(
                        label: 'BEST',
                        value: '$longestStreak',
                        unit: 'days',
                        icon: Icons.emoji_events,
                        color: GameTokens.accent,
                      )),
                      const SizedBox(width: GameTokens.spaceMd),
                      Expanded(
                          child: _StatCard(
                        label: 'TOTAL',
                        value: '$totalActiveDays',
                        unit: 'active',
                        icon: Icons.calendar_today,
                        color: GameTokens.info,
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: GameTokens.spaceLg),

                // ── Milestone badges ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GameTokens.spaceLg),
                  child: _MilestoneBadges(
                    currentStreak: currentStreak,
                    longestStreak: longestStreak,
                  ),
                ),

                const SizedBox(height: GameTokens.spaceLg),

                // ── Heatmap label ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GameTokens.spaceLg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LAST 12 WEEKS',
                        style: GameTokens.bodySmall.copyWith(
                          color: GameTokens.disabledText,
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        children: [
                          Text('Less',
                              style: GameTokens.bodySmall
                                  .copyWith(fontSize: 9, color: GameTokens.disabledText)),
                          const SizedBox(width: 4),
                          for (final a in [0.0, 0.4, 0.65, 1.0])
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(left: 2),
                              decoration: BoxDecoration(
                                color: a == 0.0
                                    ? const Color(0xFF4A2E18)
                                    : GameTokens.warning.withValues(alpha: a),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Text('More',
                              style: GameTokens.bodySmall
                                  .copyWith(fontSize: 9, color: GameTokens.disabledText)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GameTokens.spaceSm),

                // ── Heatmap ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GameTokens.spaceLg),
                  child: _ActivityHeatmap(history: history),
                ),

                const SizedBox(height: GameTokens.spaceLg),

                // ── Recent activity log ──────────────────────────────────────
                if (history.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: GameTokens.spaceLg),
                    child: Text(
                      'RECENT ACTIVITY',
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.disabledText,
                        letterSpacing: 1.5,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: GameTokens.spaceSm),
                  _RecentActivityLog(history: history),
                ],

                const SizedBox(height: GameTokens.spaceXl),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Flame header ──────────────────────────────────────────────────────────────

class _FlameHeader extends StatelessWidget {
  final int currentStreak;
  final bool isActiveToday;
  const _FlameHeader(
      {required this.currentStreak, required this.isActiveToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          GameTokens.spaceLg, GameTokens.spaceMd, GameTokens.spaceLg, GameTokens.spaceLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Flame icon with glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      GameTokens.warning.withValues(alpha: 0.25),
                      GameTokens.warning.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Icon(
                currentStreak > 0
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                color: currentStreak > 0
                    ? GameTokens.warning
                    : GameTokens.disabledText,
                size: 48,
              ),
            ],
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.06, 1.06),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.06, 1.06),
                end: const Offset(1.0, 1.0),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),

          const SizedBox(width: GameTokens.spaceLg),

          // Streak count + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$currentStreak',
                      style: GameTokens.headlineLarge.copyWith(
                        fontSize: 48,
                        color: currentStreak > 0
                            ? GameTokens.warning
                            : GameTokens.disabledText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'day streak',
                      style: GameTokens.bodyMedium.copyWith(
                        color: GameTokens.disabledText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActiveToday
                            ? GameTokens.success
                            : GameTokens.disabledText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActiveToday
                          ? "Today's challenge done ✓"
                          : "Play today to keep your streak!",
                      style: GameTokens.bodySmall.copyWith(
                        color: isActiveToday
                            ? GameTokens.success
                            : GameTokens.warning,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: GameTokens.spaceSm, vertical: GameTokens.spaceMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: GameTokens.borderRadiusSm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GameTokens.headlineMedium.copyWith(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            unit,
            style: GameTokens.bodySmall
                .copyWith(color: GameTokens.disabledText, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GameTokens.bodySmall.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Milestone badges ──────────────────────────────────────────────────────────

class _MilestoneBadges extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  const _MilestoneBadges(
      {required this.currentStreak, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    final milestones = [
      (days: 3, label: '3-Day', icon: Icons.looks_3),
      (days: 7, label: '1 Week', icon: Icons.looks_one),
      (days: 14, label: '2 Weeks', icon: Icons.looks_two),
      (days: 30, label: '1 Month', icon: Icons.stars),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STREAK MILESTONES',
          style: GameTokens.bodySmall.copyWith(
            color: GameTokens.disabledText,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: GameTokens.spaceSm),
        Row(
          children: milestones.map((m) {
            final isUnlocked = longestStreak >= m.days;
            final isCurrent = currentStreak >= m.days;
            final color = isCurrent
                ? GameTokens.warning
                : isUnlocked
                    ? GameTokens.accent
                    : GameTokens.accentDim;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isUnlocked ? 0.12 : 0.04),
                        border: Border.all(
                          color: color.withValues(
                              alpha: isUnlocked ? 0.5 : 0.2),
                        ),
                        borderRadius: GameTokens.borderRadiusSm,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isUnlocked ? m.icon : Icons.lock_outline,
                            color: color,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.label,
                            style: GameTokens.bodySmall.copyWith(
                              color: color,
                              fontSize: 9,
                              fontWeight: isUnlocked
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Activity heatmap (12 weeks × 7 days) ──────────────────────────────────────

class _ActivityHeatmap extends StatelessWidget {
  final Set<String> history;
  const _ActivityHeatmap({required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Start from 12 weeks ago, padded to Monday
    final totalDays = 84; // 12 weeks
    final startDate = now.subtract(Duration(days: totalDays - 1));

    // Week labels (Mon–Sun header)
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day-of-week labels
        Row(
          children: [
            const SizedBox(width: 28), // offset for month labels
            ...dayLabels.map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: GameTokens.bodySmall.copyWith(
                      fontSize: 9,
                      color: GameTokens.disabledText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Heatmap grid — weeks as rows, days as columns
        ...List.generate(12, (weekIndex) {
          final weekStart = startDate.add(Duration(days: weekIndex * 7));
          // Month label on the first day of each month
          final monthLabel = weekStart.day <= 7
              ? _monthAbbr(weekStart.month)
              : '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                // Month label
                SizedBox(
                  width: 28,
                  child: Text(
                    monthLabel,
                    style: GameTokens.bodySmall.copyWith(
                      fontSize: 9,
                      color: GameTokens.disabledText,
                    ),
                  ),
                ),
                // 7 day cells
                ...List.generate(7, (dayIndex) {
                  final date = weekStart.add(Duration(days: dayIndex));
                  final dateStr = date.toIso8601String().substring(0, 10);
                  final isActive = history.contains(dateStr);
                  final isToday = dateStr == now.toIso8601String().substring(0, 10);
                  final isFuture = date.isAfter(now);

                  return Expanded(
                    child: Tooltip(
                      message: isActive
                          ? 'Played on $dateStr'
                          : isFuture
                              ? ''
                              : 'No activity on $dateStr',
                      child: Container(
                        height: 14,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          color: isFuture
                              ? Colors.transparent
                              : isActive
                                  ? GameTokens.warning.withValues(alpha: 0.90)
                                  : const Color(0xFF4A2E18), // dark wood brown for inactive
                          border: isToday
                              ? Border.all(
                                  color: Colors.white70, width: 1.5)
                              : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _monthAbbr(int month) {
    const abbr = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return abbr[month];
  }
}

// ── Recent activity log ───────────────────────────────────────────────────────

class _RecentActivityLog extends StatelessWidget {
  final Set<String> history;
  const _RecentActivityLog({required this.history});

  @override
  Widget build(BuildContext context) {
    final sorted = history.toList()..sort((a, b) => b.compareTo(a));
    final recent = sorted.take(5).toList();
    final now = DateTime.now();

    return Column(
      children: recent.asMap().entries.map((entry) {
        final index = entry.key;
        final dateStr = entry.value;
        final date = DateTime.parse(dateStr);
        final diff = now.difference(date).inDays;
        final relLabel = diff == 0
            ? 'Today'
            : diff == 1
                ? 'Yesterday'
                : '$diff days ago';

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceLg, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: GameTokens.warning.withValues(alpha: diff == 0 ? 0.2 : 0.08),
                  border: Border.all(
                    color: GameTokens.warning.withValues(alpha: diff == 0 ? 0.8 : 0.3),
                  ),
                  borderRadius: GameTokens.borderRadiusSm,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: GameTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullDate(date),
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.surface,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      relLabel,
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.disabledText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.local_fire_department,
                  color: GameTokens.warning, size: 14),
            ],
          ),
        ).animate().fadeIn(delay: (index * 60).ms, duration: 250.ms).slideX(begin: 0.05, end: 0);
      }).toList(),
    );
  }

  String _fullDate(DateTime dt) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[dt.weekday]}, ${dt.day} ${months[dt.month]}';
  }
}
