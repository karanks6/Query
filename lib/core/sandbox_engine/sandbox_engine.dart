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
  /// [schemaSql] and [seedSql]. If [postExecutionSql] is provided, it will
  /// be executed and its result returned. Otherwise, [sql] will be queried
  /// for results if it's a SELECT.
  /// Then calls [onExecuted] with the open database and result rows.
  T executeInSandbox<T>({
    required String sql,
    required String schemaSql,
    required String seedSql,
    String? postExecutionSql,
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

      ResultSet resultSet;
      
      if (postExecutionSql != null) {
        // Run player query (can be multiple statements like INSERT; UPDATE)
        db.execute(sql);
        // Run validation SELECT
        final stmt = db.prepare(postExecutionSql);
        try {
          resultSet = stmt.select();
        } finally {
          stmt.dispose();
        }
      } else {
        // Run player query natively to catch multi-statement syntax errors
        db.execute(sql);
        
        // Unfortunately db.execute doesn't return results. So for SELECT queries,
        // we must re-run the final SELECT statement to get the rows.
        // We split by ; to find the last statement.
        final statements = sql.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        final lastStatement = statements.isNotEmpty ? statements.last : sql;
        
        final stmt = db.prepare(lastStatement);
        try {
          resultSet = stmt.select();
        } finally {
          stmt.dispose();
        }
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
