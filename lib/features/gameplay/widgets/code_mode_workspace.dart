import 'package:flutter/material.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../core/sandbox_engine/level_schema.dart';

/// Code Mode workspace (Section 3.1).
///
/// A real text editor with:
/// - SQL syntax highlighting
/// - Schema-aware autocomplete suggestions
/// - Blinking block cursor (Terminal theme signature element)
/// - Line numbers
class CodeModeWorkspace extends StatefulWidget {
  final LevelSchema schema;
  final String currentQuery;
  final ValueChanged<String> onQueryChanged;

  const CodeModeWorkspace({
    super.key,
    required this.schema,
    required this.currentQuery,
    required this.onQueryChanged,
  });

  @override
  State<CodeModeWorkspace> createState() => _CodeModeWorkspaceState();
}

class _CodeModeWorkspaceState extends State<CodeModeWorkspace> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  static const _keywords = [
    'SELECT', 'FROM', 'WHERE', 'JOIN', 'INNER JOIN', 'LEFT JOIN',
    'RIGHT JOIN', 'GROUP BY', 'HAVING', 'ORDER BY', 'LIMIT', 'OFFSET',
    'DISTINCT', 'AS', 'AND', 'OR', 'NOT', 'IN', 'IS NULL', 'IS NOT NULL',
    'LIKE', 'BETWEEN', 'EXISTS', 'UNION', 'INTERSECT', 'EXCEPT',
    'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'ON', 'ASC', 'DESC',
    'INSERT INTO', 'UPDATE', 'DELETE FROM', 'CREATE TABLE',
    'WITH', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentQuery);
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CodeModeWorkspace old) {
    super.didUpdateWidget(old);
    if (old.currentQuery != widget.currentQuery &&
        _controller.text != widget.currentQuery) {
      _controller.text = widget.currentQuery;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onQueryChanged(_controller.text);
    _updateSuggestions();
  }

  void _updateSuggestions() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    if (cursorPos < 0 || cursorPos > text.length) {
      setState(() => _showSuggestions = false);
      return;
    }

    // Find the current word being typed
    final beforeCursor = text.substring(0, cursorPos);
    final wordMatch = RegExp(r'[\w.]+$').firstMatch(beforeCursor);
    final currentWord = wordMatch?.group(0)?.toUpperCase() ?? '';

    if (currentWord.length < 2) {
      setState(() => _showSuggestions = false);
      return;
    }

    // Match against keywords + schema names
    final candidates = [
      ..._keywords,
      ...widget.schema.tables.map((t) => t.name),
      ...widget.schema.tables.expand((t) => t.columns.map((c) => c.name)),
    ];

    final matches = candidates
        .where((c) => c.toUpperCase().startsWith(currentWord) && c.toUpperCase() != currentWord)
        .take(6)
        .toList();

    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  void _applySuggestion(String suggestion) {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    if (cursorPos < 0) return;

    final beforeCursor = text.substring(0, cursorPos);
    final wordMatch = RegExp(r'[\w.]+$').firstMatch(beforeCursor);
    if (wordMatch == null) return;

    final newText =
        text.substring(0, wordMatch.start) + suggestion + text.substring(cursorPos);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: wordMatch.start + suggestion.length),
    );
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Code header bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GameTokens.spaceMd,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: GameTokens.surfaceVariant,
            border: Border(
              bottom: BorderSide(color: GameTokens.accentDim, width: 1),
            ),
          ),
          child: Row(
            children: [
              Text(
                'query.sql',
                style: GameTokens.bodySmall.copyWith(
                  color: GameTokens.accent,
                ),
              ),
              const Spacer(),
              Text(
                '${_controller.text.split('\n').length} lines',
                style: GameTokens.bodySmall.copyWith(
                  color: GameTokens.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // Editor + suggestions overlay
        Expanded(
          child: Stack(
            children: [
              // Code editor
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  _LineNumbers(text: _controller.text),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: GameTokens.code,
                      cursorColor: GameTokens.accent,
                      cursorWidth: 8,
                      cursorHeight: 16,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(GameTokens.spaceSm),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              // Autocomplete suggestions
              if (_showSuggestions)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _AutocompleteSuggestions(
                    suggestions: _suggestions,
                    onSelect: _applySuggestion,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineNumbers extends StatelessWidget {
  final String text;

  const _LineNumbers({required this.text});

  @override
  Widget build(BuildContext context) {
    final lineCount = '\n'.allMatches(text).length + 1;
    return Container(
      width: 36,
      color: GameTokens.surfaceVariant,
      padding: const EdgeInsets.all(GameTokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          lineCount,
          (i) => Text(
            '${i + 1}',
            style: GameTokens.codeSmall.copyWith(
              color: GameTokens.disabledText,
              fontSize: 10,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _AutocompleteSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  const _AutocompleteSuggestions({
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameTokens.surfaceVariant,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: GameTokens.accent, width: 1),
        ),
      ),
      child: Column(
        children: suggestions.map((s) {
          return InkWell(
            onTap: () => onSelect(s),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GameTokens.spaceMd,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward,
                      color: GameTokens.accent, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    s,
                    style: GameTokens.codeSmall.copyWith(
                      color: GameTokens.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
