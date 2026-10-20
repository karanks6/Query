import 'package:flutter_test/flutter_test.dart';
import 'package:query/core/sandbox_engine/statement_whitelist.dart';

void main() {
  group('StatementWhitelist', () {
    test('allows plain SELECT queries in World 1-5', () {
      final wl = StatementWhitelist.forWorld(1);
      expect(wl.allows('SELECT * FROM users'), isTrue);
      expect(wl.allows('select id, name from table'), isTrue);
    });

    test('allows CTE queries starting with WITH in World 1-5', () {
      final wl = StatementWhitelist.forWorld(1);
      expect(wl.allows('WITH cte AS (SELECT * FROM users) SELECT * FROM cte'), isTrue);
      expect(wl.allows('with active_users as (select * from u) select * from active_users'), isTrue);
    });

    test('allows queries with leading comments', () {
      final wl = StatementWhitelist.forWorld(1);
      expect(wl.allows('-- single line comment\nSELECT * FROM users'), isTrue);
      expect(wl.allows('/* multi line comment */ SELECT * FROM users'), isTrue);
      expect(wl.allows('  -- comment 1\n  -- comment 2\n  SELECT * FROM users'), isTrue);
    });

    test('blocks DML and DDL in World 1-5', () {
      final wl = StatementWhitelist.forWorld(1);
      expect(wl.allows('INSERT INTO users VALUES (1)'), isFalse);
      expect(wl.allows('UPDATE users SET name = "test"'), isFalse);
      expect(wl.allows('DELETE FROM users'), isFalse);
      expect(wl.allows('CREATE TABLE test (id INT)'), isFalse);
    });

    test('allows DML in World 6', () {
      final wl = StatementWhitelist.forWorld(6);
      expect(wl.allows('SELECT * FROM users'), isTrue);
      expect(wl.allows('INSERT INTO users VALUES (1)'), isTrue);
      expect(wl.allows('UPDATE users SET name = "test"'), isTrue);
      expect(wl.allows('DELETE FROM users'), isTrue);
      expect(wl.allows('CREATE TABLE test (id INT)'), isFalse);
    });

    test('allows DDL in World 7+', () {
      final wl = StatementWhitelist.forWorld(7);
      expect(wl.allows('SELECT * FROM users'), isTrue);
      expect(wl.allows('INSERT INTO users VALUES (1)'), isTrue);
      expect(wl.allows('CREATE TABLE test (id INT)'), isTrue);
      expect(wl.allows('ALTER TABLE test ADD COLUMN age INT'), isTrue);
      expect(wl.allows('DROP TABLE test'), isTrue);
    });

    test('catches forbidden PRAGMA and ATTACH statements', () {
      final wl = StatementWhitelist.forWorld(7);
      expect(wl.checkForbidden('PRAGMA table_info(users)'), isNotNull);
      expect(wl.checkForbidden('ATTACH DATABASE "escape.db" AS esc'), isNotNull);
      expect(wl.checkForbidden('SELECT * FROM users'), isNull);
    });
  });
}
