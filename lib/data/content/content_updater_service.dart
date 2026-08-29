import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ContentUpdaterService {
  static const String manifestUrl = 'https://example.com/query_content/manifest.json';
  static const String contentBaseUrl = 'https://example.com/query_content/';

  /// Checks for remote content updates and downloads them if a newer version exists.
  Future<void> checkForUpdates() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final localManifestFile = File('${docDir.path}/manifest.json');
      
      int localVersion = 0;
      if (await localManifestFile.exists()) {
        final content = await localManifestFile.readAsString();
        final json = jsonDecode(content);
        localVersion = json['version'] ?? 0;
      }

      final response = await http.get(Uri.parse(manifestUrl));
      if (response.statusCode == 200) {
        final remoteJson = jsonDecode(response.body);
        final remoteVersion = remoteJson['version'] ?? 0;

        if (remoteVersion > localVersion) {
          // Download updated levels
          final levelsToUpdate = remoteJson['updated_levels'] as List<dynamic>;
          for (final levelPath in levelsToUpdate) {
            final levelResponse = await http.get(Uri.parse('$contentBaseUrl$levelPath'));
            if (levelResponse.statusCode == 200) {
              final levelFile = File('${docDir.path}/$levelPath');
              await levelFile.create(recursive: true);
              await levelFile.writeAsBytes(levelResponse.bodyBytes);
            }
          }
          // Save new manifest
          await localManifestFile.writeAsString(response.body);
        }
      }
    } catch (e) {
      // Fail silently if no network or server is down. We fall back to bundled assets.
      print('Content update failed: $e');
    }
  }
}
