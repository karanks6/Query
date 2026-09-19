import 'package:flame/components.dart';
import 'query_scene.dart';
import '../components/persistent_hud.dart';

class DashboardScene extends QueryScene {
  late PersistentHudComponent hud;

  @override
  Future<void> onLoad() async {
    hud = PersistentHudComponent();
    add(hud);
  }

  @override
  Future<void> onEnter() async {
    // Increase parallax speed slightly or change direction
  }
}
