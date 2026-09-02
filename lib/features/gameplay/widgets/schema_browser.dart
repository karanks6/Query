import 'package:flutter/material.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../../../core/sandbox_engine/level_schema.dart';

/// Schema Browser panel (Section 5.5).
///
/// Displays a mini ERD / table-column inspector.
/// Terminal theme: tables and columns in a nested list with
/// bracket-style formatting to reinforce the terminal metaphor.
class SchemaBrowser extends StatefulWidget {
  final LevelSchema schema;
  final ScrollController? scrollController;

  const SchemaBrowser({super.key, required this.schema, this.scrollController});

  @override
  State<SchemaBrowser> createState() => _SchemaBrowserState();
}

class _SchemaBrowserState extends State<SchemaBrowser> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    // Expand all tables by default on first show
    for (final table in widget.schema.tables) {
      _expanded.add(table.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlantedPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceMd,
              vertical: GameTokens.spaceSm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: GameTokens.accentDim, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart_outlined,
                    color: GameTokens.accent, size: 14),
                const SizedBox(width: GameTokens.spaceSm),
                Text(
                  'SCHEMA',
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.accent,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Table list
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(
                  vertical: GameTokens.spaceSm),
              children: widget.schema.tables
                  .map((table) => _TableItem(
                        table: table,
                        isExpanded: _expanded.contains(table.name),
                        onToggle: () {
                          setState(() {
                            if (_expanded.contains(table.name)) {
                              _expanded.remove(table.name);
                            } else {
                              _expanded.add(table.name);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableItem extends StatelessWidget {
  final TableSchema table;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _TableItem({
    required this.table,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table row
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceMd,
              vertical: 6,
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: GameTokens.accent,
                  size: 16,
                ),
                const Icon(Icons.table_rows_outlined,
                    color: GameTokens.accent, size: 12),
                const SizedBox(width: 4),
                Text(
                  table.name,
                  style: GameTokens.code.copyWith(
                    color: GameTokens.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Columns (when expanded)
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: table.columns.map((col) => _ColumnItem(col: col)).toList(),
            ),
          ),
      ],
    );
  }
}

class _ColumnItem extends StatelessWidget {
  final ColumnSchema col;

  const _ColumnItem({required this.col});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            col.primaryKey ? 'Ã°Å¸â€â€˜ ' : '  ',
            style: const TextStyle(fontSize: 9),
          ),
          Text(
            col.name,
            style: GameTokens.codeSmall.copyWith(
              color: GameTokens.primaryText,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            col.type,
            style: GameTokens.codeSmall.copyWith(
              color: GameTokens.secondaryText,
              fontSize: 10,
            ),
          ),
          if (col.notNull)
            Text(
              ' NOT NULL',
              style: GameTokens.codeSmall.copyWith(
                color: GameTokens.disabledText,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}
