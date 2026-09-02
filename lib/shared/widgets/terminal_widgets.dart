import 'package:flutter/material.dart';
import '../../theming/tokens/sci_fi_tokens.dart';

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
      duration: SciFiTokens.cursorBlinkDuration,
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
            color: widget.color ?? SciFiTokens.accent,
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
        ? SciFiTokens.error
        : isPrimary
            ? SciFiTokens.accent
            : SciFiTokens.accentDim;
    final textColor = isDanger
        ? SciFiTokens.error
        : isPrimary
            ? SciFiTokens.accent
            : SciFiTokens.secondaryText;
    final bgColor = isPrimary
        ? SciFiTokens.accentDim.withValues(alpha: 0.2)
        : Colors.transparent;

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: SciFiTokens.borderRadiusSm,
      child: AnimatedContainer(
        duration: SciFiTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: SciFiTokens.spaceLg,
          vertical: SciFiTokens.spaceSm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: SciFiTokens.borderRadiusSm,
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
              const SizedBox(width: SciFiTokens.spaceSm),
            ],
            Text(
              '[ $label ]',
              style: SciFiTokens.labelLarge.copyWith(color: textColor),
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
        color: SciFiTokens.accentDim,
      );
    }
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: SciFiTokens.accentDim)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SciFiTokens.spaceSm),
          child: Text(label!, style: SciFiTokens.bodySmall),
        ),
        Expanded(child: Container(height: 1, color: SciFiTokens.accentDim)),
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
      padding: padding ?? const EdgeInsets.all(SciFiTokens.spaceMd),
      decoration: BoxDecoration(
        color: SciFiTokens.surface,
        borderRadius: SciFiTokens.borderRadiusSm,
        border: Border.all(
          color: borderColor ?? SciFiTokens.accentDim,
          width: 1,
        ),
        boxShadow: shadows ?? SciFiTokens.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: SciFiTokens.borderRadiusSm,
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
          Text(label!, style: SciFiTokens.bodySmall),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: SciFiTokens.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? SciFiTokens.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? SciFiTokens.accent).withValues(alpha: 0.5),
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
                  ? SciFiTokens.accent
                  : SciFiTokens.accentDim,
              size: 20,
            ),
          ),
        if (showTimeMedal && medalLabel != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: SciFiTokens.warning, width: 1),
              borderRadius: SciFiTokens.borderRadiusSm,
            ),
            child: Text(
              medalLabel!,
              style: SciFiTokens.bodySmall.copyWith(
                color: SciFiTokens.warning,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class TerminalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const TerminalAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SciFiTokens.surface,
        border: Border(
          bottom: BorderSide(
            color: SciFiTokens.accentDim,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: SciFiTokens.accent, size: 20),
                  onPressed: onBack,
                )
              else
                const SizedBox(width: SciFiTokens.spaceMd),
              Expanded(
                child: Text(
                  title,
                  style: SciFiTokens.titleLarge.copyWith(
                    color: SciFiTokens.accent,
                    letterSpacing: 2,
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
  Size get preferredSize => const Size.fromHeight(56.0);
}
