import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../../../data/content/models/level_model.dart';

class DataBrowser extends StatefulWidget {
  final LevelModel level;
  final ScrollController? scrollController;

  const DataBrowser({super.key, required this.level, this.scrollController});

  @override
  State<DataBrowser> createState() => _DataBrowserState();
}

class _DataBrowserState extends State<DataBrowser> {
  final Set<String> _expanded = {};
  final Map<String, List<Map<String, dynamic>>> _tableData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final table in widget.level.schema.tables) {
      _expanded.add(table.name);
    }
    _fetchData();
  }

  void _fetchData() {
    try {
      final db = sqlite.sqlite3.openInMemory();
      try {
        if (widget.level.schemaSql.trim().isNotEmpty) {
          db.execute(widget.level.schemaSql);
        }
        if (widget.level.seedSql.trim().isNotEmpty) {
          db.execute(widget.level.seedSql);
        }

        for (final table in widget.level.schema.tables) {
          final rs = db.select('SELECT * FROM ${table.name} LIMIT 50');
          _tableData[table.name] = rs.map((row) => Map<String, dynamic>.from(row)).toList();
        }
      } finally {
        db.dispose();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
                  'DATABASE PREVIEW',
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.accent,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Table list or Loading
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: GameTokens.accent))
                : _error != null
                    ? Center(
                        child: Text('Error loading data: $_error',
                            style: GameTokens.bodySmall
                                .copyWith(color: GameTokens.warning)))
                    : ListView(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: GameTokens.spaceSm),
                        children: widget.level.schema.tables
                            .map((table) => _TableItem(
                                  tableName: table.name,
                                  data: _tableData[table.name] ?? [],
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
  final String tableName;
  final List<Map<String, dynamic>> data;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _TableItem({
    required this.tableName,
    required this.data,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceMd,
              vertical: GameTokens.spaceSm,
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  color: GameTokens.accent,
                  size: 16,
                ),
                const SizedBox(width: GameTokens.spaceXs),
                Icon(
                  Icons.table_rows_outlined,
                  color: GameTokens.primaryText,
                  size: 14,
                ),
                const SizedBox(width: GameTokens.spaceXs),
                Text(
                  tableName,
                  style: GameTokens.bodyMedium.copyWith(
                    color: GameTokens.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${data.length} rows',
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.disabledText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Data Table
        if (isExpanded)
          Container(
            color: GameTokens.background,
            width: double.infinity,
            child: data.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(GameTokens.spaceMd),
                    child: Text('No data found.', style: GameTokens.bodySmall),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 32,
                      dataRowMinHeight: 28,
                      dataRowMaxHeight: 28,
                      columnSpacing: 24,
                      headingTextStyle: GameTokens.bodySmall.copyWith(
                        color: GameTokens.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      dataTextStyle: GameTokens.bodySmall.copyWith(
                        color: GameTokens.secondaryText,
                        fontSize: 12,
                      ),
                      columns: data.first.keys.map((key) {
                        return DataColumn(label: Text(key));
                      }).toList(),
                      rows: data.map((row) {
                        return DataRow(
                          cells: row.keys.map((key) {
                            return DataCell(Text(row[key]?.toString() ?? 'NULL'));
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
          ),
      ],
    );
  }
}
