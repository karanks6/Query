import 'package:flutter_test/flutter_test.dart';
import 'package:query/game/scenes/daily_challenge_scene.dart';

void main() {
  test('DailyChallengeScene can be instantiated and has correct overlay state', () {
    final scene = DailyChallengeScene();
    expect(scene, isNotNull);
    expect(scene.activeOverlays, isEmpty);
  });
}
