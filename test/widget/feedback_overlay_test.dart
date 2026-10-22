import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:query/core/sandbox_engine/sandbox_engine.dart';
import 'package:query/core/settings/settings_service.dart';
import 'package:query/core/validation/validation_result.dart';
import 'package:query/features/feedback_overlay/feedback_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('FeedbackOverlay Widget QA Tests', () {
    testWidgets('Renders sandbox error message and triggers onRetry', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      bool retryTriggered = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                sandboxError: const SandboxException(
                  type: SandboxExceptionType.forbidden,
                  message: 'PRAGMA statements are strictly prohibited.',
                ),
                onDismiss: () {},
                onRetry: () {
                  retryTriggered = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('PRAGMA statements are strictly prohibited'), findsOneWidget);

      final retryButton = find.text('RETRY');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(retryTriggered, isTrue);
    });

    testWidgets('Renders plain English message for syntax failure report', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const syntaxFail = ValidationResult.failure(
        errorMessage: 'Syntax error near "FROM"',
        plainEnglishMessage: 'You are missing the SELECT column list before FROM.',
      );

      final report = QueryValidationReport(
        syntaxPassed: false,
        semanticPassed: false,
        resultPassed: false,
        performancePassed: false,
        syntaxResult: syntaxFail,
        semanticResult: const ValidationResult.success(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                report: report,
                onDismiss: () {},
                onRetry: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('missing the SELECT column list'), findsOneWidget);
    });
  });
}
