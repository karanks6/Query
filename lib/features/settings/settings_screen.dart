import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final tokens = ref.watch(activeTokensProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: tokens.primaryText)),
        backgroundColor: tokens.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: tokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'APPEARANCE',
            style: TextStyle(color: tokens.secondaryText, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.surfaceVariant),
            ),
            child: Column(
              children: AppTheme.values.map((t) {
                return RadioListTile<AppTheme>(
                  title: Text(t.displayName, style: TextStyle(color: tokens.primaryText)),
                  value: t,
                  groupValue: theme,
                  activeColor: tokens.accent,
                  onChanged: (value) {
                    if (value != null) themeNotifier.setTheme(value);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ACCESSIBILITY & AUDIO',
            style: TextStyle(color: tokens.secondaryText, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.surfaceVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Sound Effects', style: TextStyle(color: tokens.primaryText)),
                  value: true,
                  activeColor: tokens.accent,
                  onChanged: (bool value) {
                    // TODO: Implement audio toggle state
                  },
                ),
                SwitchListTile(
                  title: Text('Color-blind Safe Results', style: TextStyle(color: tokens.primaryText)),
                  subtitle: Text('Uses shapes in addition to color', style: TextStyle(color: tokens.secondaryText)),
                  value: false,
                  activeColor: tokens.accent,
                  onChanged: (bool value) {
                    // TODO: Implement colorblind state
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'SYSTEM',
            style: TextStyle(color: tokens.secondaryText, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text('App Check Status', style: TextStyle(color: tokens.primaryText)),
            subtitle: Text('Initialized', style: TextStyle(color: tokens.success)),
            leading: Icon(Icons.security, color: tokens.success),
          ),
        ],
      ),
    );
  }
}
