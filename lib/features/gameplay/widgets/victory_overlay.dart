import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theming/tokens/game_tokens.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/scoring/level_scorer.dart';
import '../../../game/query_game.dart';
import '../../../game/scenes/victory_scene.dart';
import '../gameplay_provider.dart';

/// Unity-engine-style Level Cleared / Victory Overlay.
///
/// Features:
/// - Embossed game modal with golden bevel trim and mahogany gradient
/// - 3D Star podium presentation with glow and bounce animations
/// - Query Output Table showing columns, formatted values, row numbers, and scrollability
/// - Reward & acorns breakdown panel
/// - Proportionate, responsive action buttons with clear visual hierarchy
class VictoryOverlay extends ConsumerStatefulWidget {
  final QueryGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  ConsumerState<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends ConsumerState<VictoryOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider).playCelebration();
    });
  }

  VictoryScene? _resolveVictoryScene() {
    if (widget.game.sceneStack.isNotEmpty && widget.game.sceneStack.last is VictoryScene) {
      return widget.game.sceneStack.last as VictoryScene;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final victoryScene = _resolveVictoryScene();
    final state = ref.watch(gameplayProvider);
    final level = victoryScene?.level ?? state.level;

    if (level == null) {
      return const SizedBox.shrink();
    }

    final score = victoryScene?.state.levelScore ?? state.levelScore ?? const LevelScore.zero();
    final starCount = score.starCount.clamp(1, 3);

    // Resolve output rows: prioritize last executed report rows, fallback to level expectedResult
    final outputRows = (victoryScene?.state.lastReport?.resultRows ?? state.lastReport?.resultRows) ?? level.expectedResult;
    final columnNames = outputRows.isNotEmpty ? outputRows.first.keys.toList() : <String>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 680;
            final modalMaxHeight = (constraints.maxHeight * 0.94).clamp(420.0, 760.0);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: modalMaxHeight,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3B2518), // Deep warm mahogany
                        Color(0xFF28170F), // Dark wood core
                        Color(0xFF1B0E08), // Obsidian root
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE59B28), // Golden bevel
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.75),
                        blurRadius: 30,
                        spreadRadius: 6,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFFE59B28).withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // Subtle golden corner accents
                        Positioned(
                          top: -20,
                          left: -20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE59B28).withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE59B28).withValues(alpha: 0.15),
                            ),
                          ),
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── 1. Top Header Banner ──────────────────────────────────
                              _buildHeaderBanner(level.title, isSmallScreen),

                              SizedBox(height: isSmallScreen ? 6 : 10),

                              // ── 2. Stars Podium ──────────────────────────────────────
                              _buildStarsPodium(starCount, isSmallScreen),

                              SizedBox(height: isSmallScreen ? 6 : 10),

                              // ── 3. Reward & Acorn Pill ───────────────────────────────
                              _buildRewardStrip(score, isSmallScreen),

                              SizedBox(height: isSmallScreen ? 8 : 12),

                              // ── 4. Query Result Ledger (Expanded / Flexible) ─────────
                              Expanded(
                                child: _buildQueryResultLedger(
                                  outputRows: outputRows,
                                  columns: columnNames,
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 10 : 14),

                              // ── 5. Action Buttons (Map, Replay, Next) ────────────────
                              _buildActionButtons(victoryScene, isSmallScreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header Banner ─────────────────────────────────────────────────────────────
  Widget _buildHeaderBanner(String levelTitle, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5A391D),
                Color(0xFF7A4E26),
                Color(0xFF5A391D),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE59B28).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'TRAIL CLEARED',
            style: GoogleFonts.nunitoSans(
              color: const Color(0xFFFFF9EC),
              fontSize: isSmallScreen ? 20 : 23,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              shadows: const [
                Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 4),
        Text(
          levelTitle.toUpperCase(),
          style: GoogleFonts.quicksand(
            color: const Color(0xFFD4B088),
            fontSize: isSmallScreen ? 11 : 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── 3D Star Ceremony ──────────────────────────────────────────────────────────
  Widget _buildStarsPodium(int starCount, bool isSmallScreen) {
    final starSizes = isSmallScreen ? [34.0, 42.0, 34.0] : [38.0, 48.0, 38.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        final isEarned = index < starCount;
        final size = starSizes[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: size,
                color: isEarned ? const Color(0xFFFFB300) : const Color(0xFF503B2B),
                shadows: isEarned
                    ? [
                        Shadow(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.8),
                          blurRadius: 16,
                        ),
                        const Shadow(
                          color: Color(0xFF7A4A00),
                          offset: Offset(0, 3),
                          blurRadius: 4,
                        ),
                      ]
                    : [
                        const Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
              )
                  .animate(target: isEarned ? 1 : 0)
                  .scale(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 150 + index * 120),
                    curve: Curves.elasticOut,
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                  )
                  .shimmer(delay: 700.ms, duration: 1200.ms),
            ],
          ),
        );
      }),
    );
  }

  // ── Rewards Strip ─────────────────────────────────────────────────────────────
  Widget _buildRewardStrip(LevelScore score, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F120A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6B4527), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: Color(0xFF81C784), size: 18),
              const SizedBox(width: 6),
              Text(
                '+${score.xpEarned} ACORNS EARNED',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFFFFF2D6),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4A7C59).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF4A7C59), width: 1),
            ),
            child: Text(
              '${score.starCount} / 3 STARS',
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFFA5D6A7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Query Result Table Ledger ─────────────────────────────────────────────────
  Widget _buildQueryResultLedger({
    required List<Map<String, dynamic>> outputRows,
    required List<String> columns,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EC), // Elegant Parchment background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4B088), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ledger Header Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: Color(0xFF4A301E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded, size: 15, color: Color(0xFFFFD54F)),
                const SizedBox(width: 6),
                Text(
                  'QUERY OUTPUT',
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFFFFEDB3),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1B10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${outputRows.length} ${outputRows.length == 1 ? 'row' : 'rows'}',
                    style: GoogleFonts.quicksand(
                      color: const Color(0xFFE8C89A),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Table Area
          Expanded(
            child: outputRows.isEmpty || columns.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Query executed successfully.\n(0 rows returned)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFF6E5642),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: const Color(0xFFDFCEB5),
                          ),
                          child: DataTable(
                            headingRowHeight: 28,
                            dataRowMinHeight: 26,
                            dataRowMaxHeight: 32,
                            horizontalMargin: 10,
                            columnSpacing: 14,
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFEBE0CD)),
                            columns: [
                              // Row index column header
                              const DataColumn(
                                label: Text(
                                  '#',
                                  style: TextStyle(
                                    color: Color(0xFF7A5739),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              // Table column headers
                              ...columns.map(
                                (col) => DataColumn(
                                  label: Text(
                                    col,
                                    style: const TextStyle(
                                      color: Color(0xFF2E5738), // Forest green headers
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: outputRows.asMap().entries.map((entry) {
                              final index = entry.key;
                              final row = entry.value;
                              final isEven = index % 2 == 0;

                              return DataRow(
                                color: WidgetStateProperty.all(
                                  isEven ? const Color(0xFFFAF6EC) : const Color(0xFFF3EAD7),
                                ),
                                cells: [
                                  // Row index cell
                                  DataCell(
                                    Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFF9E846A),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Column value cells
                                  ...columns.map((colName) {
                                    final val = row[colName];
                                    final isNull = val == null;

                                    return DataCell(
                                      Text(
                                        _formatCellValue(val),
                                        style: TextStyle(
                                          color: isNull ? const Color(0xFF9C8A79) : const Color(0xFF2A180E),
                                          fontSize: 11,
                                          fontWeight: isNull ? FontWeight.normal : FontWeight.w600,
                                          fontStyle: isNull ? FontStyle.italic : FontStyle.normal,
                                          fontFamily: GameTokens.codeSmall.fontFamily,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────────
  Widget _buildActionButtons(VictoryScene? victoryScene, bool isSmallScreen) {
    return Row(
      children: [
        // ── MAP BUTTON ───────────────────
        _buildWoodButton(
          label: 'MAP',
          icon: Icons.map_outlined,
          width: isSmallScreen ? 75 : 85,
          height: isSmallScreen ? 44 : 48,
          onTap: () {
            ref.read(audioControllerProvider).playSfx('ui_click.wav');
            victoryScene?.onMap();
          },
        ),

        const SizedBox(width: 8),

        // ── REPLAY BUTTON ────────────────
        _buildWoodButton(
          label: 'REPLAY',
          icon: Icons.replay_rounded,
          width: isSmallScreen ? 88 : 98,
          height: isSmallScreen ? 44 : 48,
          onTap: () {
            ref.read(audioControllerProvider).playSfx('ui_click.wav');
            victoryScene?.onReplay();
          },
        ),

        const SizedBox(width: 8),

        // ── NEXT LEVEL BUTTON (Primary CTA)
        Expanded(
          child: _buildPrimaryNextButton(
            height: isSmallScreen ? 44 : 48,
            onTap: () {
              ref.read(audioControllerProvider).playSfx('ui_click.wav');
              victoryScene?.onNextLevel();
            },
          ),
        ),
      ],
    );
  }

  // ── Wood/Stone Secondary Button ───────────────────────────────────────────────
  Widget _buildWoodButton({
    required String label,
    required IconData icon,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4E3524),
                Color(0xFF332014),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7A5439), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFFE5C8A7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFFFFF2D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Primary Next Level Button ─────────────────────────────────────────────────
  Widget _buildPrimaryNextButton({
    required double height,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF439257), // Vibrant Emerald top
                Color(0xFF2E6B3E), // Forest green core
                Color(0xFF214E2D), // Deep base
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF388E3C).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NEXT',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: const [
                    Shadow(color: Colors.black87, offset: Offset(0, 1.5), blurRadius: 3),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCellValue(dynamic value) {
    if (value == null) return 'NULL';
    if (value is double) {
      if (value == value.truncateToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }
}
