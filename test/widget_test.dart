import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:query/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QueryApp(),
      ),
    );
    expect(find.byType(ProviderScope), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // clear the Future.delayed in splash
  });
}
