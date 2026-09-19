import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../../../theming/components/action_button.dart';
import '../../../features/weekly_case/weekly_case_service.dart';
import '../../../core/providers.dart';

class WeeklyCaseCard extends ConsumerStatefulWidget {
  const WeeklyCaseCard({super.key});

  @override
  ConsumerState<WeeklyCaseCard> createState() => _WeeklyCaseCardState();
}

class _WeeklyCaseCardState extends ConsumerState<WeeklyCaseCard> {
  WeeklyCase? _case;
  bool _isLoading = true;
  int _completedParts = 0;
  Duration _timeUntilReset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _load();
    _timeUntilReset = WeeklyCaseService.instance.timeUntilReset();
  }

  Future<void> _load() async {
    try {
      final wcase = await WeeklyCaseService.instance.getCurrentCase();
      if (wcase == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Count how many parts are completed in the DB
      final db = ref.read(appDatabaseProvider);
      int done = 0;
      for (final level in wcase.levels) {
        final row = await (db.select(db.levelCompletions)
              ..where((l) => l.levelId.equals(level.id)))
            .getSingleOrNull();
        if (row != null) done++;
      }

      if (mounted) {
        setState(() {
          _case = wcase;
          _completedParts = done;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    if (days > 0) return '${days}d ${hours}h';
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SlantedPanel(
        padding: const EdgeInsets.all(16),
        borderColorOverride: GameTokens.warning,
        child: const SizedBox(
          height: 60,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation(GameTokens.warning),
            ),
          ),
        ),
      );
    }

    if (_case == null) return const SizedBox.shrink();

    final totalParts = _case!.levels.length;
    final isCompleted = _completedParts >= totalParts;
    final progress = totalParts > 0 ? _completedParts / totalParts : 0.0;

    return SlantedPanel(
      padding: const EdgeInsets.all(16),
      borderColorOverride: GameTokens.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_special_outlined,
                      color: GameTokens.warning, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'WEEKLY CASE FILE',
                    style: TextStyle(
                      color: GameTokens.warning,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                'Resets in ${_formatDuration(_timeUntilReset)}',
                style: const TextStyle(
                    color: GameTokens.secondaryText, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Title ─────────────────────────────────────────────────────
          Text(
            _case!.title,
            style: TextStyle(
              color: GameTokens.accent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Client: ${_case!.client}',
            style: const TextStyle(color: GameTokens.secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // ── Progress bar ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: GameTokens.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(
                        isCompleted ? GameTokens.success : GameTokens.warning),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_completedParts / $totalParts parts',
                style: TextStyle(
                    color: isCompleted ? GameTokens.success : GameTokens.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Bottom row: XP + CTA ──────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.military_tech,
                        color: GameTokens.warning, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+${_case!.xpReward} XP',
                      style: const TextStyle(
                          color: GameTokens.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Row(
                  children: [
                    const Icon(Icons.verified, color: GameTokens.success, size: 16),
                    const SizedBox(width: 6),
                    Text('CASE CLOSED',
                        style: TextStyle(
                            color: GameTokens.success,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12)),
                  ],
                )
              else
                ActionButton(
                  isPrimary: true,
                  onPressed: () => Navigator.of(context).pushNamed('/weekly_case'),
                  child: Text(
                    _completedParts > 0 ? 'CONTINUE CASE' : 'START INVESTIGATION',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}
