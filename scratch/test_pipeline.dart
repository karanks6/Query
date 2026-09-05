import 'package:sqlite3/sqlite3.dart';
import 'package:query/core/sandbox_engine/level_schema.dart';
import 'package:query/core/validation/query_validator.dart';

void main() async {
  final schema = LevelSchema(
    tables: [
      TableSchema(
        name: 'users',
        columns: [
          ColumnSchema(name: 'id', type: 'INTEGER'),
          ColumnSchema(name: 'name', type: 'TEXT'),
        ],
      )
    ],
  );
  
  final schemaSql = 'CREATE TABLE users (id INTEGER, name TEXT);';
  final seedSql = 'INSERT INTO users (id, name) VALUES (1, "Alice");';
  
  final expected = [
    {'id': 1, 'name': 'Alice'},
    {'id': 2, 'name': 'Bob'},
  ];
  
  // Test DML
  print('Testing DML Query...');
  final report = await QueryValidator.instance.validate(
    sql: 'INSERT INTO users (id, name) VALUES (2, "Bob")',
    schema: schema,
    schemaSql: schemaSql,
    seedSql: seedSql,
    expected: expected,
    orderSensitive: false,
    worldId: 6, // World 6 allows DML
  );
  
  print('Syntax Passed: ${report.syntaxPassed}');
  print('Semantic Passed: ${report.semanticPassed}');
  print('Result Passed: ${report.resultPassed}');
  if (report.resultRows != null) {
    print('Result Rows: ${report.resultRows}');
  }
  if (!report.resultPassed) {
    print('Error: ${report.firstFailure.errorMessage}');
  }
}
