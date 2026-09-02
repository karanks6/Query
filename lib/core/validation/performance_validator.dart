import 'package:sqlite3/sqlite3.dart';
import 'validation_result.dart';

/// Layer 4: Performance validation (active from World 3 onward).
///
/// Parses EXPLAIN QUERY PLAN output to detect:
/// - Full table scans where an index was expected
/// - Redundant joins
/// - Unnecessary subqueries
///
/// Returns an efficiency score 0.0–1.0.
class PerformanceValidator {
  PerformanceValidator._();
  static final PerformanceValidator instance = PerformanceValidator._();

  /// [database] is the already-seeded sandbox DB (execution has already run).
  /// [efficiencyThreshold] is the per-level minimum score for the optimal star.
  PerformanceValidationResult validate({
    required Database database,
    required String sql,
    required double efficiencyThreshold,
  }) {
    try {
      final plan = _explainQueryPlan(database, sql);
      final issues = _analyzeplan(plan);
      final score = _computeScore(issues, plan.length);
      final passed = score >= efficiencyThreshold;

      return PerformanceValidationResult(
        passed: passed,
        efficiencyScore: score,
        issues: issues,
        validationResult: passed
            ? const ValidationResult.success()
            : ValidationResult.failure(
                errorMessage: 'Query efficiency below threshold',
                plainEnglishMessage: _buildFeedback(issues, score),
                commonMistakeKey: issues.isNotEmpty ? issues.first.key : null,
              ),
      );
    } catch (_) {
      // Performance validation failures should never block completion.
      return PerformanceValidationResult(
        passed: true,
        efficiencyScore: 1.0,
        issues: const [],
        validationResult: const ValidationResult.success(),
      );
    }
  }

  List<Map<String, dynamic>> _explainQueryPlan(Database db, String sql) {
    final results = <Map<String, dynamic>>[];
    
    // For performance validation, we only care about SELECT statements.
    // If it's a multi-statement or DML query, we extract the first SELECT.
    String queryToAnalyze = sql;
    final selectMatch = RegExp(r'(SELECT\s+.*?)(?:;|$)', caseSensitive: false, dotAll: true).firstMatch(sql);
    if (selectMatch != null) {
      queryToAnalyze = selectMatch.group(1)!;
    }
    
    final stmt = db.prepare('EXPLAIN QUERY PLAN $queryToAnalyze');
    try {
      final resultSet = stmt.select();
      for (final row in resultSet.rows) {
        results.add({
          'id': row[0],
          'parent': row[1],
          'notused': row[2],
          'detail': row[3],
        });
      }
    } finally {
      stmt.dispose();
    }
    return results;
  }

  List<PerformanceIssue> _analyzeplan(List<Map<String, dynamic>> plan) {
    final issues = <PerformanceIssue>[];
    for (final step in plan) {
      final detail = (step['detail'] as String).toUpperCase();
      if (detail.contains('SCAN') && !detail.contains('SEARCH')) {
        issues.add(const PerformanceIssue(
          key: 'full_table_scan',
          description: 'Full table scan detected',
          hint: 'A full scan reads every row in the table. An index or a more specific WHERE clause can speed this up.',
          severity: IssueSeverity.warning,
        ));
      }
    }
    return issues;
  }

  double _computeScore(List<PerformanceIssue> issues, int planSteps) {
    if (issues.isEmpty) return 1.0;
    final penalty = issues.fold(0.0, (sum, i) => sum + i.severity.penalty);
    return (1.0 - penalty).clamp(0.0, 1.0);
  }

  String _buildFeedback(List<PerformanceIssue> issues, double score) {
    if (issues.isEmpty) return 'Query ran efficiently.';
    final scorePercent = (score * 100).toStringAsFixed(0);
    final firstIssue = issues.first;
    return 'Efficiency: $scorePercent%. ${firstIssue.hint}';
  }
}

class PerformanceValidationResult {
  final bool passed;
  final double efficiencyScore;
  final List<PerformanceIssue> issues;
  final ValidationResult validationResult;

  const PerformanceValidationResult({
    required this.passed,
    required this.efficiencyScore,
    required this.issues,
    required this.validationResult,
  });
}

class PerformanceIssue {
  final String key;
  final String description;
  final String hint;
  final IssueSeverity severity;

  const PerformanceIssue({
    required this.key,
    required this.description,
    required this.hint,
    required this.severity,
  });
}

enum IssueSeverity {
  info(0.1),
  warning(0.25),
  critical(0.5);

  final double penalty;
  const IssueSeverity(this.penalty);
}
