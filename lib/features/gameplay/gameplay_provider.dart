import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/validation/query_validator.dart';
import '../../core/validation/validation_result.dart';
import '../../core/sandbox_engine/sandbox_engine.dart';
import '../../core/scoring/level_scorer.dart';
import '../../data/content/models/level_model.dart';
import '../../core/providers.dart';

// ─── Query mode ───────────────────────────────────────────────────────────────

enum QueryMode { block, code }

// ─── Gameplay state ───────────────────────────────────────────────────────────

class GameplayState {
  final LevelModel? level;
  final QueryMode queryMode;
  final String currentQuery;
  final bool isRunning;
  final QueryValidationReport? lastReport;
  final SandboxException? sandboxError;
  final int attemptCount;
  final HintTier highestHintUsed;
  final bool levelCompleted;
  final LevelScore? levelScore;
  final DateTime? levelStartTime;
  final bool showFeedback;
  final bool schemaExpanded;
  final int existingStars;        // Stars earned on a previous attempt
  final bool isDailyChallenge;    // Whether 2× XP multiplier applies
  final String? hintError;        // Set when IP balance is too low
  final List<String> newlyEarnedAchievements; // IDs earned this session
  final bool isDetectiveMode;

  const GameplayState({
    this.level,
    this.queryMode = QueryMode.block,
    this.currentQuery = '',
    this.isRunning = false,
    this.lastReport,
    this.sandboxError,
    this.attemptCount = 0,
    this.highestHintUsed = HintTier.none,
    this.levelCompleted = false,
    this.levelScore,
    this.levelStartTime,
    this.showFeedback = false,
    this.schemaExpanded = true,
    this.existingStars = 0,
    this.isDailyChallenge = false,
    this.hintError,
    this.newlyEarnedAchievements = const [],
    this.isDetectiveMode = false,
  });

  bool get isFirstAttempt => attemptCount == 0;

  GameplayState copyWith({
    LevelModel? level,
    QueryMode? queryMode,
    String? currentQuery,
    bool? isRunning,
    QueryValidationReport? lastReport,
    SandboxException? sandboxError,
    int? attemptCount,
    HintTier? highestHintUsed,
    bool? levelCompleted,
    LevelScore? levelScore,
    DateTime? levelStartTime,
    bool? showFeedback,
    bool? schemaExpanded,
    int? existingStars,
    bool? isDailyChallenge,
    String? hintError,
    List<String>? newlyEarnedAchievements,
    bool? isDetectiveMode,
    bool clearSandboxError = false,
    bool clearReport = false,
    bool clearHintError = false,
  }) {
    return GameplayState(
      level: level ?? this.level,
      queryMode: queryMode ?? this.queryMode,
      currentQuery: currentQuery ?? this.currentQuery,
      isRunning: isRunning ?? this.isRunning,
      lastReport: clearReport ? null : (lastReport ?? this.lastReport),
      sandboxError: clearSandboxError ? null : (sandboxError ?? this.sandboxError),
      attemptCount: attemptCount ?? this.attemptCount,
      highestHintUsed: highestHintUsed ?? this.highestHintUsed,
      levelCompleted: levelCompleted ?? this.levelCompleted,
      levelScore: levelScore ?? this.levelScore,
      levelStartTime: levelStartTime ?? this.levelStartTime,
      showFeedback: showFeedback ?? this.showFeedback,
      schemaExpanded: schemaExpanded ?? this.schemaExpanded,
      existingStars: existingStars ?? this.existingStars,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      hintError: clearHintError ? null : (hintError ?? this.hintError),
      newlyEarnedAchievements:
          newlyEarnedAchievements ?? this.newlyEarnedAchievements,
      isDetectiveMode: isDetectiveMode ?? this.isDetectiveMode,
    );
  }
}

// ─── GameplayNotifier ─────────────────────────────────────────────────────────

class GameplayNotifier extends StateNotifier<GameplayState> {
  final Ref _ref;
  final QueryValidator _validator;
  final LevelScorer _scorer;

  GameplayNotifier(this._ref)
      : _validator = QueryValidator.instance,
        _scorer = LevelScorer.instance,
        super(const GameplayState());

  /// Called when entering a level.
  void loadLevel(LevelModel level, {bool isDailyChallenge = false}) {
    // Load existing completion stars asynchronously
    _loadExistingStars(level.id);
    state = GameplayState(
      level: level,
      queryMode: level.type.requiresCodeMode ? QueryMode.code : QueryMode.block,
      currentQuery: level.brokenQuery ?? '',
      levelStartTime: DateTime.now(),
      schemaExpanded: true,
      isDailyChallenge: isDailyChallenge,
    );
  }

  Future<void> _loadExistingStars(String levelId) async {
    try {
      final progressDao = _ref.read(progressDaoProvider);
      final completion = await progressDao.getLevelCompletion(levelId);
      if (completion != null && mounted) {
        state = state.copyWith(existingStars: completion.starsEarned);
      }
    } catch (_) {}
  }

  void updateQuery(String query) {
    state = state.copyWith(currentQuery: query, clearReport: true, clearSandboxError: true);
  }

  void enableDetectiveMode() {
    if (state.level?.detectiveStarterQuery != null) {
      state = state.copyWith(
        isDetectiveMode: true,
        currentQuery: state.level!.detectiveStarterQuery,
        clearReport: true,
        clearSandboxError: true,
        showFeedback: false,
      );
    }
  }

  void toggleQueryMode() {
    if (state.level?.type.isBlockModeOnly ?? false) return; // Tutorial lock
    final newMode = state.queryMode == QueryMode.block ? QueryMode.code : QueryMode.block;
    state = state.copyWith(queryMode: newMode);
  }

  void toggleSchemaPanel() {
    state = state.copyWith(schemaExpanded: !state.schemaExpanded);
  }

  void dismissFeedback() {
    state = state.copyWith(showFeedback: false);
  }

  /// Runs the player's current query through the 4-layer validation pipeline.
  Future<void> runQuery() async {
    final level = state.level;
    if (level == null || state.isRunning) return;

    state = state.copyWith(isRunning: true, clearSandboxError: true);

    try {
      final report = await _validator.validate(
        sql: state.currentQuery,
        schema: level.schema,
        schemaSql: level.schemaSql,
        seedSql: level.seedSql,
        expected: level.expectedResult,
        orderSensitive: level.orderSensitive,
        performanceActive: level.performanceActive,
        efficiencyThreshold: level.efficiencyThreshold,
        isFirstAttempt: state.isFirstAttempt,
        worldId: level.allowedWorldNumber,
      );

      final newAttemptCount = state.attemptCount + 1;

      // Record attempt
      final attemptsDao = _ref.read(attemptsDaoProvider);
      await attemptsDao.recordAttempt(
        levelId: level.id,
        attemptNumber: newAttemptCount,
        submittedQuery: state.currentQuery,
        passedSyntax: report.syntaxPassed,
        passedSemantic: report.semanticPassed,
        passedResult: report.resultPassed,
        efficiencyScore: report.efficiencyScore,
        hintTierUsed: state.highestHintUsed.index,
        durationMs: state.levelStartTime != null
            ? DateTime.now().difference(state.levelStartTime!).inMilliseconds
            : null,
      );

      if (report.isComplete) {
        await _handleLevelComplete(level, report, newAttemptCount);
      }

      state = state.copyWith(
        lastReport: report,
        attemptCount: newAttemptCount,
        isRunning: false,
        showFeedback: true,
      );
    } on SandboxException catch (e) {
      state = state.copyWith(
        isRunning: false,
        sandboxError: e,
        showFeedback: true,
        attemptCount: state.attemptCount + 1,
      );
    } catch (e) {
      state = state.copyWith(isRunning: false);
    }
  }

  Future<void> _handleLevelComplete(
    LevelModel level,
    QueryValidationReport report,
    int attemptCount,
  ) async {
    final durationMs = state.levelStartTime != null
        ? DateTime.now().difference(state.levelStartTime!).inMilliseconds
        : null;

    final score = _scorer.compute(
      resultPassed: true,
      performancePassed: report.performancePassed,
      isFirstAttempt: attemptCount == 1,
      attemptNumber: attemptCount,
      highestHintUsed: _mapHintTier(state.highestHintUsed),
      durationMs: durationMs,
      timingThresholds: level.timingThresholds,
      baseXpReward: level.xpReward,
      performanceActive: level.performanceActive,
      dailyMultiplier: state.isDailyChallenge ? 2.0 : 1.0,
      isDetectiveMode: state.isDetectiveMode,
    );

    // Persist completion
    final progressDao = _ref.read(progressDaoProvider);
    await progressDao.saveLevelCompletion(
      levelId: level.id,
      starsEarned: score.starCount,
      durationMs: durationMs,
    );

    // Award XP and Insight Points
    final playerDao = _ref.read(playerDaoProvider);
    final achievementsDao = _ref.read(achievementsDaoProvider);
    await playerDao.addXp(score.xpEarned, achievementsDao: achievementsDao);
    await playerDao.earnInsightPoints(score.xpEarned ~/ 5);

    // Check world unlock
    await progressDao.checkAndUnlockNextWorld(level.worldId);
    final currentWorldProg = await progressDao.getWorldProgress(level.worldId);

    // Achievement engine — collect newly unlocked IDs
    final newAchievements = <String>[];

    Future<void> maybeAward(String id) async {
      final hadBefore = await achievementsDao.hasAchievement(id);
      await achievementsDao.awardAchievement(id);
      if (!hadBefore) newAchievements.add(id);
    }

    await maybeAward('first_query');

    if (level.performanceActive && (report.efficiencyScore ?? 0.0) >= 1.0) {
      await maybeAward('perfect_optimization');
    }
    if (score.starCount == 3) {
      await maybeAward('three_stars');
    }
    if (state.highestHintUsed == HintTier.none) {
      await maybeAward('no_hints');
    }
    if (score.timeMedal == TimeMedal.gold) {
      await maybeAward('speedrun');
    }
    if (attemptCount >= 5) {
      await maybeAward('comeback');
    }
    if (currentWorldProg != null &&
        currentWorldProg.levelsCompleted >= currentWorldProg.totalLevels) {
      await maybeAward('${level.worldId}_complete');
    }

    state = state.copyWith(
      levelCompleted: true,
      levelScore: score,
      newlyEarnedAchievements: newAchievements,
    );
  }

  /// Attempts to use a hint. Deducts Insight Points (free after 3 failures).
  /// Returns false if the player cannot afford the hint.
  Future<bool> useHint(HintTier tier) async {
    final isGrace = state.attemptCount >= 3 && tier == HintTier.nudge;
    if (!isGrace) {
      final playerDao = _ref.read(playerDaoProvider);
      final success = await playerDao.spendInsightPoints(tier.cost);
      if (!success) {
        state = state.copyWith(
          hintError: 'Not enough Insight Points. You need ${tier.cost} IP.',
        );
        return false;
      }
    }
    // Only upgrade the hint tier if the new tier is higher than the current one.
    final updatedTier = tier.index > state.highestHintUsed.index ? tier : state.highestHintUsed;
    state = state.copyWith(
      highestHintUsed: updatedTier,
      clearHintError: true,
    );
    return true;
  }

  void clearHintError() {
    state = state.copyWith(clearHintError: true);
  }

  HintTier _mapHintTier(HintTier tier) => tier;
}

final gameplayProvider = StateNotifierProvider<GameplayNotifier, GameplayState>(
  (ref) => GameplayNotifier(ref),
);
