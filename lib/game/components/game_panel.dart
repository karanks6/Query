import 'dart:ui';
import 'package:flame/components.dart';

class GamePanelComponent extends PositionComponent {
  final Paint _paint;
  final Paint _borderPaint;
  final double slantWidth;

  GamePanelComponent({
    Color backgroundColor = const Color(0xFF1E212D),
    Color borderColor = const Color(0x33FFCC00),
    this.slantWidth = 16.0,
    super.position,
    super.size,
  })  : _paint = Paint()..color = backgroundColor..style = PaintingStyle.fill,
        _borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.x - slantWidth, 0)
      ..lineTo(size.x, slantWidth)
      ..lineTo(size.x, size.y)
      ..lineTo(slantWidth, size.y)
      ..lineTo(0, size.y - slantWidth)
      ..close();

    canvas.drawPath(path, _paint);
    canvas.drawPath(path, _borderPaint);
  }
}
