import 'package:flutter/material.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';

class SqlReferenceScreen extends StatelessWidget {
  const SqlReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'SQL REFERENCE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: ListView(
          padding: const EdgeInsets.all(GameTokens.spaceMd),
          children: const [
            _ReferenceItem(
              command: 'SELECT',
              description: 'Extracts data from a database.',
              example: 'SELECT column1, column2 FROM table_name;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'WHERE',
              description: 'Filters records based on specified conditions.',
              example: 'SELECT * FROM table_name WHERE condition;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'ORDER BY',
              description: 'Sorts the result set in ascending or descending order.',
              example: 'SELECT * FROM table_name ORDER BY column1 ASC|DESC;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'LIMIT',
              description: 'Specifies the number of records to return.',
              example: 'SELECT * FROM table_name LIMIT 10;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'GROUP BY',
              description: 'Groups rows that have the same values into summary rows.',
              example: 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'HAVING',
              description: 'Added to SQL because the WHERE keyword could not be used with aggregate functions.',
              example: 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name HAVING COUNT(column_name) > 5;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'INNER JOIN',
              description: 'Returns records that have matching values in both tables.',
              example: 'SELECT column_name(s) FROM table1 INNER JOIN table2 ON table1.column_name = table2.column_name;',
            ),
            SizedBox(height: GameTokens.spaceMd),
            _ReferenceItem(
              command: 'LEFT JOIN',
              description: 'Returns all records from the left table, and the matched records from the right table.',
              example: 'SELECT column_name(s) FROM table1 LEFT JOIN table2 ON table1.column_name = table2.column_name;',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceItem extends StatelessWidget {
  final String command;
  final String description;
  final String example;

  const _ReferenceItem({
    required this.command,
    required this.description,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return SlantedPanel(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            command,
            style: GameTokens.headlineMedium.copyWith(
              color: GameTokens.accent,
            ),
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Text(
            description,
            style: GameTokens.bodyMedium,
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(GameTokens.spaceSm),
            decoration: BoxDecoration(
              color: GameTokens.surface,
              border: Border.all(color: GameTokens.accentDim),
              borderRadius: GameTokens.borderRadiusSm,
            ),
            child: Text(
              example,
              style: GameTokens.code.copyWith(
                color: GameTokens.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
