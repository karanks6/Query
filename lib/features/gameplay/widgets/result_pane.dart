import 'package:flutter/material.dart';
import '../../../theming/tokens/terminal_classic_tokens.dart';

/// Results pane — displays query result rows with color-coded diff.
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
        padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
        decoration: BoxDecoration(
          color: TerminalClassicTokens.surface,
          border: Border(
            top: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
          ),
        ),
        child: Text(
          '// No rows returned.',
          style: TerminalClassicTokens.bodySmall.copyWith(
            color: TerminalClassicTokens.secondaryText,
          ),
        ),
      );
    }

    final columns = rows.first.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: TerminalClassicTokens.surface,
        border: Border(
          top: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result header bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TerminalClassicTokens.spaceMd,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: TerminalClassicTokens.surfaceVariant,
              border: Border(
                bottom: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_rows_outlined,
                    color: TerminalClassicTokens.accent, size: 12),
                const SizedBox(width: 4),
                Text(
                  'RESULTS  —  ${rows.length} row${rows.length == 1 ? '' : 's'}',
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.accent,
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
                  headingTextStyle: TerminalClassicTokens.codeSmall.copyWith(
                    color: TerminalClassicTokens.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  dataTextStyle: TerminalClassicTokens.codeSmall,
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
                      rowColor = TerminalClassicTokens.resultExtra;
                    } else if (missingRowIndices.contains(i)) {
                      rowColor = TerminalClassicTokens.resultMissing;
                    }

                    return DataRow(
                      color: rowColor != null
                          ? WidgetStateProperty.all(rowColor)
                          : null,
                      cells: columns
                          .map((col) => DataCell(
                                Text(
                                  _formatValue(row[col]),
                                  style: TerminalClassicTokens.codeSmall.copyWith(
                                    color: row[col] == null
                                        ? TerminalClassicTokens.disabledText
                                        : TerminalClassicTokens.primaryText,
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
