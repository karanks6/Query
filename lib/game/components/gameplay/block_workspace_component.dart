import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'draggable_block_component.dart';

class BlockWorkspaceComponent extends PositionComponent {
  final List<DraggableBlockComponent> activeBlocks = [];
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Draw the palette area at the bottom
    final paletteBg = RectangleComponent(
      size: Vector2(size.x, 100),
      position: Vector2(0, size.y - 100),
      paint: Paint()..color = const Color(0xFF15171E),
    );
    add(paletteBg);
    
    // Add some initial blocks to the palette
    final selectBlock = DraggableBlockComponent(
      type: ClauseType.select,
      onTapBlock: (block) {
        // trigger flutter overlay
      },
      size: Vector2(120, 40),
      position: Vector2(20, size.y - 80),
    );
    add(selectBlock);
    activeBlocks.add(selectBlock);
    
    final fromBlock = DraggableBlockComponent(
      type: ClauseType.from,
      onTapBlock: (block) {},
      size: Vector2(120, 40),
      position: Vector2(160, size.y - 80),
    );
    add(fromBlock);
    activeBlocks.add(fromBlock);
    
    // Add slot targets in the main build area
    for (int i = 0; i < 4; i++) {
      final slot = RectangleComponent(
        size: Vector2(140, 50),
        position: Vector2(20, 100 + (i * 60)),
        paint: Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF333333),
      );
      add(slot);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
    // update positions
  }
}
