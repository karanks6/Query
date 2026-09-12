import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_database.dart';
import '../../remote/leaderboard_service.dart';
import '../../content/models/rank_system.dart';
import 'achievements_dao.dart';

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
  Future<void> addXp(int amount, {AchievementsDao? achievementsDao}) async {
    final profile = await getProfile();
    if (profile == null) return;

    final newXp = profile.totalXp + amount;
    final newRank = _rankForXp(newXp);

    await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
        .write(PlayerProfilesCompanion(
      totalXp: Value(newXp),
      rankTitle: Value(newRank),
    ));

    if (achievementsDao != null && newXp >= 500) {
      await achievementsDao.awardAchievement('rank_silver');
    }
    
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
  Future<void> checkDailyStreak(SharedPreferences prefs, {AchievementsDao? achievementsDao}) async {
    final profile = await getProfile();
    if (profile == null) return;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().substring(0, 10);

    final lastUpdate = prefs.getString('last_streak_update');
    List<String> history = prefs.getStringList('streak_history') ?? [];
    int longestStreak = prefs.getInt('longest_streak') ?? 0;

    Future<void> updateHistoryAndLongest(int currentStreak) async {
      if (!history.contains(todayStr)) {
        history.add(todayStr);
        await prefs.setStringList('streak_history', history);
      }
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        await prefs.setInt('longest_streak', longestStreak);
      }
      
      if (achievementsDao != null) {
        if (currentStreak >= 3) await achievementsDao.awardAchievement('daily_streak_3');
        if (currentStreak >= 7) await achievementsDao.awardAchievement('daily_streak_7');
      }
    }

    if (lastUpdate == null) {
      // First time playing / starting new streak
      final newStreak = profile.streakCount + 1;
      await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
          .write(PlayerProfilesCompanion(streakCount: Value(newStreak)));
      await prefs.setString('last_streak_update', todayStr);
      await updateHistoryAndLongest(newStreak);
    } else if (lastUpdate == yesterdayStr) {
      // Kept streak alive
      final newStreak = profile.streakCount + 1;
      await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
          .write(PlayerProfilesCompanion(streakCount: Value(newStreak)));
      await prefs.setString('last_streak_update', todayStr);
      await updateHistoryAndLongest(newStreak);
    } else if (lastUpdate != todayStr) {
      // Streak broken (played before yesterday)
      // Reset streak and increment to 1 for today
      await (update(playerProfiles)..where((p) => p.id.equals(profile.id)))
          .write(const PlayerProfilesCompanion(streakCount: Value(1)));
      await prefs.setString('last_streak_update', todayStr);
      await updateHistoryAndLongest(1);
    } else {
      // Played multiple times today. Just ensure history has today.
      await updateHistoryAndLongest(profile.streakCount);
    }
  }

  String _rankForXp(int xp) {
    return RankSystem.getRankForXp(xp).title;
  }
}
