import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:query/data/local/app_database.dart';
import 'package:query/data/local/daos/player_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PlayerDao playerDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    playerDao = PlayerDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  final now = DateTime.now();
  final todayStr = DateTime(now.year, now.month, now.day).toIso8601String().substring(0, 10);
  final yesterdayStr = DateTime(now.year, now.month, now.day - 1).toIso8601String().substring(0, 10);
  final twoDaysAgoStr = DateTime(now.year, now.month, now.day - 2).toIso8601String().substring(0, 10);

  test('Broken streak resets to 0 when checking on dashboard without increment', () async {
    SharedPreferences.setMockInitialValues({
      'last_streak_update': twoDaysAgoStr,
      'longest_streak': 5,
      'streak_history': [twoDaysAgoStr],
    });
    final prefs = await SharedPreferences.getInstance();

    await playerDao.getProfile();
    // Simulate player having an old streak of 5 before skipping yesterday
    await (db.update(db.playerProfiles)).write(
      const PlayerProfilesCompanion(streakCount: Value(5)),
    );

    // Visiting dashboard checks streak with increment: false
    await playerDao.checkDailyStreak(prefs, increment: false);

    final profile = await playerDao.getProfile();
    expect(profile!.streakCount, 0, reason: 'Streak count must be 0 when broken');
    expect(prefs.getString('last_streak_update'), twoDaysAgoStr, reason: 'Dashboard check must not mark today as played');
    expect(prefs.getInt('longest_streak'), 5, reason: 'Longest streak must not be lost');
  });

  test('Broken streak starts at 1 upon completing a level (increment: true)', () async {
    SharedPreferences.setMockInitialValues({
      'last_streak_update': twoDaysAgoStr,
      'longest_streak': 5,
    });
    final prefs = await SharedPreferences.getInstance();

    await playerDao.getProfile();
    await (db.update(db.playerProfiles)).write(
      const PlayerProfilesCompanion(streakCount: Value(0)),
    );

    // Completing level with broken streak
    await playerDao.checkDailyStreak(prefs, increment: true);

    final profile = await playerDao.getProfile();
    expect(profile!.streakCount, 1, reason: 'Streak count must reset to 1');
    expect(prefs.getString('last_streak_update'), todayStr);
    expect(prefs.getStringList('streak_history'), contains(todayStr));
    expect(prefs.getInt('longest_streak'), 5);
  });

  test('Active streak from yesterday is preserved when opening dashboard (increment: false)', () async {
    SharedPreferences.setMockInitialValues({
      'last_streak_update': yesterdayStr,
      'longest_streak': 3,
    });
    final prefs = await SharedPreferences.getInstance();

    await playerDao.getProfile();
    await (db.update(db.playerProfiles)).write(
      const PlayerProfilesCompanion(streakCount: Value(3)),
    );

    // Opening dashboard today before playing
    await playerDao.checkDailyStreak(prefs, increment: false);

    final profile = await playerDao.getProfile();
    expect(profile!.streakCount, 3, reason: 'Active streak from yesterday must not be reset to 0');
    expect(prefs.getString('last_streak_update'), yesterdayStr);
  });

  test('Active streak from yesterday increments by 1 when completing a level (increment: true)', () async {
    SharedPreferences.setMockInitialValues({
      'last_streak_update': yesterdayStr,
      'longest_streak': 3,
    });
    final prefs = await SharedPreferences.getInstance();

    await playerDao.getProfile();
    await (db.update(db.playerProfiles)).write(
      const PlayerProfilesCompanion(streakCount: Value(3)),
    );

    // Completing a level today
    await playerDao.checkDailyStreak(prefs, increment: true);

    final profile = await playerDao.getProfile();
    expect(profile!.streakCount, 4, reason: 'Active streak should increment by 1');
    expect(prefs.getString('last_streak_update'), todayStr);
    expect(prefs.getInt('longest_streak'), 4, reason: 'Longest streak should update when exceeded');
  });

  test('Completing multiple levels today does not double-increment streak', () async {
    SharedPreferences.setMockInitialValues({
      'last_streak_update': todayStr,
      'longest_streak': 4,
    });
    final prefs = await SharedPreferences.getInstance();

    await playerDao.getProfile();
    await (db.update(db.playerProfiles)).write(
      const PlayerProfilesCompanion(streakCount: Value(4)),
    );

    // Completing another level today
    await playerDao.checkDailyStreak(prefs, increment: true);

    final profile = await playerDao.getProfile();
    expect(profile!.streakCount, 4, reason: 'Streak should not increment more than once per day');
    expect(prefs.getString('last_streak_update'), todayStr);
  });

  test('Fresh player with no streak history shows 0 on dashboard and starts at 1 on level completion', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await playerDao.getProfile();

    // Check on dashboard
    await playerDao.checkDailyStreak(prefs, increment: false);
    var profile = await playerDao.getProfile();
    expect(profile!.streakCount, 0);

    // First level completion
    await playerDao.checkDailyStreak(prefs, increment: true);
    profile = await playerDao.getProfile();
    expect(profile!.streakCount, 1);
    expect(prefs.getString('last_streak_update'), todayStr);
    expect(prefs.getInt('longest_streak'), 1);
  });
}
