import 'package:flutter_test/flutter_test.dart';
import 'package:query/core/sandbox_engine/level_schema.dart';
import 'package:query/core/validation/semantic_validator.dart';
import 'package:query/core/validation/syntax_validator.dart';
import 'package:query/core/validation/result_validator.dart';

void main() {
  group('Query Validation Multi-Layer QA Tests', () {
    final testSchema = LevelSchema(
      tables: const [
        TableSchema(
          name: 'users',
          columns: [
            ColumnSchema(name: 'id', type: 'INTEGER', primaryKey: true),
            ColumnSchema(name: 'name', type: 'TEXT', notNull: true),
            ColumnSchema(name: 'department', type: 'TEXT'),
          ],
        ),
        TableSchema(
          name: 'orders',
          columns: [
            ColumnSchema(name: 'id', type: 'INTEGER', primaryKey: true),
            ColumnSchema(name: 'user_id', type: 'INTEGER', notNull: true),
            ColumnSchema(name: 'amount', type: 'REAL', notNull: true),
          ],
        ),
      ],
    );

    const testSchemaSql = '''
      CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, department TEXT);
      CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER, amount REAL);
    ''';

    group('Layer 1: SyntaxValidator', () {
      test('Rejects empty query', () {
        final result = SyntaxValidator.instance.validate('', testSchemaSql);
        expect(result.passed, isFalse);
        expect(result.errorMessage, contains('Query is empty'));
      });

      test('Accepts valid SQL query', () {
        final result = SyntaxValidator.instance.validate(
          'SELECT name FROM users;',
          testSchemaSql,
        );
        expect(result.passed, isTrue);
      });

      test('Rejects malformed SQL query with syntax error', () {
        final result = SyntaxValidator.instance.validate(
          'SELECT * FROM WHERE;',
          testSchemaSql,
        );
        expect(result.passed, isFalse);
        expect(result.plainEnglishMessage, isNotNull);
      });

      test('Bypasses missing table/column errors so Layer 2 can handle them', () {
        final result = SyntaxValidator.instance.validate(
          'SELECT missing_col FROM non_existent_table;',
          testSchemaSql,
        );
        expect(result.passed, isTrue);
      });
    });

    group('Layer 2: SemanticValidator', () {
      test('Accepts query referencing valid schema tables', () {
        final result = SemanticValidator.instance.validate(
          'SELECT name FROM users JOIN orders ON users.id = orders.user_id;',
          testSchema,
        );
        expect(result.passed, isTrue);
      });

      test('Flags query referencing unknown table', () {
        final result = SemanticValidator.instance.validate(
          'SELECT * FROM secret_archives;',
          testSchema,
        );
        expect(result.passed, isFalse);
        expect(result.commonMistakeKey, equals('unknown_table'));
        expect(result.errorMessage, contains('secret_archives'));
      });

      test('Flags invalid = NULL comparison', () {
        final result = SemanticValidator.instance.validate(
          'SELECT * FROM users WHERE department = NULL;',
          testSchema,
        );
        expect(result.passed, isFalse);
        expect(result.commonMistakeKey, equals('equals_null'));
        expect(result.plainEnglishMessage, contains('IS NULL'));
      });

      test('Flags ambiguous SELECT * with GROUP BY', () {
        final result = SemanticValidator.instance.validate(
          'SELECT * FROM users GROUP BY department;',
          testSchema,
        );
        expect(result.passed, isFalse);
        expect(result.commonMistakeKey, equals('select_star_group_by'));
      });
    });

    group('Layer 3: ResultValidator', () {
      test('Passes on empty sets when both actual and expected are empty', () {
        final result = ResultValidator.instance.validate(
          actual: [],
          expected: [],
          orderSensitive: false,
        );
        expect(result.passed, isTrue);
      });

      test('Fails on row count mismatch', () {
        final result = ResultValidator.instance.validate(
          actual: [{'id': 1}],
          expected: [{'id': 1}, {'id': 2}],
          orderSensitive: false,
        );
        expect(result.passed, isFalse);
        expect(result.errorMessage, contains('Row count mismatch'));
      });

      test('Order-sensitive mode requires strict row sequence matching', () {
        final actual = [{'id': 2}, {'id': 1}];
        final expected = [{'id': 1}, {'id': 2}];

        final result = ResultValidator.instance.validate(
          actual: actual,
          expected: expected,
          orderSensitive: true,
        );
        expect(result.passed, isFalse);
        expect(result.errorMessage, contains('Result mismatch at row 1'));
      });

      test('Order-insensitive mode accepts permuted rows', () {
        final actual = [{'id': 2, 'name': 'Bob'}, {'id': 1, 'name': 'Alice'}];
        final expected = [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}];

        final result = ResultValidator.instance.validate(
          actual: actual,
          expected: expected,
          orderSensitive: false,
        );
        expect(result.passed, isTrue);
      });
    });
  });
}
