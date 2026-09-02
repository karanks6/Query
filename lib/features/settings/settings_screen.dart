import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../../theming/app_theme.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../core/settings/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'SETTINGS',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: ListView(
          padding: const EdgeInsets.all(SciFiTokens.spaceLg),
          children: [
            Text(
              'APPEARANCE',
              style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText),
            ),
            const SizedBox(height: SciFiTokens.spaceSm),
            HoloPanel(
              emissionIntensity: 0.1,
              child: Column(
                children: AppTheme.values.map((t) {
                  return RadioListTile<AppTheme>(
                    title: Text(t.displayName, style: SciFiTokens.bodyMedium),
                    value: t,
                    groupValue: theme,
                    activeColor: SciFiTokens.accent,
                    onChanged: (value) {
                      if (value != null) themeNotifier.setTheme(value);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: SciFiTokens.spaceXl),
            Text(
              'ACCESSIBILITY & AUDIO',
              style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText),
            ),
            const SizedBox(height: SciFiTokens.spaceSm),
            HoloPanel(
              emissionIntensity: 0.1,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Sound Effects', style: SciFiTokens.bodyMedium),
                    value: settings.soundEffectsEnabled,
                    activeColor: SciFiTokens.accent,
                    onChanged: (bool value) {
                      settingsNotifier.toggleSoundEffects(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Background Music', style: SciFiTokens.bodyMedium),
                    value: settings.musicEnabled,
                    activeColor: SciFiTokens.accent,
                    onChanged: (bool value) {
                      settingsNotifier.toggleMusic(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Color-blind Safe Results', style: SciFiTokens.bodyMedium),
                    subtitle: Text('Uses shapes in addition to color', style: SciFiTokens.bodySmall.copyWith(color: SciFiTokens.secondaryText)),
                    value: settings.colorblindModeEnabled,
                    activeColor: SciFiTokens.accent,
                    onChanged: (bool value) {
                      settingsNotifier.toggleColorblindMode(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: SciFiTokens.spaceXl),
            Text(
              'SYSTEM',
              style: SciFiTokens.labelLarge.copyWith(color: SciFiTokens.secondaryText),
            ),
            const SizedBox(height: SciFiTokens.spaceSm),
            HoloPanel(
              emissionIntensity: 0.1,
              child: FutureBuilder<String?>(
                future: FirebaseAppCheck.instance.getToken().then((value) => value),
                builder: (context, snapshot) {
                  final isReady = snapshot.hasData;
                  final hasError = snapshot.hasError;
                  return ListTile(
                    title: Text('App Check Status', style: SciFiTokens.bodyMedium),
                    subtitle: Text(
                      hasError ? 'Error initializing' : (isReady ? 'Active & Protected' : 'Initializing...'),
                      style: SciFiTokens.bodySmall.copyWith(
                        color: hasError ? SciFiTokens.error : (isReady ? SciFiTokens.success : SciFiTokens.warning)
                      ),
                    ),
                    leading: Icon(
                      hasError ? Icons.error_outline : (isReady ? Icons.security : Icons.sync),
                      color: hasError ? SciFiTokens.error : (isReady ? SciFiTokens.success : SciFiTokens.warning),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
