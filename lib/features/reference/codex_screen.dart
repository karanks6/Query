import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';

class CodexScreen extends StatefulWidget {
  final String? initialErrorId;
  const CodexScreen({super.key, this.initialErrorId});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  List<dynamic> _errors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  dynamic _selectedError;

  @override
  void initState() {
    super.initState();
    _loadCodex();
  }

  Future<void> _loadCodex() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/reference/error_codex.json');
      final Map<String, dynamic> data = json.decode(jsonStr);
      setState(() {
        _errors = data['errors'] ?? [];
        _isLoading = false;
        if (widget.initialErrorId != null) {
          _selectedError = _errors.firstWhere(
            (e) => e['id'] == widget.initialErrorId,
            orElse: () => null,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bug fix: guard against null fields in JSON when building the search text.
    final filteredErrors = _errors.where((err) {
      final title = (err['title'] as String?) ?? '';
      final description = (err['description'] as String?) ?? '';
      final keywords = (err['keywords'] as List<dynamic>? ?? [])
          .map((k) => k.toString())
          .join(' ');
      final text = '$title $description $keywords'.toLowerCase();
      return text.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: AppBar(
        backgroundColor: GameTokens.surface,
        title: const Text(
          'SQL Error Codex',
          style: TextStyle(fontFamily: 'FiraCode', color: GameTokens.accent),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GameTokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Bug fix: ParallaxBackground wraps a Stack which gives unbounded height
      // constraints to its children. LayoutBuilder inside an unbounded height
      // context crashes Flutter ("LayoutBuilder does not support returning
      // intrinsic dimensions"). Fix: use a separate Scaffold body without
      // ParallaxBackground for this screen, or wrap with a SizedBox.expand.
      body: Stack(
        children: [
          // Replicate the parallax background layers without the problematic wrapper
          Container(
            decoration: BoxDecoration(
              color: GameTokens.background,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  GameTokens.surfaceHighlight.withValues(alpha: 0.3),
                  GameTokens.background,
                ],
              ),
            ),
          ),
          // Foreground: constrained to screen bounds so LayoutBuilder works correctly
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: GameTokens.accent),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 720;

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildSearchBar(),
                                Expanded(
                                  child: _buildList(filteredErrors, isDesktop: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 16, right: 16),
                              child: _selectedError != null
                                  ? SlantedPanel(
                                      padding: const EdgeInsets.all(24),
                                      child: SingleChildScrollView(
                                        child: _buildErrorDetails(_selectedError),
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'Select an error to view details',
                                        style: TextStyle(
                                            color: GameTokens.secondaryText),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Mobile Layout
                    return Column(
                      children: [
                        _buildSearchBar(),
                        Expanded(
                          child: _buildList(filteredErrors, isDesktop: false),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: const TextStyle(color: GameTokens.primaryText),
        decoration: InputDecoration(
          isDense: true,
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: GameTokens.accent)),
          prefixIcon: const Icon(Icons.search, color: Colors.white30),
          filled: true,
          fillColor: GameTokens.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintText: 'Search for an error...',
          hintStyle: const TextStyle(color: Colors.white30),
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
      ),
    );
  }

  Widget _buildList(List<dynamic> filteredErrors, {required bool isDesktop}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredErrors.length,
      itemBuilder: (context, index) {
        final error = filteredErrors[index];
        final isSelected = error == _selectedError;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              if (isDesktop) {
                setState(() {
                  _selectedError = error;
                });
              } else {
                // On mobile: show detail in a modal bottom sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.75,
                    maxChildSize: 0.95,
                    minChildSize: 0.5,
                    builder: (_, scrollController) => Container(
                      decoration: BoxDecoration(
                        color: GameTokens.surface,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: _buildErrorDetails(
                          error,
                          isHighlighted: error['id'] == widget.initialErrorId,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
            child: SlantedPanel(
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: GameTokens.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (error['title'] as String?) ?? 'Unknown Error',
                            style: TextStyle(
                              color: isSelected
                                  ? GameTokens.accent
                                  : GameTokens.warning,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildErrorDetails(
                      error,
                      isHighlighted: error['id'] == widget.initialErrorId,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorDetails(dynamic error, {bool isHighlighted = false}) {
    // Bug fix: all JSON fields accessed with null-safe casts.
    final title = (error['title'] as String?) ?? 'Unknown Error';
    final description = (error['description'] as String?) ?? '';
    final badExample = (error['bad_example'] as String?) ?? '';
    final goodExample = (error['good_example'] as String?) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, color: GameTokens.warning, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isHighlighted ? GameTokens.accent : GameTokens.warning,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: GameTokens.primaryText, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildCodeSnippet('Bad Example', badExample, Colors.redAccent),
        const SizedBox(height: 8),
        _buildCodeSnippet('Good Example', goodExample, Colors.greenAccent),
      ],
    );
  }

  Widget _buildCodeSnippet(String label, String code, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            code.isEmpty ? '(no example)' : code,
            style: const TextStyle(
              fontFamily: 'FiraCode',
              color: GameTokens.primaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
