import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/levels');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json'));
  
  const encoder = JsonEncoder.withIndent('  ');
  int fixedCount = 0;

  for (final file in files) {
    if (file.path.endsWith('world.json') || file.path.endsWith('manifest.json')) continue;
    
    try {
      final jsonStr = file.readAsStringSync();
      var decoded = json.decode(jsonStr);
      
      if (decoded is! Map<String, dynamic>) continue;
      
      bool modified = false;

      // Fix expected_result if it's a Map
      if (decoded.containsKey('expected_result')) {
        final expected = decoded['expected_result'];
        if (expected is Map) {
          decoded['expected_result'] = [expected];
          modified = true;
        }
      }
      if (decoded.containsKey('expectedResult')) {
        final expected = decoded['expectedResult'];
        if (expected is Map) {
          decoded['expectedResult'] = [expected];
          modified = true;
        }
      }

      if (modified) {
        file.writeAsStringSync(encoder.convert(decoded) + '\n');
        fixedCount++;
        print('Fixed ${file.path}');
      }
    } catch (e) {
      print('ERROR processing ${file.path}: $e');
    }
  }
  print('Done! Fixed $fixedCount files.');
}
