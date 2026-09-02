import 'package:flutter/material.dart';
import '../../theming/tokens/sci_fi_tokens.dart';
import '../../theming/components/holo_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/terminal_widgets.dart';

class SqlReferenceScreen extends StatelessWidget {
  const SqlReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SciFiTokens.background,
      appBar: TerminalAppBar(
        title: 'SQL REFERENCE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: ListView(
          padding: const EdgeInsets.all(SciFiTokens.spaceMd),
          children: const [
            _ReferenceItem(
              command: 'SELECT',
              description: 'Extracts data from a database.',
              example: 'SELECT column1, column2 FROM table_name;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
            _ReferenceItem(
              command: 'WHERE',
              description: 'Filters records based on specified conditions.',
              example: 'SELECT * FROM table_name WHERE condition;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
            _ReferenceItem(
              command: 'ORDER BY',
              description: 'Sorts the result set in ascending or descending order.',
              example: 'SELECT * FROM table_name ORDER BY column1 ASC|DESC;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
            _ReferenceItem(
              command: 'LIMIT',
              description: 'Specifies the number of records to return.',
              example: 'SELECT * FROM table_name LIMIT 10;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
            _ReferenceItem(
              command: 'GROUP BY',
              description: 'Groups rows that have the same values into summary rows.',
              example: 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
            _ReferenceItem(
              command: 'HAVING',
              description: 'Added to SQL because the WHERE keyword could not be used with aggregate functions.',
              example: 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name HAVING COUNT(column_name) > 5;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
            _ReferenceItem(
              command: 'INNER JOIN',
              description: 'Returns records that have matching values in both tables.',
              example: 'SELECT column_name(s) FROM table1 INNER JOIN table2 ON table1.column_name = table2.column_name;',
            ),
            SizedBox(height: SciFiTokens.spaceMd),
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
    return HoloPanel(
      emissionIntensity: 0.1,
      padding: const EdgeInsets.all(SciFiTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            command,
            style: SciFiTokens.headlineMedium.copyWith(
              color: SciFiTokens.accent,
            ),
          ),
          const SizedBox(height: SciFiTokens.spaceSm),
          Text(
            description,
            style: SciFiTokens.bodyMedium,
          ),
          const SizedBox(height: SciFiTokens.spaceMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SciFiTokens.spaceSm),
            decoration: BoxDecoration(
              color: SciFiTokens.surface,
              border: Border.all(color: SciFiTokens.accentDim),
              borderRadius: SciFiTokens.borderRadiusSm,
            ),
            child: Text(
              example,
              style: SciFiTokens.code.copyWith(
                color: SciFiTokens.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
