import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import '../../../../features/gameplay/gameplay_provider.dart';

class TabBarComponent extends PositionComponent with TapCallbacks {
  GameplayState state;
  final VoidCallback onToggle;
  // Settable after mount when Riverpod is available
  VoidCallback? onToggleCallback;
  void Function(QueryMode mode)? onModeSelected;

  late final RectangleComponent _bg;
  late final RectangleComponent _indicator;
  late final TextComponent _blockText;
  late final TextComponent _codeText;
  QueryMode? _lastRenderedMode;

  TabBarComponent({
    required this.state,
    required this.onToggle,
    this.onModeSelected,
    super.position,
    super.size,
  });

  @override
  bool containsLocalPoint(Vector2 point) {
    // Generous touch target (+8px padding in all directions)
    return point.x >= -8 &&
        point.x <= size.x + 8 &&
        point.y >= -8 &&
        point.y <= size.y + 8;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Parchment background
    _bg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFFEFE6D5)
        ..style = PaintingStyle.fill,
    );
    add(_bg);

    // Inner border
    _bg.add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFFD4C4A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));

    // Wooden indicator
    _indicator = RectangleComponent(
      size: Vector2(size.x / 2, size.y),
      position: Vector2(state.queryMode == QueryMode.block ? 0 : size.x / 2, 0),
      paint: Paint()..color = const Color(0xFFD48B3E).withValues(alpha: 0.35),
    );
    add(_indicator);

    _blockText = TextComponent(
      text: 'BLOCKS',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: state.queryMode == QueryMode.block
              ? const Color(0xFF3D2817)
              : const Color(0xFF9E8B75),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x / 4, size.y / 2),
      anchor: Anchor.center,
    );
    add(_blockText);

    _codeText = TextComponent(
      text: 'SCROLL',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: state.queryMode == QueryMode.code
              ? const Color(0xFF3D2817)
              : const Color(0xFF9E8B75),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x * 3 / 4, size.y / 2),
      anchor: Anchor.center,
    );
    add(_codeText);
    _lastRenderedMode = state.queryMode;
  }

  @override
  void onTapUp(TapUpEvent event) {
    final mode = event.localPosition.x < (size.x / 2.0)
        ? QueryMode.block
        : QueryMode.code;
    if (onModeSelected != null) {
      onModeSelected!(mode);
    } else if (onToggleCallback != null) {
      onToggleCallback!();
    } else {
      onToggle();
    }
  }

  void _updateTextStyles() {
    _blockText.textRenderer = TextPaint(
      style: GoogleFonts.nunitoSans(
        color: state.queryMode == QueryMode.block
            ? const Color(0xFF3D2817)
            : const Color(0xFF9E8B75),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
    _codeText.textRenderer = TextPaint(
      style: GoogleFonts.nunitoSans(
        color: state.queryMode == QueryMode.code
            ? const Color(0xFF3D2817)
            : const Color(0xFF9E8B75),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Smooth animate indicator
    final targetX = state.queryMode == QueryMode.block ? 0.0 : size.x / 2;
    _indicator.position.x += (targetX - _indicator.position.x) * 15 * dt;

    if (_lastRenderedMode != state.queryMode) {
      _lastRenderedMode = state.queryMode;
      _updateTextStyles();
    }
  }
}

