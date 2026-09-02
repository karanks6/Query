import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/terminal_widgets.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'LEADERBOARD',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(SciFiTokens.spaceLg),
          itemCount: 10,
          itemBuilder: (context, index) {
            final isTopThree = index < 3;
            return Padding(
              padding: const EdgeInsets.only(bottom: SciFiTokens.spaceMd),
              child: HoloPanel(
                emissionIntensity: isTopThree ? 0.3 : 0.05,
                borderColorOverride: isTopThree ? SciFiTokens.accent : SciFiTokens.accentDim,
                padding: const EdgeInsets.all(SciFiTokens.spaceMd),
                child: Row(
                  children: [
                    Text(
                      '#${index + 1}',
                      style: SciFiTokens.headlineMedium.copyWith(
                        color: isTopThree ? SciFiTokens.accent : SciFiTokens.secondaryText,
                      ),
                    ),
                    const SizedBox(width: SciFiTokens.spaceLg),
                    CircleAvatar(
                      backgroundColor: SciFiTokens.surfaceVariant,
                      child: const Icon(Icons.person, color: SciFiTokens.primaryText, size: 20),
                    ),
                    const SizedBox(width: SciFiTokens.spaceMd),
                    Expanded(
                      child: Text(
                        'Detective_${1000 + index * 42}',
                        style: SciFiTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${15000 - (index * 850)} XP',
                      style: SciFiTokens.code.copyWith(color: SciFiTokens.secondaryText),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
