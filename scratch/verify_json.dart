import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/levels');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json'));

  for (final file in files) {
    if (file.path.endsWith('world.json') || file.path.endsWith('manifest.json')) continue;
    
    try {
      final jsonStr = file.readAsStringSync();
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      
      // Try to parse just the fields that are cast to List
      final expectedJson = decoded['expected_result'] ?? decoded['expectedResult'];
      if (expectedJson != null && expectedJson is! List) {
        print('ERROR in ${file.path}: expected_result is not a List. It is ${expectedJson.runtimeType}');
      }
      
      final hintsJson = decoded['hints'];
      if (hintsJson != null && hintsJson is! List) {
        print('ERROR in ${file.path}: hints is not a List. It is ${hintsJson.runtimeType}');
      }

      final levelsJson = decoded['levels'];
      if (levelsJson != null && levelsJson is! List) {
         print('ERROR in ${file.path}: levels is not a List. It is ${levelsJson.runtimeType}');
      }

    } catch (e) {
      print('ERROR parsing ${file.path}: $e');
    }
  }
  print('Done checking.');
}
