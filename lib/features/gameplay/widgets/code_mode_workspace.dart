import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../core/sandbox_engine/level_schema.dart';

/// Syntax-highlighting text editing controller for SQL queries.
/// Ensures all user-entered text is bright, crisp, and high-contrast on dark editor backgrounds.
class SqlSyntaxTextEditingController extends TextEditingController {
  SqlSyntaxTextEditingController({super.text});

  static final _tokenRegex = RegExp(
    r"(?<string>'[^'\\]*(?:\\.[^'\\]*)*'|\x22[^\x22\\]*(?:\\.[^\x22\\]*)*\x22)"
    r'|(?<comment>--[^\n]*|/\*[\s\S]*?\*/)'
    r'|(?<number>\b\d+(?:\.\d+)?\b)'
    r'|(?<keyword>\b(?:SELECT|FROM|WHERE|JOIN|INNER|LEFT|RIGHT|FULL|OUTER|CROSS|ON|GROUP\s+BY|ORDER\s+BY|HAVING|LIMIT|OFFSET|AS|AND|OR|NOT|IN|IS\s+NULL|IS\s+NOT\s+NULL|LIKE|BETWEEN|EXISTS|UNION|INTERSECT|EXCEPT|DISTINCT|INSERT|INTO|VALUES|UPDATE|SET|DELETE|CREATE|TABLE|ALTER|DROP|VIEW|WITH|CASE|WHEN|THEN|ELSE|END|ASC|DESC)\b)'
    r'|(?<function>\b(?:COUNT|SUM|AVG|MIN|MAX|UPPER|LOWER|LENGTH|ROUND|COALESCE|IFNULL|NULLIF|SUBSTR|SUBSTRING|TRIM|REPLACE|NOW|DATE|DATETIME)\b)'
    r'|(?<operator>[=><!+\-*/%]+|[;,()])'
    r'|(?<other>\S+)',
    caseSensitive: false,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ??
        GoogleFonts.firaCode(
          color: const Color(0xFFF9F5EA),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.6,
        );

    final textVal = text;
    if (textVal.isEmpty) {
      return TextSpan(style: baseStyle, text: '');
    }

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in _tokenRegex.allMatches(textVal)) {
      if (match.start > lastIndex) {
        // Plain whitespace or untokenized spaces
        spans.add(TextSpan(
          text: textVal.substring(lastIndex, match.start),
          style: baseStyle.copyWith(color: const Color(0xFFF9F5EA)),
        ));
      }

      final matchedText = match.group(0)!;
      TextStyle tokenStyle;

      if (match.namedGroup('string') != null) {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFF81C784), // Warm green for strings
          fontWeight: FontWeight.w500,
        );
      } else if (match.namedGroup('comment') != null) {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFF8D7B68), // Muted taupe for comments
          fontStyle: FontStyle.italic,
        );
      } else if (match.namedGroup('number') != null) {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFFFF8A65), // Coral for numbers
          fontWeight: FontWeight.w600,
        );
      } else if (match.namedGroup('keyword') != null) {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFFFFC04D), // Vibrant gold for SQL keywords
          fontWeight: FontWeight.bold,
        );
      } else if (match.namedGroup('function') != null) {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFF64B5F6), // Sky blue for SQL functions
          fontWeight: FontWeight.bold,
        );
      } else if (match.namedGroup('operator') != null) {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFFD4C4A8), // Parchment beige for operators
        );
      } else {
        tokenStyle = baseStyle.copyWith(
          color: const Color(0xFFF9F5EA), // Crisp bright ivory for user input & identifiers
          fontWeight: FontWeight.w500,
        );
      }

      spans.add(TextSpan(text: matchedText, style: tokenStyle));
      lastIndex = match.end;
    }

    if (lastIndex < textVal.length) {
      spans.add(TextSpan(
        text: textVal.substring(lastIndex),
        style: baseStyle.copyWith(color: const Color(0xFFF9F5EA)),
      ));
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}

/// Code Mode workspace (Section 3.1).
///
/// A real text editor with:
/// - High-contrast text & real-time SQL syntax highlighting
/// - Schema-aware autocomplete suggestions
/// - Blinking block cursor (Terminal theme signature element)
/// - Synchronized line numbers
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
  late SqlSyntaxTextEditingController _controller;
  late FocusNode _focusNode;
  late ScrollController _editorScrollController;
  late ScrollController _lineNumbersScrollController;
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
    _controller = SqlSyntaxTextEditingController(text: widget.currentQuery);
    _focusNode = FocusNode();
    _editorScrollController = ScrollController();
    _lineNumbersScrollController = ScrollController();

    _editorScrollController.addListener(() {
      if (_lineNumbersScrollController.hasClients) {
        _lineNumbersScrollController.jumpTo(_editorScrollController.offset);
      }
    });

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
    _editorScrollController.dispose();
    _lineNumbersScrollController.dispose();
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
      if (_showSuggestions) setState(() => _showSuggestions = false);
      return;
    }

    // Find the current word being typed
    final beforeCursor = text.substring(0, cursorPos);
    final wordMatch = RegExp(r'[\w.]+$').firstMatch(beforeCursor);
    final currentWord = wordMatch?.group(0)?.toUpperCase() ?? '';

    if (currentWord.length < 2) {
      if (_showSuggestions) setState(() => _showSuggestions = false);
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => Text(
                  '${_controller.text.split('\n').length} lines',
                  style: GameTokens.bodySmall.copyWith(
                    color: GameTokens.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Editor + suggestions overlay
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1008),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF4A7C59), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Code editor with synchronized line numbers
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Line numbers
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) => _LineNumbers(
                        text: _controller.text,
                        scrollController: _lineNumbersScrollController,
                      ),
                    ),

                    // Text field
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _focusNode.requestFocus(),
                        behavior: HitTestBehavior.opaque,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          scrollController: _editorScrollController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: GoogleFonts.firaCode(
                            color: const Color(0xFFF9F5EA),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                          cursorColor: const Color(0xFFFFC04D),
                          cursorWidth: 8,
                          cursorHeight: 18,
                          decoration: InputDecoration(
                            hintText: 'Enter your SQL query here...',
                            hintStyle: GoogleFonts.firaCode(
                              color: const Color(0xFF8C7A6B),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.all(GameTokens.spaceSm),
                            isDense: true,
                            filled: false,
                          ),
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
        ),
      ],
    );
  }
}

class _LineNumbers extends StatelessWidget {
  final String text;
  final ScrollController? scrollController;

  const _LineNumbers({
    required this.text,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final lineCount = '\n'.allMatches(text).length + 1;
    return Container(
      width: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF160D07),
        border: Border(
          right: BorderSide(color: Color(0xFF3D2817), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: GameTokens.spaceSm,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            lineCount,
            (i) => SizedBox(
              height: 24.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${i + 1}',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF8C7A6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF2A180E),
        border: Border(
          top: BorderSide(color: GameTokens.accent, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                      color: GameTokens.accent, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    s,
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFFF9F5EA),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
