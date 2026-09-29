import 'dart:collection';

class Database {
  void execute(String sql, [List<Object?> parameters = const []]) {}
  ResultSet select(String sql, [List<Object?> parameters = const []]) => ResultSet();
  PreparedStatement prepare(String sql, {bool persistent = false, bool v2 = true}) => PreparedStatement();
  void dispose() {}
}

class PreparedStatement {
  ResultSet select([List<Object?> parameters = const []]) => ResultSet();
  void dispose() {}
}

class ResultSet extends IterableBase<Map<String, dynamic>> {
  List<String> get columnNames => [];
  List<List<dynamic>> get rows => [];
  
  @override
  Iterator<Map<String, dynamic>> get iterator => <Map<String, dynamic>>[].iterator;
  
  @override
  bool get isEmpty => true;
  
  @override
  String toString() => '';
}

class SqliteException implements Exception {
  final int resultCode;
  final String message;
  SqliteException(this.resultCode, this.message);
  @override
  String toString() => 'SqliteException($resultCode): $message';
}

class Sqlite3 {
  Database openInMemory() => Database();
}

final sqlite3 = Sqlite3();
