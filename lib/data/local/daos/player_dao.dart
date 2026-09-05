import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_database.dart';
import '../../remote/leaderboard_service.dart';

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
    
    // Sync to global leaderboard (fire-and-forget)
    try {
      final lbService = LeaderboardService();
      lbService.syncPlayerXp(
        displayName: profile.displayName,
        totalXp: newXp,
        rankTitle: newRank,
      );
    } catch (_) {}
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

  /// Checks and updates the daily streak using SharedPreferences.
  Future<void> checkDailyStreak(SharedPreferences prefs) async {
    final profile = await getProfile();
    if (profile == null) return;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().substring(0, 10);

    final lastUpdate = prefs.getString('last_streak_update');

    if (lastUpdate == null) {
      // First time playing / starting new streak
      final newStreak = profile.streakCount + 1;
      await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
          .write(PlayerProfilesCompanion(streakCount: Value(newStreak)));
      await prefs.setString('last_streak_update', todayStr);
    } else if (lastUpdate == yesterdayStr) {
      // Kept streak alive
      final newStreak = profile.streakCount + 1;
      await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
          .write(PlayerProfilesCompanion(streakCount: Value(newStreak)));
      await prefs.setString('last_streak_update', todayStr);
    } else if (lastUpdate != todayStr) {
      // Streak broken (played before yesterday)
      // Reset streak and increment to 1 for today
      await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
          .write(const PlayerProfilesCompanion(streakCount: Value(1)));
      await prefs.setString('last_streak_update', todayStr);
    }
  }

  String _rankForXp(int xp) {
    if (xp >= 50000) return 'The Oracle';
    if (xp >= 20000) return 'Master Architect';
    if (xp >= 10000) return 'Bureau Chief';
    if (xp >= 7500) return 'Cyber Operative';
    if (xp >= 5000) return 'Senior Investigator';
    if (xp >= 2500) return 'Query Specialist';
    if (xp >= 1000) return 'Field Detective';
    if (xp >= 500) return 'Data Sleuth';
    return 'Junior Analyst';
  }
}
