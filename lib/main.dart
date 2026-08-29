import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theming/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/level_map/level_map_screen.dart';
import 'features/gameplay/gameplay_screen.dart';
import 'data/content/models/level_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: QueryApp(),
    ),
  );
}

class QueryApp extends ConsumerWidget {
  const QueryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(activeThemeDataProvider);

    return MaterialApp(
      title: 'Query — Learn SQL',
      debugShowCheckedModeBanner: false,
      theme: themeData,
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
            final level = settings.arguments as LevelModel;
            return _slideRoute(GameplayScreen(level: level), settings);
          case '/world_select':
            return _fadeRoute(const _PlaceholderScreen('World Select'), settings);
          case '/sandbox':
            return _fadeRoute(const _PlaceholderScreen('Sandbox'), settings);
          case '/achievements':
            return _fadeRoute(const _PlaceholderScreen('Achievements'), settings);
          case '/leaderboard':
            return _fadeRoute(const _PlaceholderScreen('Leaderboard'), settings);
          case '/reference':
            return _fadeRoute(const _PlaceholderScreen('SQL Reference'), settings);
          case '/settings':
            return _fadeRoute(const _PlaceholderScreen('Settings'), settings);
          case '/profile':
            return _fadeRoute(const _PlaceholderScreen('Profile'), settings);
          case '/daily_challenge':
            return _fadeRoute(const _PlaceholderScreen('Daily Challenge'), settings);
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
    );
  }
}

/// Placeholder for Phase 2+ screens.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              '$title\n// Coming in Phase 2',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
