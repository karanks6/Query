import 'syntax_validator.dart';
import 'semantic_validator.dart';
import 'result_validator.dart';
import 'performance_validator.dart';
import 'validation_result.dart';
import '../sandbox_engine/level_schema.dart';
import '../sandbox_engine/sandbox_engine.dart';
import '../../data/content/models/level_model.dart';

/// Orchestrates the 4-layer validation pipeline (Section 3.2).
///
/// Layer order:
///   1. Syntax — parse check (no execution)
///   2. Semantic — table/column existence, type compat
///   3. Result — execute + diff against expected output
///   4. Performance — EXPLAIN QUERY PLAN efficiency (World 3+)
///
/// All functions are pure Dart with no Flutter/widget dependency.
class QueryValidator {
  final SyntaxValidator _syntaxValidator;
  final SemanticValidator _semanticValidator;
  final ResultValidator _resultValidator;
  final PerformanceValidator _performanceValidator;
  final SandboxEngine _sandboxEngine;

  QueryValidator({
    SyntaxValidator? syntaxValidator,
    SemanticValidator? semanticValidator,
    ResultValidator? resultValidator,
    PerformanceValidator? performanceValidator,
    SandboxEngine? sandboxEngine,
  })  : _syntaxValidator = syntaxValidator ?? SyntaxValidator.instance,
        _semanticValidator = semanticValidator ?? SemanticValidator.instance,
        _resultValidator = resultValidator ?? ResultValidator.instance,
        _performanceValidator = performanceValidator ?? PerformanceValidator.instance,
        _sandboxEngine = sandboxEngine ?? SandboxEngine.instance;

  static final QueryValidator instance = QueryValidator();

  /// Runs all 4 layers and returns a full [QueryValidationReport].
  ///
  /// [sql] — the player's query text
  /// [schema] — the level's schema (tables, columns, types)
  /// [schemaSql] — CREATE TABLE statements to seed the sandbox
  /// [seedSql] — INSERT statements to populate the sandbox
  /// [expected] — the canonical correct result rows
  /// [orderSensitive] — whether row order matters for this level
  /// [performanceActive] — true for World 3+
  /// [efficiencyThreshold] — 0.0–1.0 minimum for optimal star
  /// [isFirstAttempt] — for the first-attempt star
  /// [levelType] — The type of the level being validated
  Future<QueryValidationReport> validate({
    required String sql,
    required LevelSchema schema,
    required String schemaSql,
    required String seedSql,
    required List<Map<String, dynamic>> expected,
    required bool orderSensitive,
    bool performanceActive = false,
    double efficiencyThreshold = 0.8,
    bool isFirstAttempt = false,
    LevelType levelType = LevelType.puzzle,
  }) async {
    // Check for DML statements and wrap them to return a result set
    String executionSql = sql;
    final isDml = RegExp(r'^\s*(INSERT|UPDATE|DELETE)', caseSensitive: false).hasMatch(sql);
    if (isDml && schema.tables.isNotEmpty) {
      executionSql = '$sql; SELECT * FROM ${schema.tables.first.name};';
    }
    // --- Layer 1: Syntax ---
    final syntaxResult = _syntaxValidator.validate(sql);
    if (!syntaxResult.passed) {
      return QueryValidationReport(
        syntaxPassed: false,
        semanticPassed: false,
        resultPassed: false,
        performancePassed: false,
        syntaxResult: syntaxResult,
        semanticResult: const ValidationResult.success(),
        starsEarned: const [false, false, false],
      );
    }

    // --- Layer 2: Semantic ---
    final semanticResult = _semanticValidator.validate(sql, schema);
    if (!semanticResult.passed) {
      return QueryValidationReport(
        syntaxPassed: true,
        semanticPassed: false,
        resultPassed: false,
        performancePassed: false,
        syntaxResult: const ValidationResult.success(),
        semanticResult: semanticResult,
        starsEarned: const [false, false, false],
      );
    }

    // --- Layers 3 & 4: Execute in sandbox ---
    return _sandboxEngine.executeInSandbox(
      sql: executionSql,
      schemaSql: schemaSql,
      seedSql: seedSql,
      onExecuted: (db, actualRows) {
        // Layer 3: Result
        final resultResult = _resultValidator.validate(
          actual: actualRows,
          expected: expected,
          orderSensitive: orderSensitive,
        );

        // Layer 4: Performance (optional)
        PerformanceValidationResult? perfResult;
        if (performanceActive && resultResult.passed) {
          perfResult = _performanceValidator.validate(
            database: db,
            sql: sql, // use the original SQL for EXPLAIN QUERY PLAN
            efficiencyThreshold: efficiencyThreshold,
          );
        }

        bool resultPassed = resultResult.passed;
        final perfPassed = perfResult?.passed ?? true;
        
        // For Optimization Challenges, performance is a hard requirement to pass the level
        if (levelType == LevelType.optimizationChallenge && !perfPassed) {
          resultPassed = false;
        }

        // Star computation
        final completionStar = resultPassed;
        final optimalStar = resultResult.passed && perfPassed;
        final firstAttemptStar = resultPassed && isFirstAttempt;

        return QueryValidationReport(
          syntaxPassed: true,
          semanticPassed: true,
          resultPassed: resultPassed,
          performancePassed: perfPassed,
          syntaxResult: const ValidationResult.success(),
          semanticResult: const ValidationResult.success(),
          resultResult: resultResult,
          performanceResult: perfResult?.validationResult,
          resultRows: actualRows,
          efficiencyScore: perfResult?.efficiencyScore,
          starsEarned: [completionStar, optimalStar, firstAttemptStar],
        );
      },
    );
  }
}
