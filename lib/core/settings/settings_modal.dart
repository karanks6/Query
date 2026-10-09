import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings_service.dart';

class SettingsModal extends ConsumerWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F3E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SETTINGS',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C1B10),
            ),
          ),
          const SizedBox(height: 24),
          _buildToggle(
            title: 'Music',
            value: settings.musicEnabled,
            onChanged: (val) => notifier.toggleMusic(val),
          ),
          const SizedBox(height: 16),
          _buildToggle(
            title: 'Sound Effects',
            value: settings.soundEffectsEnabled,
            onChanged: (val) => notifier.toggleSoundEffects(val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8DCC4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4A484), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C1B10),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A6B53), // Deep forest green
            activeTrackColor: const Color(0xFF88A08C),
            inactiveThumbColor: const Color(0xFF8B5A2B),
            inactiveTrackColor: const Color(0xFFD4C4B4),
          ),
        ],
      ),
    );
  }
}
