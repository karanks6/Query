import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../gameplay_provider.dart';

class QueryHistorySheet extends ConsumerStatefulWidget {
  final String levelId;

  const QueryHistorySheet({super.key, required this.levelId});

  @override
  ConsumerState<QueryHistorySheet> createState() => _QueryHistorySheetState();
}

class _QueryHistorySheetState extends ConsumerState<QueryHistorySheet> {
  bool _loading = true;
  List<dynamic> _attempts = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final dao = ref.read(attemptsDaoProvider);
    final attempts = await dao.getRecentAttemptsForLevel(widget.levelId, limit: 10);
    if (mounted) {
      setState(() {
        _attempts = attempts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameTokens.spaceLg),
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: GameTokens.accent, size: 24),
              const SizedBox(width: 12),
              Text(
                'QUERY HISTORY',
                style: GameTokens.headlineMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: GameTokens.secondaryText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: GameTokens.spaceMd),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(GameTokens.accent),
              ),
            )
          else if (_attempts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: GameTokens.spaceXl),
              child: Center(
                child: Text(
                  'No previous attempts yet.',
                  style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _attempts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final attempt = _attempts[index];
                  final isSuccess = attempt.passedResult;
                  final color = isSuccess ? GameTokens.success : GameTokens.error;
                  final date = DateTime.fromMillisecondsSinceEpoch(attempt.createdAt);
                  final timeString = DateFormat.Hm().format(date);

                  return SlantedPanel(
                    borderColorOverride: color.withValues(alpha: 0.5),
                    padding: const EdgeInsets.all(GameTokens.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: color,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Attempt #${attempt.attemptNumber}',
                              style: GameTokens.bodySmall.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              timeString,
                              style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GameTokens.background,
                            borderRadius: GameTokens.borderRadiusSm,
                          ),
                          child: SelectableText(
                            attempt.submittedQuery,
                            style: GameTokens.codeSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.restore, size: 14),
                            label: const Text('RESTORE'),
                            style: TextButton.styleFrom(
                              foregroundColor: GameTokens.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () {
                              ref.read(gameplayProvider.notifier).updateQuery(attempt.submittedQuery);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
