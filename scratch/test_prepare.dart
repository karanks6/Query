import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.openInMemory();
  try {
    db.prepare('SELECT * FROM missing_table');
    print('Prepared successfully (THIS IS BAD)');
  } catch (e) {
    print('Prepare threw: $e');
  }
}
