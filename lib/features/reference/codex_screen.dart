import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../gameplay/widgets/parallax_background.dart';

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
      });

      if (widget.initialErrorId != null && _errors.isNotEmpty) {
        // Find and maybe expand or scroll to it (advanced UX, skipping for now)
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredErrors = _errors.where((err) {
      final text = (err['title'] + err['description'] + err['keywords'].join(' ')).toLowerCase();
      return text.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: AppBar(
        backgroundColor: GameTokens.surface,
        title: const Text('SQL Error Codex', style: TextStyle(fontFamily: 'FiraCode', color: GameTokens.accent)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GameTokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ParallaxBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: GameTokens.accent))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      style: const TextStyle(color: GameTokens.primaryText),
                      decoration: InputDecoration(
                        isDense: true,
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: GameTokens.accent)),
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
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredErrors.length,
                      itemBuilder: (context, index) {
                        final error = filteredErrors[index];
                        final isHighlighted = error['id'] == widget.initialErrorId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SlantedPanel(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.error_outline, color: GameTokens.warning, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        error['title'],
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
                                  error['description'],
                                  style: const TextStyle(color: GameTokens.primaryText, fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                _buildCodeSnippet('Bad Example', error['bad_example'], Colors.redAccent),
                                const SizedBox(height: 8),
                                _buildCodeSnippet('Good Example', error['good_example'], Colors.greenAccent),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
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
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(code, style: const TextStyle(color: GameTokens.primaryText, fontFamily: 'FiraCode', fontSize: 13)),
        ],
      ),
    );
  }
}
