import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../shared/widgets/game_widgets.dart';
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
      backgroundColor: Colors.transparent,
      appBar: GameAppBar(
        title: 'DAILY CYPHER',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: GameTokens.accent))
            : _todayChallenge == null
                ? const Center(
                    child: Text(
                      'NO CYPHER AVAILABLE.',
                      style: TextStyle(color: GameTokens.error),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: GameTokens.spaceXl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SlantedPanel(
                              padding: const EdgeInsets.all(GameTokens.spaceMd),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer, color: GameTokens.accent),
                                  const SizedBox(width: GameTokens.spaceMd),
                                  Text(
                                    _formatDuration(_timeUntilTomorrow),
                                    style: GameTokens.headlineMedium.copyWith(color: GameTokens.accent),
                                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white),
                                ],
                              ),
                            ),
                            const SizedBox(height: GameTokens.spaceXl),
                            SlantedPanel(
                              padding: const EdgeInsets.all(GameTokens.spaceLg),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _todayChallenge!.title.toUpperCase(),
                                    style: GameTokens.headlineMedium.copyWith(color: GameTokens.primaryText),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: GameTokens.spaceLg),
                                  Container(
                                    padding: const EdgeInsets.all(GameTokens.spaceMd),
                                    decoration: BoxDecoration(
                                      color: GameTokens.surface,
                                      border: Border.all(color: GameTokens.accentDim),
                                      borderRadius: GameTokens.borderRadiusSm,
                                    ),
                                    child: Text(
                                      _todayChallenge!.narrative,
                                      style: GameTokens.code.copyWith(color: GameTokens.secondaryText, height: 1.5),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: GameTokens.spaceXl),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceSm),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: GameTokens.warning),
                                      borderRadius: GameTokens.borderRadiusSm,
                                      color: GameTokens.warning.withValues(alpha: 0.1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.stars, color: GameTokens.warning, size: 20),
                                        const SizedBox(width: GameTokens.spaceSm),
                                        Text(
                                          'REWARD: +500 XP, 1x CYBER KEY',
                                          style: GameTokens.labelLarge.copyWith(color: GameTokens.warning),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: GameTokens.spaceXl),
                                  ActionButton(
                                    isPrimary: true,
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        '/daily_challenge_gameplay',
                                        arguments: _todayChallenge,
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceSm),
                                      child: Text('START CHALLENGE'),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 1.5.seconds, color: GameTokens.accent.withValues(alpha: 0.5)),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                          ],
                        ),
                      ),
                    ),
      ),
    );
  }
}
