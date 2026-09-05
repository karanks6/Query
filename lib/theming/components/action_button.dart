import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/game_tokens.dart';
import 'slanted_panel.dart'; // Reusing the clipper

/// ActionButton Material (Stylized).
/// 
/// A sharp, angled button with solid fills and dynamic hover/press states.
class ActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary; 
  final EdgeInsetsGeometry padding;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isPrimary = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    // Determine colors based on state
    Color baseColor;
    Color textColor;
    
    if (isDisabled) {
      baseColor = GameTokens.surfaceVariant;
      textColor = GameTokens.disabledText;
    } else if (widget.isPrimary) {
      baseColor = _isHovered ? GameTokens.accentDim : GameTokens.accent;
      textColor = GameTokens.background;
    } else {
      baseColor = _isHovered ? GameTokens.surfaceHighlight : GameTokens.surfaceVariant;
      textColor = GameTokens.primaryText;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: GameTokens.durationFast,
          curve: Curves.easeOutQuad,
          child: AnimatedContainer(
            duration: GameTokens.durationFast,
            // Subtle translation on hover for a dynamic feel
            transform: Matrix4.translationValues(_isHovered && !isDisabled ? 4.0 : 0.0, 0.0, 0.0),
            child: CustomPaint(
              painter: SlantedBorderPainter(
                clipSize: 12.0,
                borderColor: widget.isPrimary ? GameTokens.accent : GameTokens.surfaceHighlight,
                strokeWidth: 1.5,
              ),
              child: ClipPath(
                clipper: SlantedClipper(clipSize: 12.0),
                child: AnimatedContainer(
                  duration: GameTokens.durationFast,
                  color: baseColor,
                  padding: widget.padding,
                  child: DefaultTextStyle(
                    style: GameTokens.labelLarge.copyWith(color: textColor),
                    child: widget.child,
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
