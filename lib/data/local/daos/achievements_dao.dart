import 'package:drift/drift.dart';
import '../app_database.dart';

part 'achievements_dao.g.dart';

@DriftAccessor(tables: [AchievementsEarned, ThemeUnlocks])
class AchievementsDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementsDaoMixin {
  AchievementsDao(super.db);

  Future<List<AchievementsEarnedData>> getAllAchievements() {
    return select(achievementsEarned).get();
  }

  Future<bool> hasAchievement(String achievementId) async {
    final result = await (select(achievementsEarned)
          ..where((a) => a.achievementId.equals(achievementId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<void> awardAchievement(String achievementId) async {
    if (await hasAchievement(achievementId)) return;
    await into(achievementsEarned).insert(
      AchievementsEarnedCompanion.insert(
        achievementId: achievementId,
        earnedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<ThemeUnlock>> getUnlockedThemes() {
    return (select(themeUnlocks)..where((t) => t.unlockedAt.isNotNull())).get();
  }

  Future<bool> isThemeUnlocked(String themeId) async {
    final result = await (select(themeUnlocks)
          ..where((t) => t.themeId.equals(themeId)))
        .getSingleOrNull();
    return result?.unlockedAt != null;
  }

  Future<void> unlockTheme(String themeId) async {
    await into(themeUnlocks).insertOnConflictUpdate(
      ThemeUnlocksCompanion.insert(
        themeId: themeId,
        unlockedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
