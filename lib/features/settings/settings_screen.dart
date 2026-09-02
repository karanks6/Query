import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/app_theme.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../gameplay/widgets/parallax_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

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
                    value: true,
                    activeColor: SciFiTokens.accent,
                    onChanged: (bool value) {
                      // TODO: Implement audio toggle state
                    },
                  ),
                  SwitchListTile(
                    title: Text('Color-blind Safe Results', style: SciFiTokens.bodyMedium),
                    subtitle: Text('Uses shapes in addition to color', style: SciFiTokens.bodySmall.copyWith(color: SciFiTokens.secondaryText)),
                    value: false,
                    activeColor: SciFiTokens.accent,
                    onChanged: (bool value) {
                      // TODO: Implement colorblind state
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
              child: ListTile(
                title: Text('App Check Status', style: SciFiTokens.bodyMedium),
                subtitle: Text('Initialized', style: SciFiTokens.bodySmall.copyWith(color: SciFiTokens.success)),
                leading: const Icon(Icons.security, color: SciFiTokens.success),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
