import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../../theming/app_theme.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../shared/widgets/game_widgets.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../core/settings/settings_service.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'SYSTEM CONFIGURATION',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: ListView(
          padding: const EdgeInsets.all(GameTokens.spaceLg),
          children: [
            Text(
              'APPEARANCE',
              style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText),
            ),
            const SizedBox(height: GameTokens.spaceSm),
            SlantedPanel(
              child: Consumer(
                builder: (context, ref, _) {
                  final unlockedThemesAsync = ref.watch(unlockedThemesProvider);

                  return unlockedThemesAsync.when(
                    data: (unlockedThemeIds) {
                      return Column(
                        children: AppTheme.values.map((t) {
                          final isUnlocked = unlockedThemeIds.contains(t.id);
                          return RadioListTile<AppTheme>(
                            title: Row(
                              children: [
                                Text(
                                  t.displayName, 
                                  style: GameTokens.bodyMedium.copyWith(
                                    color: isUnlocked ? GameTokens.primaryText : GameTokens.disabledText,
                                  ),
                                ),
                                if (!isUnlocked) ...[
                                  const Spacer(),
                                  const Icon(Icons.lock, size: 16, color: GameTokens.disabledText),
                                ],
                              ],
                            ),
                            value: t,
                            groupValue: theme,
                            activeColor: GameTokens.accent,
                            onChanged: isUnlocked 
                                ? (value) {
                                    if (value != null) themeNotifier.setTheme(value);
                                  }
                                : null,
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
                    error: (_, __) => const Text('Error loading themes', style: TextStyle(color: GameTokens.error)),
                  );
                }
              ),
            ),
            const SizedBox(height: GameTokens.spaceXl),
            Text(
              'ACCESSIBILITY & AUDIO',
              style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText),
            ),
            const SizedBox(height: GameTokens.spaceSm),
            SlantedPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Sound Effects', style: GameTokens.bodyMedium),
                    value: settings.soundEffectsEnabled,
                    activeColor: GameTokens.accent,
                    onChanged: (bool value) {
                      settingsNotifier.toggleSoundEffects(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Background Music', style: GameTokens.bodyMedium),
                    value: settings.musicEnabled,
                    activeColor: GameTokens.accent,
                    onChanged: (bool value) {
                      settingsNotifier.toggleMusic(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Color-blind Safe Results', style: GameTokens.bodyMedium),
                    subtitle: Text('Uses shapes in addition to color', style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText)),
                    value: settings.colorblindModeEnabled,
                    activeColor: GameTokens.accent,
                    onChanged: (bool value) {
                      settingsNotifier.toggleColorblindMode(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GameTokens.spaceXl),
            Text(
              'VISUAL EFFECTS',
              style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText),
            ),
            const SizedBox(height: GameTokens.spaceSm),
            SlantedPanel(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CRT Scanline Intensity', style: GameTokens.bodyMedium),
                            Text('80%', style: GameTokens.code.copyWith(color: GameTokens.accent)),
                          ],
                        ),
                        const SizedBox(height: GameTokens.spaceSm),
                        Slider(
                          value: 0.8,
                          activeColor: GameTokens.accent,
                          inactiveColor: GameTokens.accentDim,
                          onChanged: (val) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GameTokens.spaceXl),
            Text(
              'SYSTEM',
              style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText),
            ),
            const SizedBox(height: GameTokens.spaceSm),
            SlantedPanel(
              child: FutureBuilder<String?>(
                future: FirebaseAppCheck.instance.getToken().then((value) => value),
                builder: (context, snapshot) {
                  final isReady = snapshot.hasData;
                  final hasError = snapshot.hasError;
                  return ListTile(
                    title: Text('App Check Status', style: GameTokens.bodyMedium),
                    subtitle: Text(
                      hasError ? 'Error initializing' : (isReady ? 'Active & Protected' : 'Initializing...'),
                      style: GameTokens.bodySmall.copyWith(
                        color: hasError ? GameTokens.error : (isReady ? GameTokens.success : GameTokens.warning)
                      ),
                    ),
                    leading: Icon(
                      hasError ? Icons.error_outline : (isReady ? Icons.security : Icons.sync),
                      color: hasError ? GameTokens.error : (isReady ? GameTokens.success : GameTokens.warning),
                    ),
                  );
                }
              ),
            ),
            const SizedBox(height: GameTokens.spaceXl),
            const SizedBox(height: GameTokens.spaceXl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: GameTokens.error, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: GameTokens.spaceLg),
                  backgroundColor: GameTokens.error.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: GameTokens.borderRadiusSm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, color: GameTokens.error),
                    const SizedBox(width: GameTokens.spaceSm),
                    Text(
                      'CLEAR LOCAL DATA & RESET PROGRESS',
                      style: GameTokens.labelLarge.copyWith(color: GameTokens.error),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: GameTokens.spaceXl),
          ],
        ),
      ),
    );
  }
}
