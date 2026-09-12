import 'package:drift/drift.dart';
import '../app_database.dart';

part 'attempts_dao.g.dart';

@DriftAccessor(tables: [LevelAttempts])
class AttemptsDao extends DatabaseAccessor<AppDatabase> with _$AttemptsDaoMixin {
  AttemptsDao(super.db);

  /// Records a query attempt (every attempt, not just the best).
  Future<int> recordAttempt({
    required String levelId,
    required int attemptNumber,
    required String submittedQuery,
    required bool passedSyntax,
    required bool passedSemantic,
    required bool passedResult,
    double? efficiencyScore,
    int hintTierUsed = 0,
    int? durationMs,
  }) {
    return into(levelAttempts).insert(
      LevelAttemptsCompanion.insert(
        levelId: levelId,
        attemptNumber: attemptNumber,
        submittedQuery: submittedQuery,
        passedSyntax: passedSyntax,
        passedSemantic: passedSemantic,
        passedResult: passedResult,
        efficiencyScore: Value(efficiencyScore),
        hintTierUsed: Value(hintTierUsed),
        durationMs: Value(durationMs),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Gets all attempts for a level (for concept mastery analysis).
  Future<List<LevelAttempt>> getAttemptsForLevel(String levelId) {
    return (select(levelAttempts)
          ..where((a) => a.levelId.equals(levelId))
          ..orderBy([(a) => OrderingTerm.asc(a.attemptNumber)]))
        .get();
  }

  /// Gets the most recent N attempts for a level.
  Future<List<LevelAttempt>> getRecentAttemptsForLevel(String levelId, {int limit = 5}) {
    return (select(levelAttempts)
          ..where((a) => a.levelId.equals(levelId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Gets the current attempt number for a level (for first-attempt star).
  Future<int> getAttemptCount(String levelId) async {
    final count = await (select(levelAttempts)
          ..where((a) => a.levelId.equals(levelId)))
        .get();
    return count.length;
  }

  /// Returns all attempts for a world — raw material for concept mastery tracker.
  Future<List<LevelAttempt>> getAttemptsForWorld(String worldId) {
    final prefix = '${worldId}_';
    return (select(levelAttempts)
          ..where((a) => a.levelId.like('$prefix%')))
        .get();
  }
}
