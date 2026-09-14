import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../data/content/level_loader.dart';
import 'sync/sync_service.dart';
import 'sync/firebase_sync_service.dart';

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

final conceptDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).conceptDao;
});

final themesDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).themesDao;
});

// ─── Service providers ────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = FirebaseSyncService(
    progressDao: ref.watch(progressDaoProvider),
    playerDao: ref.watch(playerDaoProvider),
  );
  service.initialize();
  return service;
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

// ─── Achievements stream ──────────────────────────────────────────────────────

final allAchievementsProvider = StreamProvider((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.achievementsEarned).watch();
});

// ─── Bookmarked Concepts stream ───────────────────────────────────────────────

final bookmarkedConceptsProvider = StreamProvider<List<String>>((ref) {
  final dao = ref.watch(conceptDaoProvider);
  return dao.watchBookmarkedConceptIds();
});

// ─── Mastery Provider ─────────────────────────────────────────────────────────

final masteryProgressProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final allProgress = await ref.watch(allWorldProgressProvider.future);
  final loader = ref.read(levelLoaderProvider);
  
  final List<Map<String, dynamic>> masteries = [];
  
  for (final progress in allProgress) {
    if (progress.totalLevels == 0) continue;
    try {
      final world = await loader.loadWorld(progress.worldId);
      final concept = world.coreSqlConcept;
      if (concept.isNotEmpty) {
        masteries.add({
          'concept': concept,
          'progress': progress.levelsCompleted / progress.totalLevels,
        });
      }
    } catch (e) {
      // Ignore worlds that fail to load
    }
  }
  return masteries;
});
