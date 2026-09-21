import 'package:flame/components.dart';
import '../../data/content/models/level_model.dart';
import 'query_scene.dart';

import 'package:flame_riverpod/flame_riverpod.dart';
import '../../features/gameplay/gameplay_provider.dart';
import '../components/gameplay/block_workspace_component.dart';

class GameplayScene extends QueryScene with RiverpodComponentMixin {
  final LevelModel level;
  late BlockWorkspaceComponent blockWorkspace;

  GameplayScene({required this.level});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    blockWorkspace = BlockWorkspaceComponent();
    add(blockWorkspace);
  }

  @override
  void onMount() {
    super.onMount();
    listen(gameplayProvider, (previous, next) {
      if (next != null) {
        if (next.queryMode == QueryMode.block) {
          blockWorkspace.priority = 10;
        } else {
          blockWorkspace.priority = -10;
        }
      }
    });
  }
}
