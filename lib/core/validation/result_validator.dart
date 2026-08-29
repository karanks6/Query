import 'validation_result.dart';

/// Layer 3: Result validation.
///
/// Diffs the player's actual result set against the level's canonical expected
/// output. Order-sensitivity is a per-level flag — only enforced when the
/// puzzle explicitly requires ORDER BY.
class ResultValidator {
  ResultValidator._();
  static final ResultValidator instance = ResultValidator._();

  ValidationResult validate({
    required List<Map<String, dynamic>> actual,
    required List<Map<String, dynamic>> expected,
    required bool orderSensitive,
  }) {
    if (actual.isEmpty && expected.isEmpty) return const ValidationResult.success();

    if (actual.length != expected.length) {
      final diff = _buildDiff(actual, expected, orderSensitive);
      return ValidationResult.failure(
        errorMessage:
            'Row count mismatch: got ${actual.length}, expected ${expected.length}',
        plainEnglishMessage: diff.plainEnglishSummary,
      );
    }

    if (orderSensitive) {
      // Ordered comparison — rows must match position-by-position
      for (int i = 0; i < expected.length; i++) {
        if (!_rowsMatch(actual[i], expected[i])) {
          final diff = _buildDiff(actual, expected, true);
          return ValidationResult.failure(
            errorMessage: 'Result mismatch at row ${i + 1}',
            plainEnglishMessage: diff.plainEnglishSummary,
          );
        }
      }
    } else {
      // Unordered comparison — check that every expected row appears in actual
      final remainingActual = List<Map<String, dynamic>>.from(actual);
      for (final expectedRow in expected) {
        final idx = remainingActual.indexWhere((r) => _rowsMatch(r, expectedRow));
        if (idx == -1) {
          final diff = _buildDiff(actual, expected, false);
          return ValidationResult.failure(
            errorMessage: 'Missing expected row in result',
            plainEnglishMessage: diff.plainEnglishSummary,
          );
        }
        remainingActual.removeAt(idx);
      }
    }

    return const ValidationResult.success();
  }

  bool _rowsMatch(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      // Normalize types: SQLite returns ints/doubles/strings
      final aVal = _normalize(a[key]);
      final bVal = _normalize(b[key]);
      if (aVal != bVal) return false;
    }
    return true;
  }

  dynamic _normalize(dynamic value) {
    if (value == null) return null;
    if (value is double && value == value.truncateToDouble()) {
      return value.toInt();
    }
    return value;
  }

  ResultDiff _buildDiff(
    List<Map<String, dynamic>> actual,
    List<Map<String, dynamic>> expected,
    bool orderSensitive,
  ) {
    final missing = <Map<String, dynamic>>[];
    final extra = <Map<String, dynamic>>[];

    final remainingActual = List<Map<String, dynamic>>.from(actual);
    for (final row in expected) {
      final idx = remainingActual.indexWhere((r) => _rowsMatch(r, row));
      if (idx == -1) {
        missing.add(row);
      } else {
        remainingActual.removeAt(idx);
      }
    }
    extra.addAll(remainingActual);

    // Detect pure order mismatch: same rows, different order
    final orderMismatch =
        orderSensitive && missing.isEmpty && extra.isEmpty && actual.length == expected.length;

    return ResultDiff(
      expectedRowCount: expected.length,
      actualRowCount: actual.length,
      missingRows: missing,
      extraRows: extra,
      orderMismatch: orderMismatch,
    );
  }
}
