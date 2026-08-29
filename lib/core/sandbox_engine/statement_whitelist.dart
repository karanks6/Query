/// Per-world whitelist of SQL statement types.
///
/// Enforced in the sandbox before execution — prevents early worlds from
/// using DDL or DML they haven't learned yet, and prevents engine escapes
/// everywhere (PRAGMA, ATTACH DATABASE).
class StatementWhitelist {
  final Set<AllowedStatementType> _allowed;

  const StatementWhitelist(this._allowed);

  /// Returns true if [sql] starts with an allowed statement keyword.
  bool allows(String sql) {
    final upper = sql.trim().toUpperCase();
    for (final type in _allowed) {
      if (upper.startsWith(type.keyword)) return true;
    }
    return false;
  }

  /// Checks for globally forbidden patterns (always blocked regardless of world).
  String? checkForbidden(String sql) {
    final upper = sql.trim().toUpperCase();
    if (upper.startsWith('PRAGMA')) {
      return 'PRAGMA statements are disabled in the sandbox.';
    }
    if (upper.contains('ATTACH DATABASE') || upper.contains('ATTACH ')) {
      return 'ATTACH DATABASE is disabled in the sandbox.';
    }
    if (upper.startsWith('DETACH')) {
      return 'DETACH is disabled in the sandbox.';
    }
    return null;
  }

  /// Generates a plain-English message for blocked statement types.
  String blockedMessage(String sql) {
    final upper = sql.trim().toUpperCase();
    if (upper.startsWith('INSERT') || upper.startsWith('UPDATE') || upper.startsWith('DELETE')) {
      return 'Data modification (INSERT/UPDATE/DELETE) isn\'t available in this world yet. '
          'You\'ll unlock it in World 6: Data Forge.';
    }
    if (upper.startsWith('CREATE') || upper.startsWith('ALTER') || upper.startsWith('DROP')) {
      return 'Schema changes (CREATE/ALTER/DROP) aren\'t available yet. '
          'You\'ll learn them in World 7: Blueprint Bureau.';
    }
    return 'This type of statement isn\'t allowed in this level.';
  }

  // --- Pre-built whitelists per world range ---

  /// Worlds 1–5: SELECT only
  static const selectOnly = StatementWhitelist({AllowedStatementType.select});

  /// World 6: SELECT + DML
  static const selectAndDml = StatementWhitelist({
    AllowedStatementType.select,
    AllowedStatementType.insert,
    AllowedStatementType.update,
    AllowedStatementType.delete,
  });

  /// World 7+: SELECT + DML + DDL
  static const full = StatementWhitelist({
    AllowedStatementType.select,
    AllowedStatementType.insert,
    AllowedStatementType.update,
    AllowedStatementType.delete,
    AllowedStatementType.create,
    AllowedStatementType.alter,
    AllowedStatementType.drop,
  });

  static StatementWhitelist forWorld(int worldNumber) {
    if (worldNumber <= 5) return selectOnly;
    if (worldNumber == 6) return selectAndDml;
    return full;
  }
}

enum AllowedStatementType {
  select('SELECT'),
  insert('INSERT'),
  update('UPDATE'),
  delete('DELETE'),
  create('CREATE'),
  alter('ALTER'),
  drop('DROP'),
  with_('WITH'); // CTEs

  final String keyword;
  const AllowedStatementType(this.keyword);
}
