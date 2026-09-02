import 'package:flutter/material.dart';
import '../../../theming/tokens/game_tokens.dart';

/// Results pane â€” displays query result rows with color-coded diff.
///
/// Row states:
///   - Match (default): neutral background
///   - Extra: orange tint ("you returned this, we didn't expect it")
///   - Missing: red tint ("we expected this, you didn't return it")
class ResultPane extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final Set<int> extraRowIndices;
  final Set<int> missingRowIndices;

  const ResultPane({
    super.key,
    required this.rows,
    this.extraRowIndices = const {},
    this.missingRowIndices = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(GameTokens.spaceMd),
        decoration: BoxDecoration(
          color: GameTokens.surface,
          border: Border(
            top: BorderSide(color: GameTokens.accentDim, width: 1),
          ),
        ),
        child: Text(
          '// No rows returned.',
          style: GameTokens.bodySmall.copyWith(
            color: GameTokens.secondaryText,
          ),
        ),
      );
    }

    final columns = rows.first.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: GameTokens.surface,
        border: Border(
          top: BorderSide(color: GameTokens.accentDim, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result header bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceMd,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: GameTokens.surfaceVariant,
              border: Border(
                bottom: BorderSide(color: GameTokens.accentDim, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_rows_outlined,
                    color: GameTokens.accent, size: 12),
                const SizedBox(width: 4),
                Text(
                  'RESULTS  â€”  ${rows.length} row${rows.length == 1 ? '' : 's'}',
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.accent,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 32,
                  dataRowMinHeight: 28,
                  dataRowMaxHeight: 36,
                  dividerThickness: 0.5,
                  headingTextStyle: GameTokens.codeSmall.copyWith(
                    color: GameTokens.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  dataTextStyle: GameTokens.codeSmall,
                  columns: columns
                      .map((col) => DataColumn(
                            label: Text(col),
                          ))
                      .toList(),
                  rows: rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    Color? rowColor;
                    if (extraRowIndices.contains(i)) {
                      rowColor = GameTokens.resultExtra;
                    } else if (missingRowIndices.contains(i)) {
                      rowColor = GameTokens.resultMissing;
                    }

                    return DataRow(
                      color: rowColor != null
                          ? WidgetStateProperty.all(rowColor)
                          : null,
                      cells: columns
                          .map((col) => DataCell(
                                Text(
                                  _formatValue(row[col]),
                                  style: GameTokens.codeSmall.copyWith(
                                    color: row[col] == null
                                        ? GameTokens.disabledText
                                        : GameTokens.primaryText,
                                    fontStyle: row[col] == null
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'NULL';
    if (value is double) {
      if (value == value.truncateToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }
}
