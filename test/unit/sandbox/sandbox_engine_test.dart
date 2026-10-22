import 'package:flutter_test/flutter_test.dart';
import 'package:query/core/sandbox_engine/sandbox_engine.dart';
import 'package:query/core/sandbox_engine/statement_whitelist.dart';

void main() {
  group('SandboxEngine Unit Tests', () {
    const schemaSql = '''
      CREATE TABLE items (id INTEGER PRIMARY KEY, name TEXT, stock INTEGER);
    ''';

    const seedSql = '''
      INSERT INTO items (name, stock) VALUES ('Acorn', 100), ('Mushroom', 45);
    ''';

    test('Spins up isolated database, executes SELECT, and returns result rows', () {
      final rows = SandboxEngine.instance.executeInSandbox<List<Map<String, dynamic>>>(
        sql: 'SELECT name, stock FROM items ORDER BY stock DESC;',
        schemaSql: schemaSql,
        seedSql: seedSql,
        onExecuted: (db, resultRows) => resultRows,
      );

      expect(rows.length, equals(2));
      expect(rows[0]['name'], equals('Acorn'));
      expect(rows[0]['stock'], equals(100));
      expect(rows[1]['name'], equals('Mushroom'));
      expect(rows[1]['stock'], equals(45));
    });

    test('Blocks forbidden PRAGMA statements', () {
      expect(
        () => SandboxEngine.instance.executeInSandbox(
          sql: 'PRAGMA database_list;',
          schemaSql: schemaSql,
          seedSql: seedSql,
          onExecuted: (db, resultRows) => resultRows,
        ),
        throwsA(isA<SandboxException>().having(
          (e) => e.type,
          'type',
          SandboxExceptionType.forbidden,
        )),
      );
    });

    test('Blocks forbidden ATTACH DATABASE statements', () {
      expect(
        () => SandboxEngine.instance.executeInSandbox(
          sql: 'ATTACH DATABASE "malicious.db" AS test;',
          schemaSql: schemaSql,
          seedSql: seedSql,
          onExecuted: (db, resultRows) => resultRows,
        ),
        throwsA(isA<SandboxException>().having(
          (e) => e.type,
          'type',
          SandboxExceptionType.forbidden,
        )),
      );
    });

    test('Enforces StatementWhitelist (blocks DDL in selectOnly mode)', () {
      expect(
        () => SandboxEngine.instance.executeInSandbox(
          sql: 'DROP TABLE items;',
          schemaSql: schemaSql,
          seedSql: seedSql,
          whitelist: StatementWhitelist.selectOnly,
          onExecuted: (db, resultRows) => resultRows,
        ),
        throwsA(isA<SandboxException>().having(
          (e) => e.type,
          'type',
          SandboxExceptionType.statementBlocked,
        )),
      );
    });
  });
}
