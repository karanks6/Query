import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../gameplay_provider.dart';
import '../../../main.dart'; // for navigatorKey

// SQL clause types available in the palette
enum _ClauseType {
  select('SELECT', 0, 'e.g.  *  or  name, age', Color(0xFF4A7C59)),
  from('FROM', 1, 'table name, e.g.  catalog', Color(0xFFD48B3E)),
  where('WHERE', 3, 'condition, e.g.  age > 18', Color(0xFFB55A30)),
  join('JOIN', 2, 'table ON condition', Color(0xFF8B5A2B)),
  groupBy('GROUP BY', 4, 'column, e.g.  department', Color(0xFF5A7C8A)),
  orderBy('ORDER BY', 5, 'column ASC/DESC', Color(0xFF6B8E23)),
  limit('LIMIT', 6, 'number, e.g.  10', Color(0xFF8F9779));

  final String keyword;
  final int sortOrder;
  final String hint;
  final Color color;
  const _ClauseType(this.keyword, this.sortOrder, this.hint, this.color);
}

class _ClausePair {
  final _ClauseType type;
  final String value;
  const _ClausePair({required this.type, required this.value});
  _ClausePair withValue(String v) => _ClausePair(type: type, value: v);
}

/// Flutter-native SQL block builder rendered inside the gameplay overlay.
/// Clause chips at the bottom; assembled query shown above.
/// Tapping a chip (or placed block) opens an input sheet via the root Navigator.
class FlutterBlockWorkspace extends ConsumerStatefulWidget {
  const FlutterBlockWorkspace({super.key});

  @override
  ConsumerState<FlutterBlockWorkspace> createState() =>
      _FlutterBlockWorkspaceState();
}

class _FlutterBlockWorkspaceState
    extends ConsumerState<FlutterBlockWorkspace> {
  static const _palette = _ClauseType.values;
  final List<_ClausePair> _placed = [];

  // ── Clause management ──────────────────────────────────────────────────────

  Future<void> _tapChip(_ClauseType type) async {
    // SELECT and FROM may only appear once; tap again to edit existing.
    final existingIdx = (type == _ClauseType.select || type == _ClauseType.from)
        ? _placed.indexWhere((c) => c.type == type)
        : -1;

    if (existingIdx >= 0) {
      await _editAt(existingIdx);
    } else {
      final value = await _askValue(type);
      if (value != null) {
        setState(() => _placed.add(_ClausePair(type: type, value: value)));
        _push();
      }
    }
  }

  Future<void> _editAt(int i) async {
    final value = await _askValue(_placed[i].type, initial: _placed[i].value);
    if (value != null) {
      setState(() => _placed[i] = _placed[i].withValue(value));
      _push();
    }
  }

  void _removeAt(int i) {
    setState(() => _placed.removeAt(i));
    _push();
  }

  // ── Open game-styled input sheet via root Navigator ────────────────────────

  Future<String?> _askValue(_ClauseType type, {String initial = ''}) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return Future.value(null);
    return showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InputSheet(type: type, initial: initial),
    );
  }

  // ── Sync query string to provider ─────────────────────────────────────────

  void _push() {
    final ordered = List.of(_placed)
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
    final sql = ordered.map((c) {
      final v = c.value.trim();
      return v.isEmpty ? c.type.keyword : '${c.type.keyword} $v';
    }).join('\n');
    ref.read(gameplayProvider.notifier).updateQuery(sql);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ordered = List.of(_placed)
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1008).withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(color: Color(0xFF5C3D2E), width: 2),
        ),
      ),
      child: Column(
        children: [
          // ── Built clauses area ───────────────────────────────────────────
          Expanded(
            child: ordered.isEmpty
                ? _emptyHint()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    itemCount: ordered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final clause = ordered[i];
                      final origIdx = _placed.lastIndexWhere(
                          (c) => c.type == clause.type && c.value == clause.value);
                      return _PlacedBlock(
                        clause: clause,
                        onTap: () => _editAt(origIdx),
                        onDelete: () => _removeAt(origIdx),
                      );
                    },
                  ),
          ),

          // ── Clause palette ───────────────────────────────────────────────
          _Palette(types: _palette, onTap: _tapChip),
        ],
      ),
    );
  }

  Widget _emptyHint() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swipe_up_rounded,
                color: Color(0xFF7A6A5A), size: 36),
            const SizedBox(height: 8),
            Text(
              'Tap a keyword below\nto build your SQL query',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                color: const Color(0xFF9A8A7A),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
}

// ─── Placed clause block ───────────────────────────────────────────────────────

class _PlacedBlock extends StatelessWidget {
  final _ClausePair clause;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlacedBlock(
      {required this.clause, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = clause.type.color;
    final hasVal = clause.value.trim().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFE6D5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasVal ? c : const Color(0xFFD4C4A8), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          // Coloured keyword tab
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            ),
            child: Text(clause.type.keyword,
                style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ),
          // Value text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                hasVal ? clause.value : 'tap to set value…',
                style: GoogleFonts.sourceCodePro(
                  color: hasVal
                      ? const Color(0xFF2A180E)
                      : const Color(0xFFAA9888),
                  fontSize: 13,
                  fontWeight:
                      hasVal ? FontWeight.w600 : FontWeight.normal,
                  fontStyle:
                      hasVal ? FontStyle.normal : FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Remove button
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: const Color(0xFFB55A30),
            onPressed: onDelete,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
        ]),
      ),
    );
  }
}

// ─── Palette of keyword chips ──────────────────────────────────────────────────

class _Palette extends StatelessWidget {
  final List<_ClauseType> types;
  final Future<void> Function(_ClauseType) onTap;

  const _Palette({required this.types, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF2A1A0C),
        border: Border(top: BorderSide(color: Color(0xFF5C3D2E), width: 2)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: types
            .map((t) => GestureDetector(
                  onTap: () => onTap(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: t.color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Text(
                      t.keyword,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Game-styled text input sheet ─────────────────────────────────────────────

class _InputSheet extends StatefulWidget {
  final _ClauseType type;
  final String initial;
  const _InputSheet({required this.type, required this.initial});
  @override
  State<_InputSheet> createState() => _InputSheetState();
}

class _InputSheetState extends State<_InputSheet> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
    _focus = FocusNode();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.pop(context, _ctrl.text.trim());
  void _cancel() => Navigator.pop(context, null);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final c = widget.type.color;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFE6D5),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: c, width: 3),
            left: BorderSide(color: c.withValues(alpha: 0.5), width: 2),
            right: BorderSide(color: c.withValues(alpha: 0.5), width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFD4C4A8),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Title row
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: c, borderRadius: BorderRadius.circular(6)),
                child: Text(widget.type.keyword,
                    style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Text('Set value',
                  style: GoogleFonts.cinzel(
                      color: const Color(0xFF3D2817),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Text(
              widget.type.hint,
              style: GoogleFonts.quicksand(
                  color: const Color(0xFF8B7055), fontSize: 13),
            ),
            const SizedBox(height: 14),
            // Input field
            TextField(
              controller: _ctrl,
              focusNode: _focus,
              autofocus: true,
              style: GoogleFonts.sourceCodePro(
                  color: const Color(0xFF2A180E),
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.type.hint,
                hintStyle: GoogleFonts.sourceCodePro(
                    color: const Color(0xFF9E8B75), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFFAF7F0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFD4C4A8), width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFD4C4A8), width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: c, width: 2)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5A2B),
                    side: const BorderSide(color: Color(0xFF8B5A2B)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('CANCEL',
                      style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  child: Text('CONFIRM',
                      style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
