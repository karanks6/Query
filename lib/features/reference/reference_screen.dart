import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../shared/widgets/game_widgets.dart';
import 'codex_screen.dart';

class SqlReferenceScreen extends ConsumerStatefulWidget {
  const SqlReferenceScreen({super.key});

  @override
  ConsumerState<SqlReferenceScreen> createState() => _SqlReferenceScreenState();
}

class _SqlReferenceScreenState extends ConsumerState<SqlReferenceScreen> {

  final List<Map<String, String>> _allConcepts = const [
    {
      'command': 'SELECT',
      'description': 'Extracts data from a database.',
      'example': 'SELECT column1, column2 FROM table_name;',
      'category': 'SELECT',
    },
    {
      'command': 'WHERE',
      'description': 'Filters records based on specified conditions.',
      'example': 'SELECT * FROM table_name WHERE condition;',
      'category': 'WHERE',
    },
    {
      'command': 'ORDER BY',
      'description': 'Sorts the result set in ascending or descending order.',
      'example': 'SELECT * FROM table_name ORDER BY column1 ASC|DESC;',
      'category': 'WHERE',
    },
    {
      'command': 'LIMIT',
      'description': 'Specifies the number of records to return.',
      'example': 'SELECT * FROM table_name LIMIT 10;',
      'category': 'WHERE',
    },
    {
      'command': 'GROUP BY',
      'description': 'Groups rows that have the same values into summary rows.',
      'example': 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name;',
      'category': 'GROUP',
    },
    {
      'command': 'HAVING',
      'description': 'Added to SQL because the WHERE keyword could not be used with aggregate functions.',
      'example': 'SELECT column_name, COUNT(column_name) FROM table_name GROUP BY column_name HAVING COUNT(column_name) > 5;',
      'category': 'GROUP',
    },
    {
      'command': 'INNER JOIN',
      'description': 'Returns records that have matching values in both tables.',
      'example': 'SELECT column_name(s) FROM table1 INNER JOIN table2 ON table1.column_name = table2.column_name;',
      'category': 'JOIN',
    },
    {
      'command': 'LEFT JOIN',
      'description': 'Returns all records from the left table, and the matched records from the right table.',
      'example': 'SELECT column_name(s) FROM table1 LEFT JOIN table2 ON table1.column_name = table2.column_name;',
      'category': 'JOIN',
    },
    {
      'command': 'INSERT',
      'description': 'Inserts new records into a table.',
      'example': 'INSERT INTO table_name (column1, column2) VALUES (value1, value2);',
      'category': 'DML',
    },
    {
      'command': 'COUNT',
      'description': 'Returns the number of rows that matches a specified criterion.',
      'example': 'SELECT COUNT(column_name) FROM table_name WHERE condition;',
      'category': 'FUNC',
    },
  ];

  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  final List<String> _categories = ['ALL', 'SELECT', 'WHERE', 'GROUP', 'JOIN', 'DML', 'FUNC'];

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkedAsync = ref.watch(bookmarkedConceptsProvider);
    final bookmarkedList = bookmarkedAsync.value ?? [];

    var displayedConcepts = _allConcepts;
    
    // Filter by Category
    if (_selectedCategory != 'ALL') {
      displayedConcepts = displayedConcepts.where((c) => c['category'] == _selectedCategory).toList();
    }
    
    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      displayedConcepts = displayedConcepts.where((c) {
        return c['command']!.toLowerCase().contains(q) || c['description']!.toLowerCase().contains(q);
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GameAppBar(
        title: 'SQL REFERENCE TERMINAL',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          ActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CodexScreen()),
              );
            },
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: GameTokens.warning, size: 14),
                const SizedBox(width: 6),
                Text('CODEX', style: GameTokens.labelLarge.copyWith(color: GameTokens.warning)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(GameTokens.spaceLg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GameTokens.code.copyWith(color: GameTokens.accent),
                    decoration: InputDecoration(
                      hintText: 'SEARCH TERMINAL...',
                      hintStyle: GameTokens.code.copyWith(color: GameTokens.secondaryText),
                      prefixIcon: const Icon(Icons.search, color: GameTokens.accentDim),
                      filled: true,
                      fillColor: GameTokens.surface,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: GameTokens.accentDim),
                        borderRadius: GameTokens.borderRadiusSm,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: GameTokens.accent),
                        borderRadius: GameTokens.borderRadiusSm,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Category Tabs
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: GameTokens.spaceMd),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _ToggleButton(
                    title: cat,
                    isActive: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: GameTokens.spaceMd),
            // Content
            Expanded(
              child: displayedConcepts.isEmpty
                  ? Center(
                      child: Text(
                        'NO MATCHING RECORDS FOUND',
                        style: GameTokens.code.copyWith(color: GameTokens.secondaryText),
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg, vertical: GameTokens.spaceMd),
                          itemCount: displayedConcepts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: GameTokens.spaceLg),
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
                    ),
            ),
          ],
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
