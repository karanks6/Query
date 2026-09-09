
/// Computes star ratings and XP for a completed level (Section 4.3).
///
/// Stars:
///   ★ Completion — result set matched expected output
///   ★ Optimal Query — passed performance layer threshold
///   ★ First-Attempt Success — correct on the very first submitted query
///
/// Time Medal (Bronze/Silver/Gold) — awarded separately if a timed run.
/// Using a Full Solution hint caps rating at 1 star (completion only).
class LevelScorer {
  LevelScorer._();
  static final LevelScorer instance = LevelScorer._();

  LevelScore compute({
    required bool resultPassed,
    required bool performancePassed,
    required bool isFirstAttempt,
    required int attemptNumber,
    required HintTier highestHintUsed,
    required int? durationMs,
    required LevelTimingThresholds? timingThresholds,
    required int baseXpReward,
    required bool performanceActive,
    double dailyMultiplier = 1.0,
  }) {
    // Full solution hint caps at 1 star
    final hintCapApplied = highestHintUsed == HintTier.fullSolution;

    final completionStar = resultPassed;
    final optimalStar = resultPassed &&
        (performanceActive ? performancePassed : true) &&
        !hintCapApplied;
    final firstAttemptStar = resultPassed && isFirstAttempt && !hintCapApplied;

    final stars = [completionStar, optimalStar, firstAttemptStar];
    final starCount = stars.where((s) => s).length;

    // XP: base + bonus per extra star + first-attempt bonus
    int xpEarned = resultPassed ? baseXpReward : 0;
    if (optimalStar) xpEarned += (baseXpReward * 0.25).round();
    if (firstAttemptStar) xpEarned += (baseXpReward * 0.25).round();

    // Time medal (only if player opted into a timed run)
    TimeMedal? timeMedal;
    if (durationMs != null && timingThresholds != null && resultPassed) {
      timeMedal = _computeTimeMedal(durationMs, timingThresholds);
      if (timeMedal != null) {
        xpEarned += timeMedal.xpBonus;
      }
    }

    // Apply daily challenge multiplier (2× = double XP)
    if (dailyMultiplier > 1.0) {
      xpEarned = (xpEarned * dailyMultiplier).round();
    }

    return LevelScore(
      completionStar: completionStar,
      optimalStar: optimalStar,
      firstAttemptStar: firstAttemptStar,
      starCount: starCount,
      timeMedal: timeMedal,
      xpEarned: xpEarned,
      hintCapApplied: hintCapApplied,
      dailyBonusApplied: dailyMultiplier > 1.0,
    );
  }

  TimeMedal? _computeTimeMedal(int durationMs, LevelTimingThresholds thresholds) {
    if (durationMs <= thresholds.goldMs) return TimeMedal.gold;
    if (durationMs <= thresholds.silverMs) return TimeMedal.silver;
    if (durationMs <= thresholds.bronzeMs) return TimeMedal.bronze;
    return null;
  }
}

class LevelScore {
  final bool completionStar;
  final bool optimalStar;
  final bool firstAttemptStar;
  final int starCount; // 0–3
  final TimeMedal? timeMedal;
  final int xpEarned;
  final bool hintCapApplied;
  final bool dailyBonusApplied;

  const LevelScore({
    required this.completionStar,
    required this.optimalStar,
    required this.firstAttemptStar,
    required this.starCount,
    this.timeMedal,
    required this.xpEarned,
    required this.hintCapApplied,
    this.dailyBonusApplied = false,
  });

  bool get isPerfect => starCount == 3;
}

enum TimeMedal {
  bronze(xpBonus: 10),
  silver(xpBonus: 25),
  gold(xpBonus: 50);

  final int xpBonus;
  const TimeMedal({required this.xpBonus});
}

class LevelTimingThresholds {
  final int goldMs;
  final int silverMs;
  final int bronzeMs;

  const LevelTimingThresholds({
    required this.goldMs,
    required this.silverMs,
    required this.bronzeMs,
  });

  factory LevelTimingThresholds.fromJson(Map<String, dynamic> json) {
    return LevelTimingThresholds(
      goldMs: json['gold_ms'] as int,
      silverMs: json['silver_ms'] as int,
      bronzeMs: json['bronze_ms'] as int,
    );
  }
}

enum HintTier {
  none,
  nudge,
  partialReveal,
  fullSolution;

  /// Insight Point cost (free grace hint after 3 fails is handled by caller).
  int get cost {
    switch (this) {
      case HintTier.none:
        return 0;
      case HintTier.nudge:
        return 5;
      case HintTier.partialReveal:
        return 15;
      case HintTier.fullSolution:
        return 30;
    }
  }
}
