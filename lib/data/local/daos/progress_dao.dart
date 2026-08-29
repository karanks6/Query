import 'package:drift/drift.dart';
import '../app_database.dart';

part 'progress_dao.g.dart';

@DriftAccessor(tables: [WorldProgress, LevelCompletions])
class ProgressDao extends DatabaseAccessor<AppDatabase> with _$ProgressDaoMixin {
  ProgressDao(super.db);

  /// Returns progress for all worlds, ordered by world_id.
  Future<List<WorldProgressData>> getAllWorldProgress() {
    return (select(worldProgress)..orderBy([(w) => OrderingTerm.asc(w.worldId)]))
        .get();
  }

  /// Returns progress for a specific world.
  Future<WorldProgressData?> getWorldProgress(String worldId) {
    return (select(worldProgress)..where((w) => w.worldId.equals(worldId)))
        .getSingleOrNull();
  }

  /// Returns completion record for a specific level (null if not completed).
  Future<LevelCompletion?> getLevelCompletion(String levelId) {
    return (select(levelCompletions)..where((l) => l.levelId.equals(levelId)))
        .getSingleOrNull();
  }

  /// Returns all completed level IDs for a world.
  Future<List<String>> getCompletedLevelIds(String worldId) async {
    final prefix = '${worldId}_';
    final results = await (select(levelCompletions)
          ..where((l) => l.levelId.like('$prefix%')))
        .get();
    return results.map((r) => r.levelId).toList();
  }

  /// Saves or upgrades a level completion record (never downgrade stars).
  Future<void> saveLevelCompletion({
    required String levelId,
    required int starsEarned,
    int? timeMedal,
    int? durationMs,
  }) async {
    final existing = await getLevelCompletion(levelId);

    if (existing == null) {
      await into(levelCompletions).insert(
        LevelCompletionsCompanion.insert(
          levelId: levelId,
          starsEarned: starsEarned,
          timeMedal: Value(timeMedal),
          bestDurationMs: Value(durationMs),
          completedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await _incrementWorldProgress(levelId);
    } else {
      // Only upgrade — never downgrade star count or medals
      final newStars = starsEarned > existing.starsEarned ? starsEarned : existing.starsEarned;
      final newMedal = _upgradeMedal(existing.timeMedal, timeMedal);
      final newDuration = _bestDuration(existing.bestDurationMs, durationMs);

      await (update(levelCompletions)..where((l) => l.levelId.equals(levelId)))
          .write(LevelCompletionsCompanion(
        starsEarned: Value(newStars),
        timeMedal: Value(newMedal),
        bestDurationMs: Value(newDuration),
      ));
    }
  }

  /// Unlocks the next world if the current world's level count is met.
  Future<void> checkAndUnlockNextWorld(String currentWorldId) async {
    final current = await getWorldProgress(currentWorldId);
    if (current == null) return;

    if (current.levelsCompleted >= current.totalLevels) {
      // Derive next world ID (world_01 → world_02)
      final currentNum = int.tryParse(currentWorldId.replaceAll('world_', '')) ?? 0;
      final nextId = 'world_${(currentNum + 1).toString().padLeft(2, '0')}';

      await (update(worldProgress)..where((w) => w.worldId.equals(nextId)))
          .write(const WorldProgressCompanion(unlocked: Value(true)));
    }
  }

  Future<void> _incrementWorldProgress(String levelId) async {
    // Extract world ID from level ID pattern: "world_01_level_03" → "world_01"
    final parts = levelId.split('_');
    if (parts.length < 2) return;
    final worldId = '${parts[0]}_${parts[1]}';

    await customUpdate(
      'UPDATE world_progress SET levels_completed = levels_completed + 1 WHERE world_id = ?',
      variables: [Variable.withString(worldId)],
      updates: {worldProgress},
    );
  }

  int? _upgradeMedal(int? current, int? incoming) {
    if (current == null) return incoming;
    if (incoming == null) return current;
    return incoming > current ? incoming : current;
  }

  int? _bestDuration(int? current, int? incoming) {
    if (current == null) return incoming;
    if (incoming == null) return current;
    return incoming < current ? incoming : current;
  }
}
