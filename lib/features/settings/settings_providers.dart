import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/local/app_database.dart';
final unlockedThemesProvider = FutureProvider<List<String>>((ref) async {
  final themesDao = ref.watch(themesDaoProvider);
  final unlocks = await themesDao.getUnlockedThemes();
  return unlocks.map((u) => u.themeId).toList();
});
