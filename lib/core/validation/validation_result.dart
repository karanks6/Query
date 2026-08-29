/// Represents the outcome of a single validation layer.
class ValidationResult {
  final bool passed;
  final String? errorMessage;
  final String? plainEnglishMessage;
  final int? errorTokenIndex;
  final String? commonMistakeKey;

  const ValidationResult.success()
      : passed = true,
        errorMessage = null,
        plainEnglishMessage = null,
        errorTokenIndex = null,
        commonMistakeKey = null;

  const ValidationResult.failure({
    required this.errorMessage,
    this.plainEnglishMessage,
    this.errorTokenIndex,
    this.commonMistakeKey,
  })  : passed = false;
}

/// The full result of running all 4 validation layers against a player query.
class QueryValidationReport {
  final bool syntaxPassed;
  final bool semanticPassed;
  final bool resultPassed;
  final bool performancePassed;

  final ValidationResult syntaxResult;
  final ValidationResult semanticResult;
  final ValidationResult? resultResult;
  final ValidationResult? performanceResult;

  /// The result rows returned by query execution (null if syntax/semantic failed).
  final List<Map<String, dynamic>>? resultRows;

  /// The diff between player result and expected result.
  final ResultDiff? resultDiff;

  /// Efficiency score 0.0–1.0 (null if performance layer not active yet).
  final double? efficiencyScore;

  /// Stars earned: [completion, optimal, firstAttempt]
  final List<bool> starsEarned;

  const QueryValidationReport({
    required this.syntaxPassed,
    required this.semanticPassed,
    required this.resultPassed,
    required this.performancePassed,
    required this.syntaxResult,
    required this.semanticResult,
    this.resultResult,
    this.performanceResult,
    this.resultRows,
    this.resultDiff,
    this.efficiencyScore,
    this.starsEarned = const [false, false, false],
  });

  bool get isComplete => resultPassed;

  /// The first failed layer's result for surfacing to the player.
  ValidationResult get firstFailure {
    if (!syntaxPassed) return syntaxResult;
    if (!semanticPassed) return semanticResult;
    if (resultResult != null && !resultPassed) return resultResult!;
    if (performanceResult != null && !performancePassed) return performanceResult!;
    return const ValidationResult.success();
  }
}

/// Describes the diff between actual and expected result sets.
class ResultDiff {
  final int expectedRowCount;
  final int actualRowCount;
  final List<Map<String, dynamic>> missingRows;
  final List<Map<String, dynamic>> extraRows;
  final bool orderMismatch;

  const ResultDiff({
    required this.expectedRowCount,
    required this.actualRowCount,
    required this.missingRows,
    required this.extraRows,
    this.orderMismatch = false,
  });

  String get plainEnglishSummary {
    if (orderMismatch) {
      return 'Your rows are correct but in the wrong order — add ORDER BY to fix it.';
    }
    if (extraRows.isNotEmpty && missingRows.isEmpty) {
      return 'You returned $actualRowCount rows but only $expectedRowCount were expected. '
          'Your WHERE clause may be too broad.';
    }
    if (missingRows.isNotEmpty && extraRows.isEmpty) {
      return 'You returned $actualRowCount rows but $expectedRowCount were expected. '
          'Some rows are missing — check your filter conditions.';
    }
    return 'You returned $actualRowCount rows but $expectedRowCount were expected. '
        '${extraRows.length} extra and ${missingRows.length} missing.';
  }
}
