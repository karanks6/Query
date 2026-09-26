import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import 'core/settings/settings_service.dart';
import 'theming/app_theme.dart';
import 'firebase_options.dart';
import 'game/query_game.dart';
import 'game/scenes/dashboard_scene.dart';
import 'features/gameplay/gameplay_screen.dart'; // Just for CodeModeWorkspace and ResultPane

final queryGameProvider = Provider<QueryGame>((ref) => QueryGame());
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const GameRoot(),
    ),
  );
}

class GameRoot extends ConsumerStatefulWidget {
  const GameRoot({super.key});

  @override
  ConsumerState<GameRoot> createState() => _GameRootState();
}

class _GameRootState extends ConsumerState<GameRoot> {
  late final GlobalKey<RiverpodAwareGameWidgetState<QueryGame>> gameWidgetKey;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    gameWidgetKey = GlobalKey<RiverpodAwareGameWidgetState<QueryGame>>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(queryGameProvider).pushScene(DashboardScene());
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    final game = ref.watch(queryGameProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ref.watch(activeThemeDataProvider).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: RiverpodAwareGameWidget<QueryGame>(
          key: gameWidgetKey,
          game: game,
          overlayBuilderMap: {
            'flutter_code_editor': (context, game) => const GameplayScreenOverlay(),
          },
          initialActiveOverlays: const [],
        ),
      ),
    );
  }
}
