import 'package:flutter/material.dart';
import '../../theming/tokens/game_tokens.dart';

/// Blinking block cursor for terminal emulation
class BlinkingCursor extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;

  const BlinkingCursor({
    super.key,
    this.width = 8,
    this.height = 16,
    this.color,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GameTokens.cursorBlinkDuration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _controller.value > 0.5 ? 1.0 : 0.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            color: widget.color ?? GameTokens.accent,
          ),
        );
      },
    );
  }
}

/// A stylized separator with an optional label.
class GameDivider extends StatelessWidget {
  final String? label;

  const GameDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(
        height: 2,
        color: GameTokens.surfaceVariant,
      );
    }
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: GameTokens.surfaceVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceSm),
          child: Text(label!, style: GameTokens.bodySmall),
        ),
        Expanded(child: Container(height: 2, color: GameTokens.surfaceVariant)),
      ],
    );
  }
}

/// A highly stylized App Bar for the game
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const GameAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameTokens.background,
        border: Border(
          bottom: BorderSide(
            color: GameTokens.surfaceHighlight,
            width: 2.0,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: GameTokens.primaryText, size: 28),
                  onPressed: onBack,
                )
              else
                const SizedBox(width: GameTokens.spaceMd),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GameTokens.displayMedium.copyWith(
                    color: GameTokens.primaryText,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}

/// Stylized progress bar for XP or health
class GameProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String? label;
  final Color? color;

  const GameProgressBar({
    super.key,
    required this.value,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(label!.toUpperCase(), style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
        if (label != null) const SizedBox(height: GameTokens.spaceXs),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: GameTokens.surfaceVariant,
            borderRadius: GameTokens.borderRadiusSm, // Slight rounding
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? GameTokens.accent,
                borderRadius: GameTokens.borderRadiusSm,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Star row widget (3 stars + optional time medal).
class StarRow extends StatelessWidget {
  final int starCount;
  final bool showTimeMedal;
  final String? medalLabel;
  final Color? filledColor;
  final Color? unfilledColor;

  const StarRow({
    super.key,
    required this.starCount,
    this.showTimeMedal = false,
    this.medalLabel,
    this.filledColor,
    this.unfilledColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              i < starCount ? Icons.star_rounded : Icons.star_border_rounded,
              color: i < starCount
                  ? (filledColor ?? GameTokens.accent)
                  : (unfilledColor ?? GameTokens.surfaceHighlight),
              size: 24,
            ),
          ),
        if (showTimeMedal && medalLabel != null) ...[
          const SizedBox(width: GameTokens.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GameTokens.warningSurface,
              border: Border.all(color: GameTokens.warning, width: 2),
              borderRadius: GameTokens.borderRadiusSm,
            ),
            child: Text(
              medalLabel!.toUpperCase(),
              style: GameTokens.labelLarge.copyWith(
                color: GameTokens.warning,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
