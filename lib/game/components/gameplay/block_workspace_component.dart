import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'draggable_block_component.dart';
import '../../query_game.dart';

class BlockSlotComponent extends RectangleComponent {
  DraggableBlockComponent? attachedBlock;

  BlockSlotComponent({super.position, super.size})
      : super(
          paint: Paint()
            ..color = Colors.transparent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF333333),
        );
}

class BlockWorkspaceComponent extends PositionComponent with HasGameReference<QueryGame> {
  final List<DraggableBlockComponent> activeBlocks = [];
  final List<BlockSlotComponent> slots = [];
  late final RectangleComponent paletteBg;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
    
    // Draw the palette area at the bottom
    paletteBg = RectangleComponent(
      size: Vector2(size.x, 100),
      position: Vector2(0, size.y - 100),
      paint: Paint()..color = const Color(0xFF15171E),
    );
    add(paletteBg);
    
    _initPaletteBlocks();
    _initSlots();
  }

  void _initPaletteBlocks() {
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
  }

  void _initSlots() {
    // Add slot targets in the main build area
    for (int i = 0; i < 4; i++) {
      final slot = BlockSlotComponent(
        size: Vector2(200, 50),
        position: Vector2(20, 240 + (i * 60)), // Positioned below briefing
      );
      add(slot);
      slots.add(slot);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
    if (isLoaded) {
      paletteBg.size = Vector2(size.x, 100);
      paletteBg.position = Vector2(0, size.y - 100);
      // Re-position palette blocks
      for (int i = 0; i < activeBlocks.length; i++) {
        final b = activeBlocks[i];
        if (b.originalPosition != null && b.originalPosition!.y > size.y - 120) {
          b.position = Vector2(20.0 + (i * 140.0), size.y - 80);
          b.originalPosition = b.position.clone();
        }
      }
    }
  }

  void handleBlockDragEnd(DraggableBlockComponent block) {
    // Check intersection with any slot
    BlockSlotComponent? targetSlot;
    double minDistance = double.infinity;
    
    for (final slot in slots) {
      // Find distance between centers
      final blockCenter = block.position + block.size / 2;
      final slotCenter = slot.position + slot.size / 2;
      final dist = blockCenter.distanceTo(slotCenter);
      
      if (dist < 60 && dist < minDistance) { // Snap threshold
        minDistance = dist;
        targetSlot = slot;
      }
    }

    if (targetSlot != null) {
      // Snap to slot
      block.position = targetSlot.position.clone();
      // Free old slot if any
      for (final s in slots) {
        if (s.attachedBlock == block) s.attachedBlock = null;
      }
      targetSlot.attachedBlock = block;
      
      // Visual feedback for snapping
      block.add(
        ScaleEffect.by(
          Vector2.all(1.1),
          EffectController(
            duration: 0.1,
            reverseDuration: 0.1,
          ),
        ),
      );
    } else {
      // Return to original position
      if (block.originalPosition != null) {
        block.position = block.originalPosition!;
      }
    }
  }
}
