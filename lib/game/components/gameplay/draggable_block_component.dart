import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'block_workspace_component.dart';

enum ClauseType {
  select('SELECT', 0),
  from('FROM', 1),
  join('JOIN', 2),
  where('WHERE', 3),
  groupBy('GROUP BY', 4),
  having('HAVING', 5),
  orderBy('ORDER BY', 6),
  limit('LIMIT', 7);

  final String keyword;
  final int sortOrder;
  const ClauseType(this.keyword, this.sortOrder);
  
  Color get color {
    switch (this) {
      case ClauseType.select: return const Color(0xFF39FF6A);
      case ClauseType.from: return const Color(0xFF4ACFFF);
      case ClauseType.join: return const Color(0xFFFFD54A);
      case ClauseType.where: return const Color(0xFFFF9A6A);
      case ClauseType.groupBy: return const Color(0xFFB06AFF);
      case ClauseType.having: return const Color(0xFFFF6AB3);
      case ClauseType.orderBy: return const Color(0xFF6ABFFF);
      case ClauseType.limit: return const Color(0xFFAFFF6A);
    }
  }
}

class DraggableBlockComponent extends PositionComponent with DragCallbacks, TapCallbacks {
  final ClauseType type;
  final bool isDraggable;
  String value;
  final Function(DraggableBlockComponent) onTapBlock;
  Vector2? originalPosition;
  
  DraggableBlockComponent({
    required this.type,
    this.value = '',
    required this.onTapBlock,
    this.isDraggable = true,
    super.position,
    super.size,
  }) {
    originalPosition = position.clone();
  }

  late final TextComponent _valueText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1E2128),
    ));
    
    // Keyword Box
    add(RectangleComponent(
      size: Vector2(size.x * 0.3, size.y),
      paint: Paint()..color = type.color.withOpacity(0.15),
    ));
    
    // Keyword Text
    add(TextComponent(
      text: type.keyword,
      position: Vector2(size.x * 0.15, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: type.color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'JetBrainsMono',
        ),
      ),
    ));

    // Value Text
    _valueText = TextComponent(
      text: value.isEmpty ? type.keyword.toLowerCase() : value,
      position: Vector2(size.x * 0.35, size.y / 2),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: TextStyle(
          color: value.isEmpty ? Colors.white38 : Colors.white,
          fontSize: 14,
          fontFamily: 'JetBrainsMono',
        ),
      ),
    );
    add(_valueText);
  }

  void updateValue(String newValue) {
    value = newValue;
    _valueText.text = value.isEmpty ? type.keyword.toLowerCase() : value;
    _valueText.textRenderer = TextPaint(
      style: TextStyle(
        color: value.isEmpty ? Colors.white38 : Colors.white,
        fontSize: 14,
        fontFamily: 'JetBrainsMono',
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onTapBlock(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!isDraggable) return;
    super.onDragStart(event);
    scale = Vector2.all(1.05);
    priority = 100;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isDraggable) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!isDraggable) return;
    super.onDragEnd(event);
    scale = Vector2.all(1.0);
    priority = 1;
    
    // Call workspace drag end handler if parent is BlockWorkspaceComponent
    if (parent is BlockWorkspaceComponent) {
      (parent as BlockWorkspaceComponent).handleBlockDragEnd(this);
    } else if (originalPosition != null) {
      position = originalPosition!;
    }
  }
}
