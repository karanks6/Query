import 'package:flutter/material.dart';
import '../../../../theming/tokens/game_tokens.dart';

class RankTier {
  final String title;
  final int requiredXp;
  final IconData icon;
  final Color color;

  const RankTier({
    required this.title,
    required this.requiredXp,
    required this.icon,
    required this.color,
  });
}

class RankSystem {
  static const List<RankTier> tiers = [
    RankTier(
      title: 'Junior Analyst',
      requiredXp: 0,
      icon: Icons.badge_outlined,
      color: const Color(0xFF90A4AE), // Brighter blue grey
    ),
    RankTier(
      title: 'Data Sleuth',
      requiredXp: 500,
      icon: Icons.search,
      color: GameTokens.accent,
    ),
    RankTier(
      title: 'Field Detective',
      requiredXp: 1000,
      icon: Icons.policy_outlined,
      color: Colors.blueAccent,
    ),
    RankTier(
      title: 'Query Specialist',
      requiredXp: 2500,
      icon: Icons.psychology,
      color: Colors.purpleAccent,
    ),
    RankTier(
      title: 'Senior Investigator',
      requiredXp: 5000,
      icon: Icons.gavel,
      color: Colors.deepOrangeAccent,
    ),
    RankTier(
      title: 'Cyber Operative',
      requiredXp: 7500,
      icon: Icons.memory,
      color: GameTokens.warning,
    ),
    RankTier(
      title: 'Bureau Chief',
      requiredXp: 10000,
      icon: Icons.account_balance,
      color: GameTokens.error,
    ),
    RankTier(
      title: 'Master Architect',
      requiredXp: 20000,
      icon: Icons.architecture,
      color: Colors.cyanAccent,
    ),
    RankTier(
      title: 'The Oracle',
      requiredXp: 50000,
      icon: Icons.all_inclusive,
      color: Colors.amberAccent,
    ),
  ];

  static RankTier getRankForXp(int xp) {
    for (int i = tiers.length - 1; i >= 0; i--) {
      if (xp >= tiers[i].requiredXp) {
        return tiers[i];
      }
    }
    return tiers.first;
  }
}
