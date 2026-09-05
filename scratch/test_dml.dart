import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.openInMemory();
  db.execute('CREATE TABLE test (id INTEGER);');
  
  final sql = 'INSERT INTO test (id) VALUES (1); SELECT * FROM test;';
  try {
    final stmt = db.prepare(sql);
    final results = stmt.select();
    print('Select succeeded. Rows: ${results.length}');
  } catch (e) {
    print('Error with prepare.select: $e');
  }

  try {
    db.execute(sql);
    print('Execute succeeded');
  } catch (e) {
    print('Error with execute: $e');
  }
}
