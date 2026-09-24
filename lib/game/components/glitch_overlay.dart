import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

class GlitchOverlayComponent extends PositionComponent {
  bool _isActive = false;
  double _timer = 0;
  final Random _random = Random();
  
  final Paint _redPaint = Paint()..color = const Color(0x88FF0000)..blendMode = BlendMode.screen;
  final Paint _bluePaint = Paint()..color = const Color(0x880000FF)..blendMode = BlendMode.screen;

  void trigger([double duration = 0.3]) {
    _isActive = true;
    _timer = duration;
  }

  @override
  void update(double dt) {
    if (_isActive) {
      _timer -= dt;
      if (_timer <= 0) {
        _isActive = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isActive || size.x == 0 || size.y == 0) return;

    // A very simple procedural glitch effect
    // We draw random semi-transparent horizontal rectangles in red and blue
    int sliceCount = _random.nextInt(5) + 3;
    
    for (int i = 0; i < sliceCount; i++) {
      double y = _random.nextDouble() * size.y;
      double h = _random.nextDouble() * 20 + 2;
      double xOffset = (_random.nextDouble() - 0.5) * 40; // Shift left/right

      canvas.drawRect(
        Rect.fromLTWH(xOffset, y, size.x, h),
        _random.nextBool() ? _redPaint : _bluePaint,
      );
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    size = size; // Cover full screen
  }
}
