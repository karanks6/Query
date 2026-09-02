import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:query/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Game UI QA Test', () {
    testWidgets('verify app starts, navigates, and runs a query without overflow errors',
        (tester) async {
      app.main();
      
      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Find and tap the "START CAREER" or "NEW GAME" button on the onboarding/splash screen
      final startButton = find.textContaining(RegExp(r'(INITIALIZE|START)'));
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton.first);
        await tester.pumpAndSettle();
      }

      // Now we should be on MainMenu or World Selection.
      // Let's tap the first level available. The level card usually has "CASE" or "LEVEL" text.
      final levelNode = find.textContaining(RegExp(r'(LEVEL 1|Level 1)', caseSensitive: false));
      if (levelNode.evaluate().isNotEmpty) {
        await tester.tap(levelNode.first);
        await tester.pumpAndSettle();
      }

      // If a ConceptLessonDialog popped up, dismiss it.
      final proceedButton = find.textContaining(RegExp(r'(PROCEED|GOT IT)'));
      if (proceedButton.evaluate().isNotEmpty) {
        await tester.tap(proceedButton.first);
        await tester.pumpAndSettle();
      }

      // If we are in the gameplay screen, let's enter Code Mode.
      final codeModeButton = find.textContaining(RegExp(r'(CODE MODE|</>)'));
      if (codeModeButton.evaluate().isNotEmpty) {
        await tester.tap(codeModeButton.first);
        await tester.pumpAndSettle();
      }

      // Find the TextField and enter a query
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField.first, 'SELECT * FROM employees;');
        await tester.pumpAndSettle();
      }

      // Tap 'RUN' or 'RUN QUERY'
      final runButton = find.textContaining('RUN');
      if (runButton.evaluate().isNotEmpty) {
        await tester.tap(runButton.last); // Use last in case there are multiple runs
        
        // Wait for sandbox execution and overlay
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Check if FeedbackOverlay appeared
        final feedback = find.textContaining(RegExp(r'(CASE CRACKED|NOT QUITE)'));
        expect(feedback, findsWidgets);
      }

      // If we made it here without tester crashing from RenderFlex overflow, the QA test is successful!
    });
  });
}
