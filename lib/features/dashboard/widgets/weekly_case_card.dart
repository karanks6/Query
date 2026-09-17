import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../../../theming/components/action_button.dart';

class WeeklyCaseCard extends ConsumerWidget {
  const WeeklyCaseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace hardcoded values with real data from WeeklyCaseCompletion DB table.

    return SlantedPanel(
      padding: const EdgeInsets.all(16),
      borderColorOverride: GameTokens.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: GameTokens.warning, size: 20),
                  const SizedBox(width: 8),
                  Text('WEEKLY CASE FILE', style: TextStyle(fontFamily: 'FiraCode', color: GameTokens.warning, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text(
                '2 days left', // TODO: calculate from weekly case expiry date
                style: TextStyle(color: GameTokens.primaryText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The Rogue Process',
            style: TextStyle(color: GameTokens.accent, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'A rogue process is spawning unauthorized child threads. Track down the source ID.',
            style: TextStyle(color: GameTokens.primaryText, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.military_tech, color: GameTokens.warning, size: 14),
                    const SizedBox(width: 4),
                    const Text('+500 XP', style: TextStyle(color: GameTokens.warning, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              // TODO: Replace with completed-state check from WeeklyCaseCompletion table.
              // When isCompleted is true, show the 'CRACKED' row instead of the button.
              ActionButton(
                isPrimary: true,
                onPressed: () {
                  // Navigate to weekly case level
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to Weekly Case (Mock)')),
                  );
                },
                child: const Text('START INVESTIGATION'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
