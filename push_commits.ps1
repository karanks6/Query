git add assets/ pubspec.yaml
git commit -m "?? Add Wanderwood chapter assets & pubspec updates"
git push -f

git add lib/game/components/ui/
git add lib/theming/
git commit -m "? Introduce Wanderwood UI components and tokens"
git push

git add lib/game/components/gameplay/
git commit -m "?? Refactor gameplay components to match natural theme"
git push

git add lib/game/scenes/splash_scene.dart lib/game/scenes/dashboard_scene.dart lib/game/scenes/daily_challenge_scene.dart
git commit -m "?? Redesign Dashboard & Splash scenes to Tales of the Wild"
git push

git add lib/game/scenes/world_select_scene.dart lib/game/scenes/level_map_scene.dart
git commit -m "??? Update World Select and Map scenes"
git push

git add lib/game/scenes/gameplay_scene.dart lib/game/scenes/victory_scene.dart lib/game/scenes/query_scene.dart
git commit -m "?? Overhaul Gameplay & Victory scenes for new aesthetics"
git push

git add lib/game/components/
git commit -m "??? Update remaining game HUD and overlay components"
git push

git add lib/features/
git add lib/data/
git add lib/main.dart lib/shared/ lib/game/query_game.dart
git commit -m "? Complete UI transition across screens and core app logic"
git push
