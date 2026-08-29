import 'package:flutter/material.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';

/// Blinking block cursor â€” the Terminal/Classic theme's signature element.
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
      duration: TerminalClassicTokens.cursorBlinkDuration,
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
            color: widget.color ?? TerminalClassicTokens.accent,
          ),
        );
      },
    );
  }
}

/// Terminal-style button with [ BRACKETED ] text treatment.
class TerminalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDanger;
  final bool isLoading;
  final Widget? icon;

  const TerminalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isDanger = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDanger
        ? TerminalClassicTokens.error
        : isPrimary
            ? TerminalClassicTokens.accent
            : TerminalClassicTokens.accentDim;
    final textColor = isDanger
        ? TerminalClassicTokens.error
        : isPrimary
            ? TerminalClassicTokens.accent
            : TerminalClassicTokens.secondaryText;
    final bgColor = isPrimary
        ? TerminalClassicTokens.accentDim.withValues(alpha: 0.2)
        : Colors.transparent;

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: TerminalClassicTokens.borderRadiusSm,
      child: AnimatedContainer(
        duration: TerminalClassicTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: TerminalClassicTokens.spaceLg,
          vertical: TerminalClassicTokens.spaceSm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: TerminalClassicTokens.borderRadiusSm,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(textColor),
                ),
              )
            else if (icon != null) ...[
              icon!,
              const SizedBox(width: TerminalClassicTokens.spaceSm),
            ],
            Text(
              '[ $label ]',
              style: TerminalClassicTokens.labelLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green accent separator with optional label.
class TerminalDivider extends StatelessWidget {
  final String? label;

  const TerminalDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(
        height: 1,
        color: TerminalClassicTokens.accentDim,
      );
    }
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: TerminalClassicTokens.accentDim)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TerminalClassicTokens.spaceSm),
          child: Text(label!, style: TerminalClassicTokens.bodySmall),
        ),
        Expanded(child: Container(height: 1, color: TerminalClassicTokens.accentDim)),
      ],
    );
  }
}

/// Terminal-style card with border.
class TerminalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const TerminalCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding ?? const EdgeInsets.all(TerminalClassicTokens.spaceMd),
      decoration: BoxDecoration(
        color: TerminalClassicTokens.surface,
        borderRadius: TerminalClassicTokens.borderRadiusSm,
        border: Border.all(
          color: borderColor ?? TerminalClassicTokens.accentDim,
          width: 1,
        ),
        boxShadow: shadows ?? TerminalClassicTokens.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: TerminalClassicTokens.borderRadiusSm,
        child: container,
      );
    }
    return container;
  }
}

/// XP and star progress bar in Terminal style.
class TerminalProgressBar extends StatelessWidget {
  final double value; // 0.0â€“1.0
  final String? label;
  final Color? color;

  const TerminalProgressBar({
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
          Text(label!, style: TerminalClassicTokens.bodySmall),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: TerminalClassicTokens.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? TerminalClassicTokens.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? TerminalClassicTokens.accent).withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
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

  const StarRow({
    super.key,
    required this.starCount,
    this.showTimeMedal = false,
    this.medalLabel,
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
                  ? TerminalClassicTokens.accent
                  : TerminalClassicTokens.accentDim,
              size: 20,
            ),
          ),
        if (showTimeMedal && medalLabel != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: TerminalClassicTokens.warning, width: 1),
              borderRadius: TerminalClassicTokens.borderRadiusSm,
            ),
            child: Text(
              medalLabel!,
              style: TerminalClassicTokens.bodySmall.copyWith(
                color: TerminalClassicTokens.warning,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
