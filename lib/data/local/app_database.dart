import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'daos/player_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/attempts_dao.dart';
import 'daos/achievements_dao.dart';
import 'daos/concept_dao.dart';

part 'app_database.g.dart';

// ─── Table definitions (Section 7.1) ────────────────────────────────────────

class PlayerProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get rankTitle => text().named('rank_title').withDefault(const Constant('Junior Analyst'))();
  IntColumn get totalXp => integer().named('total_xp').withDefault(const Constant(0))();
  IntColumn get insightPoints => integer().named('insight_points').withDefault(const Constant(0))();
  IntColumn get streakCount => integer().named('streak_count').withDefault(const Constant(0))();
  IntColumn get streakFreezeAvailable => integer().named('streak_freeze_available').withDefault(const Constant(0))();
  TextColumn get activeTheme => text().named('active_theme').withDefault(const Constant('terminal_classic'))();
  IntColumn get createdAt => integer().named('created_at')();
  TextColumn get cloudSyncId => text().named('cloud_sync_id').nullable()();
}

class WorldProgress extends Table {
  TextColumn get worldId => text().named('world_id')();
  IntColumn get levelsCompleted => integer().named('levels_completed').withDefault(const Constant(0))();
  IntColumn get totalLevels => integer().named('total_levels')();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {worldId};
}

class LevelAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get levelId => text().named('level_id')();
  IntColumn get attemptNumber => integer().named('attempt_number')();
  TextColumn get submittedQuery => text().named('submitted_query')();
  BoolColumn get passedSyntax => boolean().named('passed_syntax')();
  BoolColumn get passedSemantic => boolean().named('passed_semantic')();
  BoolColumn get passedResult => boolean().named('passed_result')();
  RealColumn get efficiencyScore => real().named('efficiency_score').nullable()();
  IntColumn get hintTierUsed => integer().named('hint_tier_used').withDefault(const Constant(0))();
  IntColumn get durationMs => integer().named('duration_ms').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
}

class LevelCompletions extends Table {
  TextColumn get levelId => text().named('level_id')();
  IntColumn get starsEarned => integer().named('stars_earned')();
  IntColumn get timeMedal => integer().named('time_medal').nullable()(); // 0=bronze,1=silver,2=gold
  IntColumn get bestDurationMs => integer().named('best_duration_ms').nullable()();
  IntColumn get completedAt => integer().named('completed_at')();

  @override
  Set<Column> get primaryKey => {levelId};
}

class AchievementsEarned extends Table {
  TextColumn get achievementId => text().named('achievement_id')();
  IntColumn get earnedAt => integer().named('earned_at')();

  @override
  Set<Column> get primaryKey => {achievementId};
}

class ThemeUnlocks extends Table {
  TextColumn get themeId => text().named('theme_id')();
  IntColumn get unlockedAt => integer().named('unlocked_at').nullable()();

  @override
  Set<Column> get primaryKey => {themeId};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class ContentCacheManifest extends Table {
  TextColumn get contentPackId => text().named('content_pack_id')();
  IntColumn get version => integer()();
  TextColumn get checksum => text()();
  IntColumn get downloadedAt => integer().named('downloaded_at')();

  @override
  Set<Column> get primaryKey => {contentPackId};
}

class BookmarkedConcepts extends Table {
  TextColumn get conceptId => text().named('concept_id')();
  IntColumn get savedAt => integer().named('saved_at')();

  @override
  Set<Column> get primaryKey => {conceptId};
}

// ─── Database class ──────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    PlayerProfiles,
    WorldProgress,
    LevelAttempts,
    LevelCompletions,
    AchievementsEarned,
    ThemeUnlocks,
    Settings,
    ContentCacheManifest,
    BookmarkedConcepts,
  ],
  daos: [
    PlayerDao,
    ProgressDao,
    AttemptsDao,
    AchievementsDao,
    ConceptDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed initial data: unlock first world, add default themes
        await into(worldProgress).insert(
          WorldProgressCompanion.insert(
            worldId: 'world_01',
            levelsCompleted: const Value(0),
            totalLevels: 15,
            unlocked: const Value(true),
          ),
        );
        // Seed all 10 worlds as locked (except world_01 seeded above)
        for (int i = 2; i <= 10; i++) {
          final worldId = 'world_${i.toString().padLeft(2, '0')}';
          await into(worldProgress).insert(
            WorldProgressCompanion.insert(
              worldId: worldId,
              levelsCompleted: const Value(0),
              totalLevels: _worldLevelCounts[i] ?? 15,
              unlocked: const Value(false),
            ),
          );
        }
        // Seed terminal_classic as always-unlocked theme
        await into(themeUnlocks).insert(
          ThemeUnlocksCompanion.insert(
            themeId: 'terminal_classic',
            unlockedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(bookmarkedConcepts);
        }
      },
    );
  }

  static const _worldLevelCounts = {
    1: 15, 2: 16, 3: 18, 4: 22, 5: 20,
    6: 16, 7: 15, 8: 20, 9: 15, 10: 15,
  };

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'query_app_db.sqlite'));
      return NativeDatabase(file);
    });
  }
}
