import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/app_theme.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(activeTokensProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Daily Leaderboard', style: TextStyle(color: tokens.primaryText)),
        backgroundColor: tokens.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: tokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          final isTopThree = index < 3;
          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTopThree ? tokens.accent : tokens.surfaceVariant,
                width: isTopThree ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: isTopThree ? tokens.accent : tokens.secondaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundColor: tokens.background,
                  child: Icon(Icons.person, color: tokens.primaryText, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detective_${1000 + index * 42}',
                    style: TextStyle(color: tokens.primaryText, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${15000 - (index * 850)} XP',
                  style: TextStyle(color: tokens.secondaryText),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
