import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service responsible for fetching content updates from a remote server.
/// This fulfills Section 7.3 Content Delivery.
class ContentUpdaterService {
  static const String manifestFileName = 'content_cache_manifest.json';
  static const String manifestPrefsKey = 'content_manifest_version';

  /// Check for content updates. Called during Splash Screen.
  static Future<void> checkForUpdates() async {
    try {
      debugPrint('Checking for content updates...');
      
      // For demonstration, we'll try to fetch a manifest from Firebase Storage.
      // If the bucket is not configured, it will throw, which is handled gracefully.
      final storageRef = FirebaseStorage.instance.ref().child(manifestFileName);
      
      String manifestJsonString;
      try {
        final data = await storageRef.getData();
        if (data == null) return;
        manifestJsonString = utf8.decode(data);
      } catch (e) {
        debugPrint('Firebase Storage not configured or manifest missing: $e');
        return;
      }

      final manifest = json.decode(manifestJsonString) as Map<String, dynamic>;
      final remoteVersion = manifest['version'] as int? ?? 0;

      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt(manifestPrefsKey) ?? 0;

      if (remoteVersion > localVersion) {
        debugPrint('New content version $remoteVersion available. Downloading...');
        
        final packs = manifest['packs'] as List<dynamic>? ?? [];
        final docDir = await getApplicationDocumentsDirectory();

        for (final pack in packs) {
          final packMap = pack as Map<String, dynamic>;
          final url = packMap['url'] as String?;
          final id = packMap['id'] as String?;
          
          if (url != null && id != null) {
            await _downloadAndExtractPack(url, docDir, id);
          }
        }

        // Update local version after successful download
        await prefs.setInt(manifestPrefsKey, remoteVersion);
        debugPrint('Content update complete.');
      } else {
        debugPrint('Content is up to date.');
      }
    } catch (e) {
      debugPrint('Failed to check for content updates: $e');
    }
  }

  static Future<void> _downloadAndExtractPack(String url, Directory targetDir, String id) async {
    debugPrint('Downloading content pack: $id...');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      
      // TODO: verify checksum here if needed

      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          // Content pack structure assumes it zips the levels directory
          // e.g. world_04_join_nexus/world.json
          final f = File('${targetDir.path}/assets/levels/$filename');
          await f.create(recursive: true);
          await f.writeAsBytes(data);
        } else {
          final d = Directory('${targetDir.path}/assets/levels/$filename');
          await d.create(recursive: true);
        }
      }
      debugPrint('Extracted pack: $id successfully.');
    } else {
      debugPrint('Failed to download pack $id. Status: ${response.statusCode}');
    }
  }
}
