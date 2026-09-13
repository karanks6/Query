import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';

class WeeklyCaseCard extends ConsumerWidget {
  const WeeklyCaseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we'd check if the user completed the weekly case this week.
    final isCompleted = false;
    final timeRemaining = "2 days left";

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
              Text(
                timeRemaining,
                style: const TextStyle(color: GameTokens.primaryText, fontSize: 12),
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
              if (isCompleted)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: GameTokens.success, size: 16),
                    const SizedBox(width: 4),
                    const Text('CRACKED', style: TextStyle(color: GameTokens.success, fontWeight: FontWeight.bold)),
                  ],
                )
              else
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
