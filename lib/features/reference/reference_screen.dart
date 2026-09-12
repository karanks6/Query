import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';

class SqlReferenceScreen extends ConsumerStatefulWidget {
  const SqlReferenceScreen({super.key});

  @override
  ConsumerState<SqlReferenceScreen> createState() => _SqlReferenceScreenState();
}

class _SqlReferenceScreenState extends ConsumerState<SqlReferenceScreen> {
  bool _showBookmarksOnly = false;

  final List<Map<String, String>> _allConcepts = const [
    {
      'command': 'SELECT',
      'description': 'Extracts data from a database.',
      'example': 'SELECT column1, column2 FROM table_name;',
    },
    {
      'command': 'WHERE',
      'description': 'Filters records based on specified conditions.',
      'example': 'SELECT * FROM table_name WHERE condition;',
    },
    {
      'command': 'ORDER BY',
      'description': 'Sorts the result set in ascending or descending order.',
      'example': 'SELECT * FROM table_name ORDER BY column1 ASC|DESC;',
    },
    {
      'command': 'LIMIT',
      'description': 'Specifies the number of records to return.',
      'example': 'SELECT * FROM table_name LIMIT 10;',
    },
    {
      'command': 'GROUP BY',
      'description': 'Groups rows that have the same values into summary rows.',
      'example': 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name;',
    },
    {
      'command': 'HAVING',
      'description': 'Added to SQL because the WHERE keyword could not be used with aggregate functions.',
      'example': 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name HAVING COUNT(column_name) > 5;',
    },
    {
      'command': 'INNER JOIN',
      'description': 'Returns records that have matching values in both tables.',
      'example': 'SELECT column_name(s) FROM table1 INNER JOIN table2 ON table1.column_name = table2.column_name;',
    },
    {
      'command': 'LEFT JOIN',
      'description': 'Returns all records from the left table, and the matched records from the right table.',
      'example': 'SELECT column_name(s) FROM table1 LEFT JOIN table2 ON table1.column_name = table2.column_name;',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bookmarkedAsync = ref.watch(bookmarkedConceptsProvider);
    final bookmarkedList = bookmarkedAsync.value ?? [];

    final displayedConcepts = _showBookmarksOnly
        ? _allConcepts.where((c) => bookmarkedList.contains(c['command'])).toList()
        : _allConcepts;

    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'SQL REFERENCE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(GameTokens.spaceMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ToggleButton(
                    title: 'ALL CONCEPTS',
                    isActive: !_showBookmarksOnly,
                    onTap: () => setState(() => _showBookmarksOnly = false),
                  ),
                  const SizedBox(width: GameTokens.spaceMd),
                  _ToggleButton(
                    title: 'BOOKMARKS',
                    isActive: _showBookmarksOnly,
                    onTap: () => setState(() => _showBookmarksOnly = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: displayedConcepts.isEmpty
                  ? Center(
                      child: Text(
                        'No bookmarked concepts yet.',
                        style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
                      itemCount: displayedConcepts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: GameTokens.spaceMd),
                      itemBuilder: (context, index) {
                        final concept = displayedConcepts[index];
                        final command = concept['command']!;
                        final isBookmarked = bookmarkedList.contains(command);

                        return _ReferenceItem(
                          command: command,
                          description: concept['description']!,
                          example: concept['example']!,
                          isBookmarked: isBookmarked,
                          onBookmarkToggle: () {
                            ref.read(conceptDaoProvider).toggleBookmark(command);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: GameTokens.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceSm),
        decoration: BoxDecoration(
          color: isActive ? GameTokens.accent.withValues(alpha: 0.1) : GameTokens.surface,
          border: Border.all(
            color: isActive ? GameTokens.accent : GameTokens.accentDim,
            width: 1,
          ),
          borderRadius: GameTokens.borderRadiusSm,
        ),
        child: Text(
          title,
          style: GameTokens.labelLarge.copyWith(
            color: isActive ? GameTokens.accent : GameTokens.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _ReferenceItem extends StatelessWidget {
  final String command;
  final String description;
  final String example;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const _ReferenceItem({
    required this.command,
    required this.description,
    required this.example,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SlantedPanel(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                command,
                style: GameTokens.headlineMedium.copyWith(
                  color: GameTokens.accent,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? GameTokens.warning : GameTokens.secondaryText,
                ),
                onPressed: onBookmarkToggle,
              ),
            ],
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
