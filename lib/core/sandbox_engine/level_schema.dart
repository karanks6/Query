/// Represents the schema of a level's sandboxed database.
///
/// Used by Layer 2 (semantic validation) to check table/column references
/// without spinning up a full SQLite instance.
class LevelSchema {
  final List<TableSchema> tables;

  LevelSchema({required this.tables});

  /// Set of lowercase table names for O(1) lookup.
  late final Set<String> tableNames = tables.map((t) => t.name.toLowerCase()).toSet();

  /// Map of table name → column names for column-reference checks.
  late final Map<String, Set<String>> columnsByTable = {
    for (final t in tables)
      t.name.toLowerCase(): t.columns.map((c) => c.name.toLowerCase()).toSet(),
  };

  factory LevelSchema.fromJson(Map<String, dynamic> json) {
    final tablesJson = json['tables'] as List<dynamic>? ?? [];
    return LevelSchema(
      tables: tablesJson
          .map((t) => TableSchema.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TableSchema {
  final String name;
  final List<ColumnSchema> columns;

  const TableSchema({required this.name, required this.columns});

  factory TableSchema.fromJson(Map<String, dynamic> json) {
    final columnsJson = json['columns'] as List<dynamic>? ?? [];
    return TableSchema(
      name: json['name'] as String,
      columns: columnsJson
          .map((c) => ColumnSchema.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ColumnSchema {
  final String name;
  final String type; // 'INTEGER', 'TEXT', 'REAL', 'BLOB', 'NULL'
  final bool primaryKey;
  final bool notNull;

  const ColumnSchema({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.notNull = false,
  });

  factory ColumnSchema.fromJson(Map<String, dynamic> json) {
    return ColumnSchema(
      name: json['name'] as String,
      type: json['type'] as String? ?? 'TEXT',
      primaryKey: json['primary_key'] as bool? ?? false,
      notNull: json['not_null'] as bool? ?? false,
    );
  }
}
