/// Interface for dialect-specific SQL adapters (Section 7.2).
///
/// v1.0 targets SQLite exclusively via [SQLiteDialectAdapter].
/// Future dialect packs (PostgreSQL, MySQL) add an implementation here
/// without changing the validation or sandbox engine.
abstract class SqlDialectAdapter {
  /// Human-readable name for this dialect.
  String get dialectName;

  /// Prepares a dialect-specific hint about syntax differences.
  String dialectNote(String keyword);

  /// Returns true if this dialect supports the given feature.
  bool supportsFeature(SqlFeature feature);
}

enum SqlFeature {
  windowFunctions,
  recursiveCtes,
  fullOuterJoin,
  returningClause,
  jsonFunctions,
}

/// SQLite dialect adapter — the v1.0 implementation.
class SQLiteDialectAdapter implements SqlDialectAdapter {
  const SQLiteDialectAdapter();

  @override
  String get dialectName => 'SQLite';

  @override
  String dialectNote(String keyword) {
    switch (keyword.toUpperCase()) {
      case 'RIGHT JOIN':
      case 'FULL JOIN':
        return 'SQLite supports RIGHT and FULL OUTER JOIN from version 3.39+. '
            'In older versions, you can rewrite FULL OUTER JOIN using a UNION of LEFT JOINs.';
      case 'RETURNING':
        return 'The RETURNING clause is available in SQLite 3.35+.';
      default:
        return '';
    }
  }

  @override
  bool supportsFeature(SqlFeature feature) {
    switch (feature) {
      case SqlFeature.windowFunctions:
      case SqlFeature.recursiveCtes:
      case SqlFeature.fullOuterJoin:
      case SqlFeature.returningClause:
      case SqlFeature.jsonFunctions:
        return true;
    }
  }
}
