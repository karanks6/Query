import 'package:drift/drift.dart';
import '../app_database.dart';

part 'player_dao.g.dart';

@DriftAccessor(tables: [PlayerProfiles])
class PlayerDao extends DatabaseAccessor<AppDatabase> with _$PlayerDaoMixin {
  PlayerDao(super.db);

  /// Gets the single player profile (creates a default if none exists).
  Future<PlayerProfile?> getProfile() {
    return (select(playerProfiles)..limit(1)).getSingleOrNull();
  }

  /// Creates the initial profile after onboarding name entry.
  Future<int> createProfile(String displayName) {
    return into(playerProfiles).insert(
      PlayerProfilesCompanion.insert(
        displayName: displayName,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Awards XP and updates rank title if threshold crossed.
  Future<void> addXp(int amount) async {
    final profile = await getProfile();
    if (profile == null) return;

    final newXp = profile.totalXp + amount;
    final newRank = _rankForXp(newXp);

    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(PlayerProfilesCompanion(
      totalXp: Value(newXp),
      rankTitle: Value(newRank),
    ));
  }

  /// Spends Insight Points for hints.
  Future<bool> spendInsightPoints(int amount) async {
    final profile = await getProfile();
    if (profile == null || profile.insightPoints < amount) return false;

    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(PlayerProfilesCompanion(
      insightPoints: Value(profile.insightPoints - amount),
    ));
    return true;
  }

  /// Earns Insight Points from normal play.
  Future<void> earnInsightPoints(int amount) async {
    final profile = await getProfile();
    if (profile == null) return;
    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(PlayerProfilesCompanion(
      insightPoints: Value(profile.insightPoints + amount),
    ));
  }

  /// Updates the active visual theme.
  Future<void> setActiveTheme(String themeId) async {
    final profile = await getProfile();
    if (profile == null) return;
    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(PlayerProfilesCompanion(activeTheme: Value(themeId)));
  }

  /// Increments streak. Returns new count.
  Future<int> incrementStreak() async {
    final profile = await getProfile();
    if (profile == null) return 0;
    final newStreak = profile.streakCount + 1;
    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(PlayerProfilesCompanion(streakCount: Value(newStreak)));
    return newStreak;
  }

  /// Resets streak (broken).
  Future<void> resetStreak() async {
    final profile = await getProfile();
    if (profile == null) return;
    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(const PlayerProfilesCompanion(streakCount: Value(0)));
  }

  String _rankForXp(int xp) {
    if (xp >= 10000) return 'Bureau Chief';
    if (xp >= 5000) return 'Senior Investigator';
    if (xp >= 2000) return 'Field Detective';
    return 'Junior Analyst';
  }
}
