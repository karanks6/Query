import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../core/settings/settings_service.dart';

/// Results pane â€” displays query result rows with color-coded diff.
///
/// Row states:
///   - Match (default): neutral background
///   - Extra: orange tint ("you returned this, we didn't expect it")
///   - Missing: red tint ("we expected this, you didn't return it")
class ResultPane extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isColorblindMode = ref.watch(settingsProvider).colorblindModeEnabled;
    if (rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(GameTokens.spaceMd),
        decoration: BoxDecoration(
          color: GameTokens.surface.withValues(alpha: 0.9),
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
        color: GameTokens.surface.withValues(alpha: 0.9),
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
                      cells: columns.asMap().entries.map((colEntry) {
                        final colIdx = colEntry.key;
                        final colName = colEntry.value;
                        
                        Widget cellContent = Text(
                          _formatValue(row[colName]),
                          style: GameTokens.codeSmall.copyWith(
                            color: row[colName] == null
                                ? GameTokens.disabledText
                                : GameTokens.primaryText,
                            fontStyle: row[colName] == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        );
                        
                        if (isColorblindMode && colIdx == 0) {
                          if (extraRowIndices.contains(i)) {
                            cellContent = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('[+] ', style: TextStyle(color: GameTokens.warning, fontWeight: FontWeight.bold)),
                                cellContent,
                              ],
                            );
                          } else if (missingRowIndices.contains(i)) {
                            cellContent = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('[-] ', style: TextStyle(color: GameTokens.error, fontWeight: FontWeight.bold)),
                                cellContent,
                              ],
                            );
                          }
                        }

                        return DataCell(cellContent);
                      }).toList(),
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
