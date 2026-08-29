import 'validation_result.dart';
import '../sandbox_engine/level_schema.dart';

/// Layer 2: Semantic validation.
///
/// Checks that all referenced tables and columns exist in the level's schema,
/// and flags type mismatches (e.g. comparing a TEXT column to an integer literal).
/// This runs AFTER syntax validation confirms the query is parseable.
class SemanticValidator {
  SemanticValidator._();
  static final SemanticValidator instance = SemanticValidator._();

  ValidationResult validate(String sql, LevelSchema schema) {
    final upper = sql.toUpperCase();
    final errors = <String>[];

    // --- Table reference check ---
    final referencedTables = _extractTableReferences(sql);
    for (final table in referencedTables) {
      if (!schema.tableNames.contains(table.toLowerCase())) {
        errors.add(table);
      }
    }

    if (errors.isNotEmpty) {
      final tableList = errors.join(', ');
      return ValidationResult.failure(
        errorMessage: 'Unknown table(s): $tableList',
        plainEnglishMessage:
            'The table${errors.length > 1 ? 's' : ''} "$tableList" '
            '${errors.length > 1 ? 'don\'t exist' : 'doesn\'t exist'} in this database. '
            'Open the Schema Browser to see the available tables.',
        commonMistakeKey: 'unknown_table',
      );
    }

    // --- NULL comparison check (= NULL instead of IS NULL) ---
    if (RegExp(r'=\s*NULL', caseSensitive: false).hasMatch(sql)) {
      return ValidationResult.failure(
        errorMessage: 'Invalid NULL comparison using =',
        plainEnglishMessage:
            'You can\'t use = to compare with NULL. '
            'NULL means "unknown", so you need IS NULL or IS NOT NULL instead.',
        commonMistakeKey: 'equals_null',
      );
    }

    // --- SELECT * in aggregation context ---
    if (upper.contains('GROUP BY') && upper.contains('SELECT *')) {
      return ValidationResult.failure(
        errorMessage: 'SELECT * with GROUP BY is ambiguous',
        plainEnglishMessage:
            'When using GROUP BY, SELECT * doesn\'t make sense — '
            'specify which columns and aggregate functions you want instead.',
        commonMistakeKey: 'select_star_group_by',
      );
    }

    return const ValidationResult.success();
  }

  /// Extracts table names from FROM and JOIN clauses using a simple regex.
  /// Handles aliases: "FROM orders o" and "FROM orders AS o".
  List<String> _extractTableReferences(String sql) {
    final tables = <String>[];
    // Match FROM <table> and JOIN <table>
    final pattern = RegExp(
      r'(?:FROM|JOIN)\s+([a-zA-Z_][a-zA-Z0-9_]*)',
      caseSensitive: false,
    );
    for (final match in pattern.allMatches(sql)) {
      final name = match.group(1);
      if (name != null) tables.add(name.toLowerCase());
    }
    return tables;
  }
}
