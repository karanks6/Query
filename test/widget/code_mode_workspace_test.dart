import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:query/core/sandbox_engine/level_schema.dart';
import 'package:query/features/gameplay/widgets/code_mode_workspace.dart';

void main() {
  group('CodeModeWorkspace', () {
    final testSchema = LevelSchema(
      tables: [
        TableSchema(
          name: 'users',
          columns: [
            ColumnSchema(name: 'id', type: 'INTEGER'),
            ColumnSchema(name: 'name', type: 'TEXT'),
          ],
        ),
      ],
    );

    testWidgets('renders code mode workspace with initial query', (tester) async {
      String query = 'SELECT * FROM users';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeModeWorkspace(
              schema: testSchema,
              currentQuery: query,
              onQueryChanged: (q) => query = q,
            ),
          ),
        ),
      );

      expect(find.text('query.sql'), findsOneWidget);
      expect(find.text('1 lines'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('updates line count reactively when typing multiple lines', (tester) async {
      String query = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeModeWorkspace(
              schema: testSchema,
              currentQuery: query,
              onQueryChanged: (q) => query = q,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'SELECT *\nFROM users\nWHERE id = 1');
      await tester.pump();

      expect(find.text('3 lines'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('SqlSyntaxTextEditingController', () {
    testWidgets('tokenizes and formats SQL queries with keywords and comments', (tester) async {
      final controller = SqlSyntaxTextEditingController(
        text: '-- Comment\nSELECT id, name FROM users WHERE id = 42',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final span = controller.buildTextSpan(
                  context: context,
                  withComposing: false,
                );
                expect(span.children, isNotEmpty);
                expect(span.toPlainText(), equals('-- Comment\nSELECT id, name FROM users WHERE id = 42'));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}
