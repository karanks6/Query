import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      case ClauseType.select: return const Color(0xFF4A7C59); // Green
      case ClauseType.from: return const Color(0xFFD48B3E); // Amber
      case ClauseType.join: return const Color(0xFF8B5A2B); // Brown
      case ClauseType.where: return const Color(0xFFB55A30); // Rust
      case ClauseType.groupBy: return const Color(0xFF5A7C8A); // Slate Blue
      case ClauseType.having: return const Color(0xFF8A5A7C); // Plum
      case ClauseType.orderBy: return const Color(0xFF6B8E23); // Olive
      case ClauseType.limit: return const Color(0xFF8F9779); // Sage
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
    
    // Background (Wood block)
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8.0),
    );
    
    add(_CustomRRectComponent(
      rrect: rrect,
      paint: Paint()..color = const Color(0xFFD4C4A8), // Light wood / parchment
    ));
    
    add(_CustomRRectComponent(
      rrect: rrect,
      paint: Paint()
        ..color = const Color(0xFF8B7355)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));
    
    // Keyword Box (Color coded)
    final keywordRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.x * 0.3, size.y),
      topLeft: const Radius.circular(8.0),
      bottomLeft: const Radius.circular(8.0),
    );
    add(_CustomRRectComponent(
      rrect: keywordRRect,
      paint: Paint()..color = type.color.withValues(alpha: 0.8),
    ));
    
    // Keyword Text
    add(TextComponent(
      text: type.keyword,
      position: Vector2(size.x * 0.15, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    ));

    // Value Text
    _valueText = TextComponent(
      text: value.isEmpty ? type.keyword.toLowerCase() : value,
      position: Vector2(size.x * 0.35, size.y / 2),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: value.isEmpty ? const Color(0xFF8B7355).withValues(alpha: 0.6) : const Color(0xFF3D2817),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    add(_valueText);
  }

  void updateValue(String newValue) {
    value = newValue;
    _valueText.text = value.isEmpty ? type.keyword.toLowerCase() : value;
    _valueText.textRenderer = TextPaint(
      style: GoogleFonts.quicksand(
        color: value.isEmpty ? const Color(0xFF8B7355).withValues(alpha: 0.6) : const Color(0xFF3D2817),
        fontSize: 14,
        fontWeight: FontWeight.w700,
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

class _CustomRRectComponent extends PositionComponent {
  final RRect rrect;
  final Paint paint;

  _CustomRRectComponent({required this.rrect, required this.paint});

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(rrect, paint);
  }
}

