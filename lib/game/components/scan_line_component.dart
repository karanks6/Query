import 'dart:ui';
import 'package:flame/components.dart';

class ScanLineComponent extends PositionComponent {
  final Paint _paint = Paint()
    ..color = const Color(0x1A000000) // 10% black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  double _offset = 0;

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;
    
    for (double y = _offset; y < size.y; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
    }
  }

  @override
  void update(double dt) {
    _offset += 15 * dt;
    if (_offset >= 4.0) {
      _offset -= 4.0;
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize; 
  }
}
