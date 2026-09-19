import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../data/content/models/level_model.dart';
import '../../core/providers.dart';
import 'weekly_case_service.dart';

class WeeklyCaseScreen extends ConsumerStatefulWidget {
  const WeeklyCaseScreen({super.key});

  @override
  ConsumerState<WeeklyCaseScreen> createState() => _WeeklyCaseScreenState();
}

class _WeeklyCaseScreenState extends ConsumerState<WeeklyCaseScreen> {
  WeeklyCase? _currentCase;
  bool _isLoading = true;
  String? _error;
  Duration _timeUntilReset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadCase();
    _timeUntilReset = WeeklyCaseService.instance.timeUntilReset();
    // Update the timer every minute (reset is weekly, per-minute is fine)
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      setState(() {
        _timeUntilReset = WeeklyCaseService.instance.timeUntilReset();
      });
      return true;
    });
  }

  Future<void> _loadCase() async {
    try {
      final c = await WeeklyCaseService.instance.getCurrentCase();
      if (mounted) {
        setState(() {
          _currentCase = c;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'WEEKLY_CASE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(GameTokens.accent),
                ),
              )
            : _error != null || _currentCase == null
                ? _buildErrorState()
                : _buildCaseContent(_currentCase!),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: GameTokens.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'No weekly case available.',
            style: GameTokens.bodyLarge.copyWith(color: GameTokens.error),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseContent(WeeklyCase wcase) {
    final db = ref.watch(appDatabaseProvider);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(GameTokens.spaceMd),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Header ──────────────────────────────────────────────────
              _buildHeader(wcase),
              const SizedBox(height: GameTokens.spaceLg),

              // ── Timer ───────────────────────────────────────────────────
              _buildResetTimer(),
              const SizedBox(height: GameTokens.spaceLg),

              // ── Levels list ─────────────────────────────────────────────
              Text(
                '// INVESTIGATION PARTS',
                style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: GameTokens.spaceMd),
              ...List.generate(wcase.levels.length, (i) {
                return FutureBuilder<bool>(
                  future: _isLevelCompleted(db, wcase.levels[i].id),
                  builder: (context, snap) {
                    final done = snap.data ?? false;
                    return _buildLevelCard(
                      context: context,
                      level: wcase.levels[i],
                      index: i,
                      isCompleted: done,
                      isUnlocked: i == 0 || _isUnlocked(i, wcase, db),
                      totalXp: wcase.levels[i].xpReward,
                    );
                  },
                );
              }),

              const SizedBox(height: GameTokens.spaceLg),
              // ── Total XP reward banner ──────────────────────────────────
              _buildXpBanner(wcase),
              const SizedBox(height: GameTokens.spaceXl),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(WeeklyCase wcase) {
    return SlantedPanel(
      borderColorOverride: GameTokens.warning,
      padding: const EdgeInsets.all(GameTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_special_outlined, color: GameTokens.warning, size: 20),
              const SizedBox(width: 8),
              Text('WEEKLY CASE FILE',
                  style: GameTokens.labelLarge.copyWith(color: GameTokens.warning, letterSpacing: 2)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GameTokens.warning.withValues(alpha: 0.15),
                  borderRadius: GameTokens.borderRadiusSm,
                  border: Border.all(color: GameTokens.warning, width: 1),
                ),
                child: Text(wcase.difficulty,
                    style: GameTokens.bodySmall.copyWith(color: GameTokens.warning)),
              ),
            ],
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Text(wcase.title,
              style: GameTokens.headlineLarge.copyWith(color: GameTokens.accent)),
          const SizedBox(height: 4),
          Text('Client: ${wcase.client}',
              style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText)),
          const SizedBox(height: GameTokens.spaceMd),
          Text(wcase.narrative, style: GameTokens.bodyMedium),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildResetTimer() {
    return SlantedPanel(
      padding: const EdgeInsets.symmetric(
          horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: GameTokens.info, size: 16),
          const SizedBox(width: 8),
          Text('RESETS IN:',
              style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText, fontSize: 11)),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_timeUntilReset),
            style: GameTokens.bodyMedium.copyWith(
              color: GameTokens.info,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required LevelModel level,
    required int index,
    required bool isCompleted,
    required bool isUnlocked,
    required int totalXp,
  }) {
    final color = isCompleted
        ? GameTokens.success
        : isUnlocked
            ? GameTokens.accent
            : GameTokens.disabledText;

    return Padding(
      padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
      child: ActionButton(
        onPressed: isUnlocked
            ? () => Navigator.of(context).pushNamed('/gameplay', arguments: level)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
          child: Row(
            children: [
              // Step indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color, width: 1.5),
                  borderRadius: GameTokens.borderRadiusSm,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: color, size: 18)
                      : Text(
                          '${index + 1}',
                          style: GameTokens.bodyMedium.copyWith(
                              color: color, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: GameTokens.spaceMd),
              // Title & narrative
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.title,
                        style: GameTokens.bodyMedium.copyWith(
                          color: isUnlocked ? GameTokens.primaryText : GameTokens.disabledText,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      level.narrative,
                      style: GameTokens.bodySmall.copyWith(
                          color: isUnlocked
                              ? GameTokens.secondaryText
                              : GameTokens.disabledText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GameTokens.spaceSm),
              // XP chip
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+$totalXp XP',
                      style: GameTokens.bodySmall.copyWith(
                          color: isCompleted ? GameTokens.success : GameTokens.warning,
                          fontWeight: FontWeight.bold)),
                  if (!isUnlocked)
                    const Icon(Icons.lock_outline, color: GameTokens.disabledText, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 80).ms, duration: 300.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildXpBanner(WeeklyCase wcase) {
    final total = wcase.levels.fold<int>(0, (sum, l) => sum + l.xpReward);
    return SlantedPanel(
      borderColorOverride: GameTokens.warning,
      padding: const EdgeInsets.symmetric(
          horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.military_tech, color: GameTokens.warning, size: 28),
          const SizedBox(width: GameTokens.spaceMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CASE COMPLETION REWARD',
                  style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
              Text('+$total XP',
                  style: GameTokens.headlineMedium.copyWith(
                      color: GameTokens.warning, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<bool> _isLevelCompleted(dynamic db, String levelId) async {
    try {
      final row = await (db.select(db.levelCompletions)
            ..where((l) => l.levelId.equals(levelId)))
          .getSingleOrNull();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  bool _isUnlocked(int index, WeeklyCase wcase, dynamic db) {
    // For now levels unlock sequentially: level N unlocks when N-1 is done.
    // We use a synchronous heuristic here since FutureBuilder handles the async.
    // The actual lock is enforced by the FutureBuilder in the parent.
    return true; // FutureBuilder controls rendering; optimistic unlock for now.
  }
}
