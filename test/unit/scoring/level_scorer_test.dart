import 'package:flutter_test/flutter_test.dart';
import 'package:query/core/scoring/level_scorer.dart';
import 'package:query/data/content/models/level_model.dart';

void main() {
  group('LevelScorer Unit Tests', () {
    const defaultThresholds = LevelTimingThresholds(
      goldMs: 30000,
      silverMs: 60000,
      bronzeMs: 90000,
    );

    test('Awards all 3 stars for first-attempt optimal solution', () {
      final score = LevelScorer.instance.compute(
        resultPassed: true,
        performancePassed: true,
        isFirstAttempt: true,
        attemptNumber: 1,
        highestHintUsed: HintTier.none,
        durationMs: 25000,
        timingThresholds: defaultThresholds,
        baseXpReward: 100,
        performanceActive: true,
      );

      expect(score.completionStar, isTrue);
      expect(score.optimalStar, isTrue);
      expect(score.firstAttemptStar, isTrue);
      expect(score.starCount, equals(3));
      expect(score.timeMedal, equals(TimeMedal.gold));
      // Base: 100 + Optimal: 25 + FirstAttempt: 25 + GoldMedal: 50 = 200
      expect(score.xpEarned, equals(200));
      expect(score.hintCapApplied, isFalse);
    });

    test('Full solution hint caps rating at 1 star even if optimal and first attempt', () {
      final score = LevelScorer.instance.compute(
        resultPassed: true,
        performancePassed: true,
        isFirstAttempt: true,
        attemptNumber: 1,
        highestHintUsed: HintTier.fullSolution,
        durationMs: 45000,
        timingThresholds: defaultThresholds,
        baseXpReward: 100,
        performanceActive: true,
      );

      expect(score.completionStar, isTrue);
      expect(score.optimalStar, isFalse);
      expect(score.firstAttemptStar, isFalse);
      expect(score.starCount, equals(1));
      expect(score.hintCapApplied, isTrue);
    });

    test('Correctly computes Silver and Bronze time medals', () {
      final silverScore = LevelScorer.instance.compute(
        resultPassed: true,
        performancePassed: false,
        isFirstAttempt: false,
        attemptNumber: 2,
        highestHintUsed: HintTier.none,
        durationMs: 55000,
        timingThresholds: defaultThresholds,
        baseXpReward: 100,
        performanceActive: true,
      );
      expect(silverScore.timeMedal, equals(TimeMedal.silver));
      // Base: 100 + SilverMedal: 25 = 125
      expect(silverScore.xpEarned, equals(125));

      final bronzeScore = LevelScorer.instance.compute(
        resultPassed: true,
        performancePassed: false,
        isFirstAttempt: false,
        attemptNumber: 3,
        highestHintUsed: HintTier.none,
        durationMs: 85000,
        timingThresholds: defaultThresholds,
        baseXpReward: 100,
        performanceActive: true,
      );
      expect(bronzeScore.timeMedal, equals(TimeMedal.bronze));
      // Base: 100 + BronzeMedal: 10 = 110
      expect(bronzeScore.xpEarned, equals(110));
    });

    test('Daily challenge multiplier doubles total XP earned', () {
      final score = LevelScorer.instance.compute(
        resultPassed: true,
        performancePassed: true,
        isFirstAttempt: true,
        attemptNumber: 1,
        highestHintUsed: HintTier.none,
        durationMs: null,
        timingThresholds: null,
        baseXpReward: 100,
        performanceActive: false,
        dailyMultiplier: 2.0,
      );

      // (100 base + 25 optimal + 25 firstAttempt) * 2.0 = 300
      expect(score.xpEarned, equals(300));
      expect(score.dailyBonusApplied, isTrue);
    });

    test('Detective mode applies 25% XP reduction penalty', () {
      final score = LevelScorer.instance.compute(
        resultPassed: true,
        performancePassed: false,
        isFirstAttempt: false,
        attemptNumber: 2,
        highestHintUsed: HintTier.none,
        durationMs: null,
        timingThresholds: null,
        baseXpReward: 100,
        performanceActive: true,
        isDetectiveMode: true,
      );

      // 100 * 0.75 = 75
      expect(score.xpEarned, equals(75));
    });

    test('Zero stars and zero XP when result fails', () {
      final score = LevelScorer.instance.compute(
        resultPassed: false,
        performancePassed: false,
        isFirstAttempt: false,
        attemptNumber: 1,
        highestHintUsed: HintTier.none,
        durationMs: 15000,
        timingThresholds: defaultThresholds,
        baseXpReward: 100,
        performanceActive: true,
      );

      expect(score.completionStar, isFalse);
      expect(score.optimalStar, isFalse);
      expect(score.firstAttemptStar, isFalse);
      expect(score.starCount, equals(0));
      expect(score.xpEarned, equals(0));
      expect(score.timeMedal, isNull);
    });
  });
}
