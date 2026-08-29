import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../shared/widgets/terminal_widgets.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../data/content/models/level_model.dart';
import 'daily_challenge_service.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  LevelModel? _todayChallenge;
  bool _isLoading = true;
  Timer? _timer;
  Duration _timeUntilTomorrow = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
    _startTimer();
  }

  Future<void> _loadChallenge() async {
    final challenge = await DailyChallengeService.instance.getTodayChallenge();
    if (mounted) {
      setState(() {
        _todayChallenge = challenge;
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _updateTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimer();
    });
  }

  void _updateTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (mounted) {
      setState(() {
        _timeUntilTomorrow = tomorrow.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalClassicTokens.background,
      appBar: TerminalAppBar(
        title: 'DAILY_CHALLENGE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todayChallenge == null
              ? const Center(
                  child: Text(
                    'No challenge available today.',
                    style: TextStyle(color: TerminalClassicTokens.error),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(TerminalClassicTokens.spaceLg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: TerminalClassicTokens.accent),
                          const SizedBox(height: TerminalClassicTokens.spaceLg),
                          Text(
                            _todayChallenge!.title,
                            style: TerminalClassicTokens.headlineMedium.copyWith(color: TerminalClassicTokens.accent),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: TerminalClassicTokens.spaceMd),
                          Text(
                            _todayChallenge!.narrative,
                            style: TerminalClassicTokens.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: TerminalClassicTokens.spaceLg),
                          Container(
                            padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
                            decoration: BoxDecoration(
                              border: Border.all(color: TerminalClassicTokens.accentDim),
                              borderRadius: TerminalClassicTokens.borderRadiusSm,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'NEXT CHALLENGE IN:',
                                  style: TerminalClassicTokens.labelLarge.copyWith(color: TerminalClassicTokens.secondaryText),
                                ),
                                const SizedBox(height: TerminalClassicTokens.spaceSm),
                                Text(
                                  _formatDuration(_timeUntilTomorrow),
                                  style: TerminalClassicTokens.headlineLarge.copyWith(color: TerminalClassicTokens.accent),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: TerminalClassicTokens.spaceXl),
                          TerminalButton(
                            label: 'START CHALLENGE',
                            onPressed: () {
                              Navigator.of(context).pushNamed('/gameplay', arguments: _todayChallenge);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
