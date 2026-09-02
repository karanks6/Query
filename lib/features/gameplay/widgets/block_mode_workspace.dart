import 'package:flutter/material.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../core/sandbox_engine/level_schema.dart';

/// Block Mode workspace (Section 3.1).
///
/// Draggable clause blocks that snap together:
/// SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
///
/// Each block accepts typed values via inline text fields.
/// Produces valid SQL string via [onQueryChanged].
class BlockModeWorkspace extends StatefulWidget {
  final LevelSchema schema;
  final String currentQuery;
  final ValueChanged<String> onQueryChanged;

  const BlockModeWorkspace({
    super.key,
    required this.schema,
    required this.currentQuery,
    required this.onQueryChanged,
  });

  @override
  State<BlockModeWorkspace> createState() => _BlockModeWorkspaceState();
}

class _BlockModeWorkspaceState extends State<BlockModeWorkspace> {
  // Active clause blocks in order
  final List<ClauseBlock> _blocks = [];

  // Available clause blocks to drag in
  static const _availableClauses = [
    ClauseType.select,
    ClauseType.from,
    ClauseType.where,
    ClauseType.groupBy,
    ClauseType.having,
    ClauseType.orderBy,
    ClauseType.limit,
    ClauseType.join,
  ];

  @override
  void initState() {
    super.initState();
    // Start with SELECT and FROM pre-placed (tutorial default)
    _blocks.add(ClauseBlock(type: ClauseType.select, value: ''));
    _blocks.add(ClauseBlock(type: ClauseType.from, value: ''));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _rebuildQuery();
    });
  }

  void _addBlock(ClauseType type) {
    // Don't add duplicates (except JOIN)
    if (type != ClauseType.join &&
        _blocks.any((b) => b.type == type)) {
      return;
    }
    setState(() {
      _blocks.add(ClauseBlock(type: type, value: ''));
      _sortBlocks();
    });
    _rebuildQuery();
  }

  void _removeBlock(int index) {
    // Cannot remove SELECT or FROM
    if (_blocks[index].type == ClauseType.select ||
        _blocks[index].type == ClauseType.from) {
      return;
    }
    setState(() => _blocks.removeAt(index));
    _rebuildQuery();
  }

  void _updateBlockValue(int index, String value) {
    _blocks[index] = ClauseBlock(type: _blocks[index].type, value: value);
    _rebuildQuery();
  }

  void _sortBlocks() {
    _blocks.sort((a, b) =>
        a.type.sortOrder.compareTo(b.type.sortOrder));
  }

  void _triggerAssistMode() {
    // Simple heuristic: suggest the next logical block that isn't present
    if (!_blocks.any((b) => b.type == ClauseType.where)) {
      _addBlock(ClauseType.where);
    } else if (!_blocks.any((b) => b.type == ClauseType.groupBy)) {
      _addBlock(ClauseType.groupBy);
    } else if (!_blocks.any((b) => b.type == ClauseType.orderBy)) {
      _addBlock(ClauseType.orderBy);
    }
  }

  void _rebuildQuery() {
    final parts = <String>[];
    for (final block in _blocks) {
      if (block.value.isNotEmpty) {
        parts.add('${block.type.keyword} ${block.value}');
      } else {
        parts.add(block.type.keyword);
      }
    }
    widget.onQueryChanged(parts.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active blocks area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(GameTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '// QUERY BUILDER',
                      style: GameTokens.bodySmall.copyWith(
                        color: GameTokens.secondaryText,
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _triggerAssistMode,
                      icon: Icon(Icons.lightbulb_outline, size: 14, color: GameTokens.accent),
                      label: Text('Assist', style: GameTokens.bodySmall.copyWith(color: GameTokens.accent)),
                    ),
                  ],
                ),
                const SizedBox(height: GameTokens.spaceSm),

                // Blocks
                ...List.generate(_blocks.length, (i) {
                  return _ClauseBlockWidget(
                    block: _blocks[i],
                    schema: widget.schema,
                    onValueChanged: (v) => _updateBlockValue(i, v),
                    onRemove: _blocks[i].type.isRemovable
                        ? () => _removeBlock(i)
                        : null,
                  );
                }),

                // Drop zone hint
                if (_blocks.length < 4)
                  Container(
                    margin: const EdgeInsets.only(top: GameTokens.spaceSm),
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: GameTokens.accentDim,
                        width: 1,
                        // Dashed border approximation
                      ),
                      borderRadius: GameTokens.borderRadiusSm,
                    ),
                    child: Center(
                      child: Text(
                        '+ tap a clause below to add',
                        style: GameTokens.bodySmall.copyWith(
                          color: GameTokens.hintText,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Clause palette (draggable chips at bottom)
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: GameTokens.surfaceVariant,
            border: Border(
              top: BorderSide(color: GameTokens.accentDim, width: 1),
            ),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceSm,
              vertical: 8,
            ),
            children: _availableClauses.map((clause) {
              final alreadyUsed = clause != ClauseType.join &&
                  _blocks.any((b) => b.type == clause);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: alreadyUsed ? null : () => _addBlock(clause),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: alreadyUsed
                          ? GameTokens.surface
                          : GameTokens.accentDim.withValues(alpha: 0.2),
                      border: Border.all(
                        color: alreadyUsed
                            ? GameTokens.disabledText
                            : GameTokens.accent,
                        width: 1,
                      ),
                      borderRadius: GameTokens.borderRadiusSm,
                    ),
                    child: Text(
                      clause.keyword,
                      style: GameTokens.codeSmall.copyWith(
                        color: alreadyUsed
                            ? GameTokens.disabledText
                            : GameTokens.accent,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ClauseBlockWidget extends StatefulWidget {
  final ClauseBlock block;
  final LevelSchema schema;
  final ValueChanged<String> onValueChanged;
  final VoidCallback? onRemove;

  const _ClauseBlockWidget({
    required this.block,
    required this.schema,
    required this.onValueChanged,
    this.onRemove,
  });

  @override
  State<_ClauseBlockWidget> createState() => _ClauseBlockWidgetState();
}

class _ClauseBlockWidgetState extends State<_ClauseBlockWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.value);
  }

  @override
  void didUpdateWidget(covariant _ClauseBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the parent forced a completely new value that isn't what we already have
    if (widget.block.value != _controller.text) {
      _controller.text = widget.block.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: GameTokens.surfaceVariant,
        borderRadius: GameTokens.borderRadiusSm,
        border: Border.all(color: widget.block.type.color, width: 1),
      ),
      child: Row(
        children: [
          // Keyword badge
          Container(
            width: 84,
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: widget.block.type.color.withValues(alpha: 0.15),
              border: Border(right: BorderSide(color: widget.block.type.color, width: 1)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
            ),
            child: Text(
              widget.block.type.keyword,
              style: GameTokens.codeSmall.copyWith(
                color: widget.block.type.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Value field
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onValueChanged,
              style: GameTokens.code.copyWith(fontSize: 13),
              cursorColor: GameTokens.accent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                isDense: true,
              ),
            ),
          ),

          // Remove button
          if (widget.onRemove != null)
            IconButton(
              icon: const Icon(Icons.close,
                  color: GameTokens.disabledText, size: 14),
              onPressed: widget.onRemove,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

// ───────── Data models ────────────────────────────────────────────────────────

class ClauseBlock {
  final ClauseType type;
  final String value;

  const ClauseBlock({required this.type, required this.value});
}

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

  bool get isRemovable =>
      this != ClauseType.select && this != ClauseType.from;

  Color get color {
    switch (this) {
      case ClauseType.select:
        return const Color(0xFF39FF6A); // accent green
      case ClauseType.from:
        return const Color(0xFF4ACFFF); // info blue
      case ClauseType.join:
        return const Color(0xFFFFD54A); // warning amber
      case ClauseType.where:
        return const Color(0xFFFF9A6A); // orange
      case ClauseType.groupBy:
        return const Color(0xFFB06AFF); // purple
      case ClauseType.having:
        return const Color(0xFFFF6AB3); // pink
      case ClauseType.orderBy:
        return const Color(0xFF6ABFFF); // light blue
      case ClauseType.limit:
        return const Color(0xFFAFFF6A); // lime
    }
  }
}
