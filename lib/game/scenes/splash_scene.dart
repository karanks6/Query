import 'package:flame/components.dart';
import 'query_scene.dart';
import '../components/glitch_overlay.dart';

class SplashScene extends QueryScene {
  late GlitchOverlayComponent glitchOverlay;

  @override
  Future<void> onLoad() async {
    glitchOverlay = GlitchOverlayComponent();
    add(glitchOverlay);
  }

  @override
  Future<void> onEnter() async {
    glitchOverlay.trigger(0.4);
  }
}
