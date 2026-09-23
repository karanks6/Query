import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/providers.dart';

class PersistentHudComponent extends PositionComponent with RiverpodComponentMixin {
  late TextComponent _title;
  late TextComponent _playerName;
  late TextComponent _rankTitle;
  
  @override
  Future<void> onLoad() async {
    _title = TextComponent(
      text: 'QUERY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          fontSize: 24,
          letterSpacing: 6,
          shadows: [Shadow(color: Color(0x80FFCC00), offset: Offset(2, 2))],
        ),
      ),
      position: Vector2(16, 16),
    );

    _playerName = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      ),
      anchor: Anchor.topRight,
    );

    _rankTitle = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFCC00),
          fontFamily: 'JetBrainsMono',
          fontSize: 11,
        ),
      ),
      anchor: Anchor.topRight,
    );

    add(_title);
    add(_playerName);
    add(_rankTitle);
  }

  @override
  void onMount() {
    super.onMount();
    addToGameWidgetBuild(() {
      ref.listen(playerProfileProvider, (previous, next) {
        if (next.hasValue && next.value != null) {
          _playerName.text = next.value!.displayName;
          _rankTitle.text = next.value!.rankTitle;
        }
      });
    });
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = Vector2(gameSize.x, 60);
    _playerName.position = Vector2(size.x - 100, 16);
    _rankTitle.position = Vector2(size.x - 100, 34);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF1E212D);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    final borderPaint = Paint()..color = const Color(0x33FFCC00)..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), borderPaint);
  }
}
