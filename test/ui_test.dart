import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:query/main.dart';
import 'package:query/core/settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Mobile Layout Screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Mock initial setup
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const GameRoot(),
      ),
    );
    
    // Wait for animations and game to settle
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    
    await expectLater(
      find.byType(GameRoot),
      matchesGoldenFile('mobile_ui.png')
    );
  });
}
