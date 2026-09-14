import 'package:drift/drift.dart';
import '../app_database.dart';

part 'themes_dao.g.dart';

@DriftAccessor(tables: [ThemeUnlocks])
class ThemesDao extends DatabaseAccessor<AppDatabase> with _$ThemesDaoMixin {
  ThemesDao(super.db);

  Future<List<ThemeUnlock>> getUnlockedThemes() {
    return select(themeUnlocks).get();
  }

  Future<void> unlockTheme(String themeId) {
    return into(themeUnlocks).insert(
      ThemeUnlocksCompanion.insert(
        themeId: themeId,
        unlockedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}
