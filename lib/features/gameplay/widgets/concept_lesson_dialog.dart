import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../../../theming/components/action_button.dart';
import '../../../data/content/models/level_model.dart';

class ConceptLessonDialog extends StatelessWidget {
  final LevelModel level;

  const ConceptLessonDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Generate a simple educational lesson based on the level type or narrative
    String lessonText = '### New Concept Introduced!\n\n';
    
    if (level.narrative.contains('SELECT') || level.narrative.contains('FROM')) {
      lessonText += 'The **SELECT** statement is used to select data from a database. \nThe data returned is stored in a result table, called the result-set.\n\n';
      lessonText += '```sql\nSELECT column1, column2 FROM table_name;\n```\n\n';
    } else if (level.narrative.contains('WHERE')) {
      lessonText += 'The **WHERE** clause is used to filter records. \nIt is used to extract only those records that fulfill a specified condition.\n\n';
      lessonText += '```sql\nSELECT column1, column2 FROM table_name WHERE condition;\n```\n\n';
    } else if (level.narrative.contains('JOIN')) {
      lessonText += 'A **JOIN** clause is used to combine rows from two or more tables, based on a related column between them.\n\n';
      lessonText += '```sql\nSELECT table1.col, table2.col \nFROM table1 \nJOIN table2 ON table1.id = table2.id;\n```\n\n';
    } else {
      lessonText += 'In this module, you will learn to apply SQL techniques to solve real-world database queries.\n\n';
    }
    
    lessonText += '---\n**Objective**: ${level.narrative}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(GameTokens.spaceMd),
      child: SlantedPanel(
        colorOverride: GameTokens.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, color: GameTokens.accent, size: 24),
                  const SizedBox(width: GameTokens.spaceSm),
                  Text(
                    'LESSON MODULE',
                    style: GameTokens.headlineMedium.copyWith(color: GameTokens.accent),
                  ),
                ],
              ),
              const SizedBox(height: GameTokens.spaceMd),
              MarkdownBody(
                data: lessonText,
                styleSheet: MarkdownStyleSheet(
                  p: GameTokens.bodyMedium,
                  code: GameTokens.codeSmall.copyWith(color: GameTokens.info),
                  codeblockDecoration: BoxDecoration(
                    color: GameTokens.surfaceVariant,
                    borderRadius: GameTokens.borderRadiusSm,
                    border: Border.all(color: GameTokens.accentDim),
                  ),
                ),
              ),
              const SizedBox(height: GameTokens.spaceLg),
              Align(
                alignment: Alignment.centerRight,
                child: ActionButton(
                  isPrimary: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('BEGIN MISSION', style: GameTokens.labelLarge.copyWith(color: GameTokens.background)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
