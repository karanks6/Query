import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../../../features/gameplay/gameplay_provider.dart';

class TabBarComponent extends PositionComponent with TapCallbacks {
  final GameplayState state;
  final VoidCallback onToggle;
  // Settable after mount when Riverpod is available
  VoidCallback? onToggleCallback;
  
  late final RectangleComponent _bg;
  late final RectangleComponent _indicator;
  late final TextComponent _blockText;
  late final TextComponent _codeText;

  TabBarComponent({
    required this.state,
    required this.onToggle,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _bg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF15171E)
        ..style = PaintingStyle.fill,
    );
    add(_bg);
    
    _bg.add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    ));

    _indicator = RectangleComponent(
      size: Vector2(size.x / 2, size.y),
      position: Vector2(state.queryMode == QueryMode.block ? 0 : size.x / 2, 0),
      paint: Paint()..color = const Color(0xFF00FF9D).withValues(alpha: 0.2),
    );
    add(_indicator);

    _blockText = TextComponent(
      text: 'BLOCK',
      textRenderer: TextPaint(
        style: TextStyle(
          color: state.queryMode == QueryMode.block ? const Color(0xFF00FF9D) : Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x / 4, size.y / 2),
      anchor: Anchor.center,
    );
    add(_blockText);

    _codeText = TextComponent(
      text: 'CODE',
      textRenderer: TextPaint(
        style: TextStyle(
          color: state.queryMode == QueryMode.code ? const Color(0xFF00FF9D) : Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x * 3 / 4, size.y / 2),
      anchor: Anchor.center,
    );
    add(_codeText);
  }

  @override
  void onTapUp(TapUpEvent event) {
    (onToggleCallback ?? onToggle)();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Smooth animate indicator
    final targetX = state.queryMode == QueryMode.block ? 0.0 : size.x / 2;
    _indicator.position.x += (targetX - _indicator.position.x) * 10 * dt;
    
    _blockText.textRenderer = TextPaint(
      style: TextStyle(
        color: state.queryMode == QueryMode.block ? const Color(0xFF00FF9D) : Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
    _codeText.textRenderer = TextPaint(
      style: TextStyle(
        color: state.queryMode == QueryMode.code ? const Color(0xFF00FF9D) : Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}
