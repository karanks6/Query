import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../data/content/level_loader.dart';

// ─── Database provider ────────────────────────────────────────────────────────

/// Singleton app database. Override in tests to use an in-memory instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─── DAO providers ────────────────────────────────────────────────────────────

final playerDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).playerDao;
});

final progressDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).progressDao;
});

final attemptsDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).attemptsDao;
});

final achievementsDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).achievementsDao;
});

// ─── Content providers ────────────────────────────────────────────────────────

final levelLoaderProvider = Provider<LevelLoader>((ref) {
  return LevelLoader.instance;
});

// ─── Player profile stream ────────────────────────────────────────────────────

final playerProfileProvider = StreamProvider((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.playerProfiles)..limit(1)).watchSingleOrNull();
});

// ─── World progress stream ────────────────────────────────────────────────────

final allWorldProgressProvider = StreamProvider((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.worldProgress)
        ..orderBy([(w) => OrderingTerm.asc(w.worldId)]))
      .watch();
});

final worldProgressProvider =
    StreamProvider.family<WorldProgressData?, String>((ref, worldId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.worldProgress)
        ..where((w) => w.worldId.equals(worldId)))
      .watchSingleOrNull();
});
