import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../gameplay_provider.dart';

class FlutterBlockWorkspace extends ConsumerStatefulWidget {
  const FlutterBlockWorkspace({super.key});

  @override
  ConsumerState<FlutterBlockWorkspace> createState() => _FlutterBlockWorkspaceState();
}

class _FlutterBlockWorkspaceState extends ConsumerState<FlutterBlockWorkspace> {
  static const _allClauses = [
    _ClauseType.select,
    _ClauseType.from,
    _ClauseType.where,
    _ClauseType.join,
    _ClauseType.groupBy,
    _ClauseType.orderBy,
    _ClauseType.limit,
  ];

  final List<_ClausePair> _query = [];

  void _addClause(_ClauseType type) {
    setState(() {
      if ((type == _ClauseType.select || type == _ClauseType.from) &&
          _query.any((c) => c.type == type)) { return; }
      _query.add(_ClausePair(type: type, value: ''));
    });
    final idx = _query.lastIndexWhere((c) => c.type == type);
    _editClause(idx);
  }

  Future<void> _editClause(int index) async {
    if (index < 0 || index >= _query.length) return;
    final clause = _query[index];
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GameInputSheet(
        keyword: clause.type.keyword,
        initialValue: clause.value,
        hint: clause.type.hint,
      ),
    );
    if (result != null) {
      setState(() { _query[index] = _ClausePair(type: clause.type, value: result); });
      _rebuildQuery();
    }
  }

  void _removeClause(int index) {
    setState(() { _query.removeAt(index); });
    _rebuildQuery();
  }

  void _rebuildQuery() {
    final sorted = List<_ClausePair>.from(_query)
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
    final parts = sorted.map((c) {
      final v = c.value.trim();
      return v.isNotEmpty ? ' ' : c.type.keyword;
    }).toList();
    ref.read(gameplayProvider.notifier).updateQuery(parts.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _QueryBuildArea(
            query: _query,
            onEdit: _editClause,
            onRemove: _removeClause,
          ),
        ),
        _ClausePalette(allClauses: _allClauses, onAdd: _addClause),
      ],
    );
  }
}

// ─── Game-styled input bottom sheet ─────────────────────────────────────────

class _GameInputSheet extends StatefulWidget {
  final String keyword;
  final String initialValue;
  final String hint;
  const _GameInputSheet({required this.keyword, required this.initialValue, required this.hint});
  @override
  State<_GameInputSheet> createState() => _GameInputSheetState();
}

class _GameInputSheetState extends State<_GameInputSheet> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  void _submit() => Navigator.pop(context, _ctrl.text.trim());
  void _cancel() => Navigator.pop(context, null);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final color = _colorFor(widget.keyword);
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEFE6D5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: Color(0xFF8B5A2B), width: 3),
            left: BorderSide(color: Color(0xFF8B5A2B), width: 2),
            right: BorderSide(color: Color(0xFF8B5A2B), width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFD4C4A8), borderRadius: BorderRadius.circular(2)),
            )),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                child: Text(widget.keyword, style: GoogleFonts.nunitoSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Text('Define value', style: GoogleFonts.cinzel(color: const Color(0xFF3D2817), fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              focusNode: _focus,
              autofocus: true,
              style: GoogleFonts.sourceCodePro(color: const Color(0xFF2A180E), fontSize: 17, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.sourceCodePro(color: const Color(0xFF9E8B75), fontSize: 15),
                filled: true,
                fillColor: const Color(0xFFFAF7F0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4C4A8), width: 2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4C4A8), width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: _cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5A2B),
                  side: const BorderSide(color: Color(0xFF8B5A2B)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('CANCEL', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  foregroundColor: const Color(0xFFEFE6D5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                ),
                child: Text('✓  CONFIRM', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold, fontSize: 15)),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

Color _colorFor(String keyword) {
  switch (keyword.toUpperCase()) {
    case 'SELECT': return const Color(0xFF4A7C59);
    case 'FROM': return const Color(0xFFD48B3E);
    case 'WHERE': return const Color(0xFFB55A30);
    case 'JOIN': case 'INNER JOIN': case 'LEFT JOIN': return const Color(0xFF8B5A2B);
    case 'GROUP BY': return const Color(0xFF5A7C8A);
    case 'ORDER BY': return const Color(0xFF6B8E23);
    case 'LIMIT': return const Color(0xFF8F9779);
    default: return const Color(0xFF8B5A2B);
  }
}

// ─── Query build area ─────────────────────────────────────────────────────────

class _QueryBuildArea extends StatelessWidget {
  final List<_ClausePair> query;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  const _QueryBuildArea({required this.query, required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final sorted = List<_ClausePair>.from(query)
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));

    if (sorted.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.arrow_downward, color: Color(0xFFD4C4A8), size: 32),
        const SizedBox(height: 8),
        Text('Tap a block below\nto build your query',
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(color: const Color(0xFFD4C4A8), fontSize: 14)),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final clause = sorted[i];
        final origIdx = query.lastIndexWhere((c) => c.type == clause.type && c.value == clause.value);
        return _ClauseBlock(clause: clause, onTap: () => onEdit(origIdx), onDelete: () => onRemove(origIdx));
      },
    );
  }
}

class _ClauseBlock extends StatelessWidget {
  final _ClausePair clause;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ClauseBlock({required this.clause, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(clause.type.keyword);
    final hasValue = clause.value.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFE6D5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasValue ? color : const Color(0xFFD4C4A8), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            ),
            child: Text(clause.type.keyword, style: GoogleFonts.nunitoSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                hasValue ? clause.value : 'tap to define...',
                style: GoogleFonts.sourceCodePro(
                  color: hasValue ? const Color(0xFF2A180E) : const Color(0xFFB0A090),
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                  fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: const Color(0xFFB55A30),
            onPressed: onDelete,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
        ]),
      ),
    );
  }
}

// ─── Palette ──────────────────────────────────────────────────────────────────

class _ClausePalette extends StatelessWidget {
  final List<_ClauseType> allClauses;
  final ValueChanged<_ClauseType> onAdd;

  const _ClausePalette({required this.allClauses, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF3D2817),
        border: Border(top: BorderSide(color: Color(0xFF5C3D2E), width: 2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: allClauses.map((t) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onAdd(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _colorFor(t.keyword),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Text(t.keyword, style: GoogleFonts.nunitoSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

enum _ClauseType {
  select('SELECT', 0, 'e.g.  *  or  name, age'),
  from('FROM', 1, 'table name, e.g. users'),
  join('JOIN', 2, 'table ON condition'),
  where('WHERE', 3, 'condition, e.g. age > 18'),
  groupBy('GROUP BY', 4, 'column(s), e.g. department'),
  orderBy('ORDER BY', 5, 'column ASC/DESC'),
  limit('LIMIT', 6, 'number, e.g. 10');

  final String keyword;
  final int sortOrder;
  final String hint;
  const _ClauseType(this.keyword, this.sortOrder, this.hint);
}

class _ClausePair {
  final _ClauseType type;
  final String value;
  const _ClausePair({required this.type, required this.value});
}
