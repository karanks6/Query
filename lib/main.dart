import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/game.dart';

import 'theming/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/level_map/level_map_screen.dart';
import 'features/gameplay/gameplay_screen.dart';
import 'features/world_select/world_select_screen.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/sandbox/sandbox_screen.dart';
import 'features/reference/reference_screen.dart';
import 'features/daily_challenge/daily_challenge_screen.dart';
import 'features/weekly_case/weekly_case_screen.dart';
import 'data/content/models/level_model.dart';
import 'package:query/features/settings/settings_screen.dart';
import 'package:query/features/profile/profile_screen.dart';
import 'package:query/features/leaderboard/leaderboard_screen.dart';
import 'package:query/core/settings/settings_service.dart';
import 'firebase_options.dart';

import 'game/query_game.dart';

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

class GameRoot extends ConsumerWidget {
  const GameRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(queryGameProvider);
    return GameWidget<QueryGame>(
      game: game,
      overlayBuilderMap: {
        'flutter_ui': (context, game) => const QueryApp(),
      },
      initialActiveOverlays: const ['flutter_ui'],
    );
  }
}

class QueryApp extends ConsumerWidget {
  const QueryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(activeThemeDataProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Query — Learn SQL',
      debugShowCheckedModeBanner: false,
      theme: themeData.copyWith(
        scaffoldBackgroundColor: Colors.transparent, // Allow Flame to show through
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _fadeRoute(const SplashScreen(), settings);
          case '/onboarding':
            return _fadeRoute(const OnboardingScreen(), settings);
          case '/dashboard':
            return _fadeRoute(const DashboardScreen(), settings);
          case '/level_map':
            final worldId = settings.arguments as String? ?? 'world_01';
            return _fadeRoute(LevelMapScreen(worldId: worldId), settings);
          case '/gameplay':
          case '/daily_challenge_gameplay':
            final level = settings.arguments as LevelModel;
            return _slideRoute(GameplayScreen(level: level), settings);
          case '/world_select':
            return _fadeRoute(const WorldSelectScreen(), settings);
          case '/sandbox':
            return _fadeRoute(const SandboxScreen(), settings);
          case '/achievements':
            return _fadeRoute(const AchievementsScreen(), settings);
          case '/leaderboard':
            return _fadeRoute(const LeaderboardScreen(), settings);
          case '/reference':
            return _fadeRoute(const SqlReferenceScreen(), settings);
          case '/settings':
            return _fadeRoute(const SettingsScreen(), settings);
          case '/profile':
            return _fadeRoute(const ProfileScreen(), settings);
          case '/daily_challenge':
            return _fadeRoute(const DailyChallengeScreen(), settings);
          case '/weekly_case':
            return _fadeRoute(const WeeklyCaseScreen(), settings);
          default:
            return _fadeRoute(const SplashScreen(), settings);
        }
      },
    );
  }

  PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 220),
      opaque: false, // Important: Allow Flame game behind route
    );
  }

  PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      opaque: false, // Important: Allow Flame game behind route
    );
  }
}
