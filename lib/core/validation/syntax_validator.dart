import 'package:sqlite3/sqlite3.dart';
import 'validation_result.dart';

/// Layer 1: Syntax validation.
///
/// Uses sqlite3's `prepare()` in a throwaway in-memory database to detect
/// syntax errors without executing. This is the most reliable approach —
/// the SQLite parser itself catches errors exactly as execution would.
class SyntaxValidator {
  SyntaxValidator._();

  static final SyntaxValidator instance = SyntaxValidator._();

  ValidationResult validate(String sql, String schemaSql) {
    if (sql.trim().isEmpty) {
      return const ValidationResult.failure(
        errorMessage: 'Query is empty.',
        plainEnglishMessage: 'Write a SQL query in the workspace, then press Run.',
      );
    }

    Database? db;
    try {
      db = sqlite3.openInMemory();
      if (schemaSql.trim().isNotEmpty) {
        db.execute(schemaSql);
      }
      
      // Execute the query to catch syntax errors even in multi-statement queries.
      // This DB is disposed immediately, so execution side-effects don't matter.
      db.execute(sql);
      
      return const ValidationResult.success();
    } on SqliteException catch (e) {
      final lower = e.message.toLowerCase();
      // SQLite execution will throw on missing tables/columns. We want to bypass
      // these here so that Layer 2 (SemanticValidator) can catch them and give
      // user-friendly feedback instead of generic syntax errors.
      if (lower.contains('no such table') || lower.contains('no such column')) {
        return const ValidationResult.success();
      }

      return ValidationResult.failure(
        errorMessage: e.message,
        plainEnglishMessage: _translateSyntaxError(e.message, sql),
        commonMistakeKey: _detectCommonMistakeKey(e.message),
      );
    } finally {
      db?.dispose();
    }
  }

  String _translateSyntaxError(String raw, String sql) {
    final lower = raw.toLowerCase();
    if (lower.contains('near')) {
      final nearMatch = RegExp(r'near "(.+?)": syntax error').firstMatch(lower);
      if (nearMatch != null) {
        final token = nearMatch.group(1);
        return 'Syntax error near "$token". Check for a missing comma, keyword, or closing parenthesis.';
      }
    }
    if (lower.contains('incomplete input')) {
      return 'Your query looks incomplete. Did you forget to finish a clause like WHERE or JOIN?';
    }
    if (lower.contains('unrecognized token')) {
      return 'There\'s an unrecognized character in your query. Check for typos or invalid symbols.';
    }
    return 'Syntax error: $raw. Check your SQL structure and try again.';
  }

  String? _detectCommonMistakeKey(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('near "from"')) return 'missing_select_list';
    if (lower.contains('near "where"')) return 'missing_from_clause';
    if (lower.contains('near "group"')) return 'group_by_syntax';
    if (lower.contains('near "having"')) return 'having_without_group';
    return null;
  }
}
