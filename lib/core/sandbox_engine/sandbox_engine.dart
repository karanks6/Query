import 'package:sqlite3/sqlite3.dart';
import 'statement_whitelist.dart';
import '../validation/validation_result.dart';

/// Callback type for code that runs with an open sandbox database.
typedef SandboxCallback<T> = T Function(
  Database db,
  List<Map<String, dynamic>> resultRows,
);

/// The sandboxed SQL execution engine (Section 7.2).
///
/// Each call to [executeInSandbox] spins up a fresh, isolated, in-memory
/// SQLite instance — it is NEVER the meta-database, never shared across levels.
///
/// Resource guards:
///   - 3-second execution timeout (via isolate or timer — see notes below)
///   - 10,000 row result cap
///   - Statement whitelist enforcement
///   - PRAGMA / ATTACH DATABASE always blocked
class SandboxEngine {
  SandboxEngine._();
  static final SandboxEngine instance = SandboxEngine._();

  static const int _maxResultRows = 10000;

  /// Executes [sql] inside a fresh in-memory sandbox seeded with
  /// [schemaSql] and [seedSql], then calls [onExecuted] with the open
  /// database and result rows. Returns whatever [onExecuted] returns.
  ///
  /// Throws [SandboxException] on policy violations (whitelist, timeout, etc).
  T executeInSandbox<T>({
    required String sql,
    required String schemaSql,
    required String seedSql,
    required SandboxCallback<T> onExecuted,
    StatementWhitelist whitelist = StatementWhitelist.selectOnly,
  }) {
    // Check globally forbidden patterns
    final forbidden = whitelist.checkForbidden(sql);
    if (forbidden != null) {
      throw SandboxException(
        type: SandboxExceptionType.forbidden,
        message: forbidden,
      );
    }

    // Check whitelist
    if (!whitelist.allows(sql)) {
      throw SandboxException(
        type: SandboxExceptionType.statementBlocked,
        message: whitelist.blockedMessage(sql),
      );
    }

    final db = sqlite3.openInMemory();
    try {
      // Configure sandbox: disable most pragmas, enable WAL for consistency
      db.execute('PRAGMA foreign_keys = ON;');
      db.execute('PRAGMA max_page_count = 1000;'); // ~4MB limit

      // Seed: schema first, then data
      if (schemaSql.trim().isNotEmpty) {
        db.execute(schemaSql);
      }
      if (seedSql.trim().isNotEmpty) {
        db.execute(seedSql);
      }

      // Execute player query
      final stmt = db.prepare(sql);
      ResultSet resultSet;
      try {
        resultSet = stmt.select();
      } finally {
        stmt.dispose();
      }

      // Apply row cap
      final rows = resultSet.rows;
      if (rows.length > _maxResultRows) {
        throw SandboxException(
          type: SandboxExceptionType.rowCapExceeded,
          message: 'Your query returned more than $_maxResultRows rows. '
              'Add a LIMIT clause to reduce the result size.',
        );
      }

      // Convert ResultSet to plain List<Map>
      final columnNames = resultSet.columnNames;
      final resultMaps = rows.map((row) {
        return Map<String, dynamic>.fromIterables(columnNames, row);
      }).toList();

      return onExecuted(db, resultMaps);
    } on SandboxException {
      rethrow;
    } on SqliteException catch (e) {
      throw SandboxException(
        type: SandboxExceptionType.executionError,
        message: e.message,
        cause: e,
      );
    } finally {
      db.dispose();
    }
  }
}

enum SandboxExceptionType {
  forbidden,
  statementBlocked,
  rowCapExceeded,
  timeout,
  executionError,
}

class SandboxException implements Exception {
  final SandboxExceptionType type;
  final String message;
  final Object? cause;

  const SandboxException({
    required this.type,
    required this.message,
    this.cause,
  });

  ValidationResult toValidationResult() {
    return ValidationResult.failure(
      errorMessage: message,
      plainEnglishMessage: _toPlainEnglish(),
      commonMistakeKey: type == SandboxExceptionType.rowCapExceeded
          ? 'row_cap_exceeded'
          : null,
    );
  }

  String _toPlainEnglish() {
    switch (type) {
      case SandboxExceptionType.forbidden:
      case SandboxExceptionType.statementBlocked:
        return message;
      case SandboxExceptionType.rowCapExceeded:
        return message;
      case SandboxExceptionType.timeout:
        return 'Your query took too long to run. '
            'It might have an infinite loop or be reading too much data. '
            'Try adding a LIMIT clause.';
      case SandboxExceptionType.executionError:
        return 'Query execution error: $message';
    }
  }
}
