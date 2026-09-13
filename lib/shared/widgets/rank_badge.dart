import 'package:flutter/material.dart';
import '../../data/content/models/rank_system.dart';

class RankBadge extends StatelessWidget {
  final RankTier rank;
  final double size;

  const RankBadge({
    super.key,
    required this.rank,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: rank.color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: rank.color.withValues(alpha: 0.6),
          width: size * 0.05,
        ),
        boxShadow: [
          BoxShadow(
            color: rank.color.withValues(alpha: 0.2),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          rank.icon,
          color: rank.color,
          size: size * 0.5,
        ),
      ),
    );
  }
}
