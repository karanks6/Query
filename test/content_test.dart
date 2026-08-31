import 'package:flutter_test/flutter_test.dart';
import 'package:query/data/content/level_loader.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Load all worlds', () async {
    await LevelLoader.instance.preloadBundledWorlds();
    final world3 = await LevelLoader.instance.loadWorld('world_03');
    expect(world3.id, 'world_03');
    print('Loaded world 3 successfully!');
    
    for (int i = 1; i <= 6; i++) {
       final w = await LevelLoader.instance.loadWorld('world_0$i');
       print('World $i: ${w.levels.length} levels loaded.');
    }
  });
}
