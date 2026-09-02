import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../theming/components/holo_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/terminal_widgets.dart';
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
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'DAILY_CHALLENGE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _todayChallenge == null
                ? const Center(
                    child: Text(
                      'No challenge available today.',
                      style: TextStyle(color: SciFiTokens.error),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: HoloPanel(
                        padding: const EdgeInsets.all(SciFiTokens.spaceLg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 64, color: SciFiTokens.accent),
                            const SizedBox(height: SciFiTokens.spaceLg),
                            Text(
                              _todayChallenge!.title,
                              style: SciFiTokens.headlineMedium.copyWith(color: SciFiTokens.accent),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: SciFiTokens.spaceMd),
                            Text(
                              _todayChallenge!.narrative,
                              style: SciFiTokens.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: SciFiTokens.spaceLg),
                            HoloPanel(
                              emissionIntensity: 0.1,
                              padding: const EdgeInsets.all(SciFiTokens.spaceMd),
                              child: Column(
                                children: [
                                  Text(
                                    'NEXT CHALLENGE IN:',
                                    style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText),
                                  ),
                                  const SizedBox(height: SciFiTokens.spaceSm),
                                  Text(
                                    _formatDuration(_timeUntilTomorrow),
                                    style: SciFiTokens.headlineLarge.copyWith(color: SciFiTokens.accent),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: SciFiTokens.spaceXl),
                            HoloButton(
                              isPrimary: true,
                              child: const Text('START CHALLENGE'),
                              onPressed: () {
                                Navigator.of(context).pushNamed('/gameplay', arguments: _todayChallenge);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
