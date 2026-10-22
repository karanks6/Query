import 'package:flutter_test/flutter_test.dart';
import 'package:query/features/daily_challenge/daily_challenge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyChallengeService QA Tests', () {
    test('Loads challenge for today with valid level definition', () async {
      final challenge = await DailyChallengeService.instance.getTodayChallenge();

      expect(challenge, isNotNull);
      expect(challenge!.id, startsWith('daily_'));
      expect(challenge.worldId, equals('daily'));
      expect(challenge.title, isNotEmpty);
      expect(challenge.narrative, isNotEmpty);
      expect(challenge.schema.tables, isNotEmpty);
      expect(challenge.schemaSql, isNotEmpty);
      expect(challenge.seedSql, isNotEmpty);
      expect(challenge.expectedResult, isNotEmpty);
    });

    test('Today challenge remains stable when invoked multiple times on the same date', () async {
      final challenge1 = await DailyChallengeService.instance.getTodayChallenge();
      final challenge2 = await DailyChallengeService.instance.getTodayChallenge();

      expect(challenge1?.id, equals(challenge2?.id));
      expect(challenge1?.title, equals(challenge2?.title));
    });
  });
}
