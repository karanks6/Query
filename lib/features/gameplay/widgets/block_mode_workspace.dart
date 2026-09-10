import 'package:flutter/material.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../data/content/models/level_model.dart';
import '../../../core/sandbox_engine/level_schema.dart';

/// Block Mode workspace (Section 3.1).
///
/// Draggable clause blocks that snap together:
/// SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
///
/// Each block accepts typed values via inline text fields.
/// Produces valid SQL string via [onQueryChanged].
class BlockModeWorkspace extends StatefulWidget {
  final LevelModel level;
  final String currentQuery;
  final ValueChanged<String> onQueryChanged;

  const BlockModeWorkspace({
    super.key,
    required this.level,
    required this.currentQuery,
    required this.onQueryChanged,
  });

  @override
  State<BlockModeWorkspace> createState() => _BlockModeWorkspaceState();
}

class _BlockModeWorkspaceState extends State<BlockModeWorkspace> {
  // Active clause blocks in order
  final List<ClauseBlock> _blocks = [];

  // True when this is a guided tutorial level (guidedAnswer is set)
  bool get _isGuided => widget.level.guidedAnswer?.isNotEmpty ?? false;

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
    if (_isGuided) {
      _initGuidedBlocks();
    } else {
      // Standard: start with SELECT and FROM pre-placed
      _blocks.add(ClauseBlock(type: ClauseType.select, value: ''));
      _blocks.add(ClauseBlock(type: ClauseType.from, value: ''));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _rebuildQuery();
    });
  }

  /// Parses the guidedAnswer SQL and pre-fills blocks.
  /// Blocks that are present in the answer get value from guidedAnswer (locked).
  /// Blocks where the value should be filled by the player stay empty.
  void _initGuidedBlocks() {
    final sql = widget.level.guidedAnswer!.trim();
    for (final type in ClauseType.values) {
      final kw = type.keyword;
      final upperSql = sql.toUpperCase();
      if (upperSql.contains(kw)) {
        // Extract value after this keyword up to the next keyword
        final kwIdx = upperSql.indexOf(kw);
        final start = kwIdx + kw.length;
        int end = upperSql.length;
        for (final other in ClauseType.values) {
          if (other == type) continue;
          final otherIdx = upperSql.indexOf(other.keyword, start);
          if (otherIdx != -1 && otherIdx < end) end = otherIdx;
        }
        final rawValue = sql.substring(start, end).trim();
        // Mark with a placeholder sentinel '___' for player-fill slots
        final isPlayerFill = rawValue == '___' || rawValue.isEmpty;
        _blocks.add(ClauseBlock(
          type: type,
          value: isPlayerFill ? '' : rawValue,
          isGuided: !isPlayerFill,
        ));
      }
    }
    _sortBlocks();
    // Ensure SELECT and FROM are always present
    if (!_blocks.any((b) => b.type == ClauseType.select)) {
      _blocks.insert(0, ClauseBlock(type: ClauseType.select, value: ''));
    }
    if (!_blocks.any((b) => b.type == ClauseType.from)) {
      _blocks.insert(1, ClauseBlock(type: ClauseType.from, value: ''));
    }
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
    final hints = widget.level.hints;
    if (hints.isEmpty) return;

    // Find the full solution hint using proper enum comparison
    HintModel? fullSolutionHint;
    try {
      fullSolutionHint = hints.firstWhere(
        (h) => h.tier == HintTierType.fullSolution,
      );
    } catch (_) {
      fullSolutionHint = hints.isNotEmpty ? hints.last : null;
    }
    if (fullSolutionHint == null) return;

    final solutionSql = (fullSolutionHint.codeSnippet ?? '').toUpperCase();
    if (solutionSql.isEmpty) return;

    // Determine which clause blocks the solution actually uses
    for (final type in ClauseType.values) {
      if (solutionSql.contains(type.keyword) &&
          !_blocks.any((b) => b.type == type)) {
        _addBlock(type);
        // Notify the user which block was added
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Assist: Added "${type.keyword}" block — your query needs this clause.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF1A2435),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // All required blocks are already present — give a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Assist: All required clauses are in place. Check the values in each block.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1A2435),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

                // Guided tutorial banner
                if (_isGuided)
                  Container(
                    margin: const EdgeInsets.only(bottom: GameTokens.spaceSm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: GameTokens.spaceSm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: GameTokens.accent.withValues(alpha: 0.1),
                      borderRadius: GameTokens.borderRadiusSm,
                      border: Border.all(
                        color: GameTokens.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school_outlined,
                            color: GameTokens.accent, size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'GUIDED MODE — Fill in the highlighted blocks to complete the query.',
                            style: GameTokens.bodySmall.copyWith(
                              color: GameTokens.accent,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Blocks
                ...List.generate(_blocks.length, (i) {
                  return _ClauseBlockWidget(
                    block: _blocks[i],
                    schema: widget.level.schema,
                    onValueChanged: (v) => _updateBlockValue(i, v),
                    onRemove: (!_blocks[i].type.isRemovable || _blocks[i].isGuided)
                        ? null
                        : () => _removeBlock(i),
                    isGuided: _isGuided,
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
  final bool isGuided;

  const _ClauseBlockWidget({
    required this.block,
    required this.schema,
    required this.onValueChanged,
    this.onRemove,
    this.isGuided = false,
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
    final isLockedGuided = widget.isGuided && widget.block.isGuided;
    final isPlayerFill = widget.isGuided && !widget.block.isGuided;
    final borderColor = isPlayerFill
        ? GameTokens.warning
        : widget.block.type.color;
    final bgColor = isPlayerFill
        ? GameTokens.warning.withValues(alpha: 0.08)
        : GameTokens.surfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: GameTokens.borderRadiusSm,
        border: Border.all(
          color: borderColor,
          width: isPlayerFill ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Keyword badge
          Container(
            width: 84,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: widget.block.type.color.withValues(alpha: 0.15),
              border: Border(right: BorderSide(color: borderColor, width: 1)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.block.type.keyword,
                  style: GameTokens.codeSmall.copyWith(
                    color: widget.block.type.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLockedGuided) ...[  
                  const SizedBox(width: 4),
                  const Icon(Icons.lock_outline,
                      color: GameTokens.secondaryText, size: 10),
                ],
                if (isPlayerFill) ...[  
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined,
                      color: GameTokens.warning, size: 10),
                ],
              ],
            ),
          ),

          // Value field
          Expanded(
            child: isLockedGuided
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      widget.block.value,
                      style: GameTokens.code.copyWith(
                        fontSize: 13,
                        color: GameTokens.secondaryText,
                      ),
                    ),
                  )
                : TextField(
                    controller: _controller,
                    onChanged: widget.onValueChanged,
                    style: GameTokens.code.copyWith(fontSize: 13),
                    cursorColor:
                        isPlayerFill ? GameTokens.warning : GameTokens.accent,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      isDense: true,
                      hintText: isPlayerFill
                          ? 'Fill this in…'
                          : widget.block.type.placeholder,
                      hintStyle: GameTokens.code.copyWith(
                        fontSize: 13,
                        color: isPlayerFill
                            ? GameTokens.warning.withValues(alpha: 0.6)
                            : GameTokens.hintText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ),

          // Remove button (only for non-guided blocks)
          if (widget.onRemove != null && !isLockedGuided)
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
  final bool isGuided; // Pre-filled by guidedAnswer (locked/read-only)

  const ClauseBlock({
    required this.type,
    required this.value,
    this.isGuided = false,
  });
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

  String get placeholder {
    switch (this) {
      case ClauseType.select:
        return 'e.g.  name, salary';
      case ClauseType.from:
        return 'e.g.  employees';
      case ClauseType.join:
        return 'e.g.  departments ON employees.dept_id = departments.id';
      case ClauseType.where:
        return 'e.g.  salary > 50000';
      case ClauseType.groupBy:
        return 'e.g.  department';
      case ClauseType.having:
        return 'e.g.  COUNT(*) > 5';
      case ClauseType.orderBy:
        return 'e.g.  name ASC';
      case ClauseType.limit:
        return 'e.g.  10';
    }
  }

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
