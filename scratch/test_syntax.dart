import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.openInMemory();
  db.execute('CREATE TABLE test (id INTEGER);');
  
  final sql = 'SELECT * FROM test; SELEC * FROM test;';
  try {
    db.execute(sql);
    print('Execute succeeded');
  } catch (e) {
    print('Error with execute: $e');
  }
}
