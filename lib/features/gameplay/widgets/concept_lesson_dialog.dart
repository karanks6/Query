import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/slanted_panel.dart';
import '../../../theming/components/action_button.dart';
import '../../../data/content/models/level_model.dart';
import '../../../data/content/concept_cards.dart';

class ConceptLessonDialog extends StatelessWidget {
  final LevelModel level;

  const ConceptLessonDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final card = ConceptCards.forLevel(level.conceptCardId, level.narrative);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(GameTokens.spaceMd),
      child: SlantedPanel(
        colorOverride: GameTokens.surface,
        borderColorOverride: GameTokens.accent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: card == null
              ? _FallbackLesson(level: level)
              : _RichLesson(card: card),
        ),
      ),
    );
  }
}

class _RichLesson extends StatelessWidget {
  final ConceptCard card;
  const _RichLesson({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: GameTokens.accent,
              child: Text('LESSON MODULE', style: GameTokens.labelLarge.copyWith(
                color: GameTokens.background, letterSpacing: 2,
              )),
            ),
          ],
        ),
        const SizedBox(height: GameTokens.spaceMd),
        Text(card.title, style: GameTokens.headlineLarge.copyWith(color: GameTokens.accent)),
        const SizedBox(height: 2),
        Text(card.subtitle, style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText)),
        const SizedBox(height: GameTokens.spaceMd),
        Container(height: 1, color: GameTokens.accentDim),
        const SizedBox(height: GameTokens.spaceMd),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: card.explanation,
                  styleSheet: MarkdownStyleSheet(
                    p: GameTokens.bodyMedium.copyWith(height: 1.5),
                    code: GameTokens.codeSmall.copyWith(
                      color: GameTokens.accent, backgroundColor: GameTokens.surfaceVariant,
                    ),
                    strong: GameTokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold, color: GameTokens.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: GameTokens.spaceMd),
                Text('EXAMPLE', style: GameTokens.bodySmall.copyWith(
                  color: GameTokens.secondaryText, letterSpacing: 1.5,
                )),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(GameTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: GameTokens.surfaceVariant,
                    borderRadius: GameTokens.borderRadiusSm,
                    border: Border.all(color: GameTokens.accentDim),
                  ),
                  child: Text(card.codeExample, style: GameTokens.code.copyWith(
                    color: GameTokens.accent, fontSize: 12,
                  )),
                ),
                if (card.doExample != null || card.dontExample != null) ...[
                  const SizedBox(height: GameTokens.spaceMd),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (card.doExample != null)
                        Expanded(child: _DoCard(text: card.doExample!)),
                      if (card.doExample != null && card.dontExample != null)
                        const SizedBox(width: 8),
                      if (card.dontExample != null)
                        Expanded(child: _DontCard(text: card.dontExample!)),
                    ],
                  ),
                ],
                if (card.tip != null) ...[
                  const SizedBox(height: GameTokens.spaceMd),
                  Container(
                    padding: const EdgeInsets.all(GameTokens.spaceSm),
                    decoration: BoxDecoration(
                      color: GameTokens.warning.withValues(alpha: 0.1),
                      borderRadius: GameTokens.borderRadiusSm,
                      border: Border.all(color: GameTokens.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_outlined, color: GameTokens.warning, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Text(card.tip!, style: GameTokens.bodySmall.copyWith(
                          color: GameTokens.warning,
                        ))),
                      ],
                    ),
                  ),
                ],
              ],
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
    );
  }
}

class _DoCard extends StatelessWidget {
  final String text;
  const _DoCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameTokens.spaceSm),
      decoration: BoxDecoration(
        color: GameTokens.successSurface,
        borderRadius: GameTokens.borderRadiusSm,
        border: Border.all(color: GameTokens.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✓ DO', style: GameTokens.bodySmall.copyWith(
            color: GameTokens.success, fontWeight: FontWeight.bold, fontSize: 9,
          )),
          const SizedBox(height: 4),
          Text(text, style: GameTokens.codeSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _DontCard extends StatelessWidget {
  final String text;
  const _DontCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameTokens.spaceSm),
      decoration: BoxDecoration(
        color: GameTokens.errorSurface,
        borderRadius: GameTokens.borderRadiusSm,
        border: Border.all(color: GameTokens.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✗ AVOID', style: GameTokens.bodySmall.copyWith(
            color: GameTokens.error, fontWeight: FontWeight.bold, fontSize: 9,
          )),
          const SizedBox(height: 4),
          Text(text, style: GameTokens.codeSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _FallbackLesson extends StatelessWidget {
  final LevelModel level;
  const _FallbackLesson({required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school, color: GameTokens.accent, size: 24),
            const SizedBox(width: GameTokens.spaceSm),
            Text('LESSON MODULE', style: GameTokens.headlineMedium.copyWith(color: GameTokens.accent)),
          ],
        ),
        const SizedBox(height: GameTokens.spaceMd),
        Text('In this module, you will apply SQL techniques to solve real-world queries.', style: GameTokens.bodyMedium),
        const SizedBox(height: GameTokens.spaceSm),
        Text('Objective:', style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText)),
        const SizedBox(height: 4),
        Text(level.narrative, style: GameTokens.bodyMedium),
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
    );
  }
}

