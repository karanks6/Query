import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/sci_fi_tokens.dart';

/// Holopanel Material (Section 2.2).
/// 
/// Translates the URP unlit-lit hybrid Shader Graph material to Flutter.
/// Provides a blurred glass core and an emissive edge (Fresnel).
class HoloPanel extends StatelessWidget {
  final Widget child;
  final double emissionIntensity; // 0.0 to 1.0 (Section 2.2 budget)
  final Color? colorOverride;
  final Color? borderColorOverride;
  final Color? glowColorOverride;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool interactive; // If true, reacts to hover/focus

  const HoloPanel({
    super.key,
    required this.child,
    this.emissionIntensity = 0.5,
    this.colorOverride,
    this.borderColorOverride,
    this.glowColorOverride,
    this.padding,
    this.borderRadius,
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = colorOverride ?? SciFiTokens.surface;
    final edgeColor = (borderColorOverride ?? SciFiTokens.accent).withValues(alpha: emissionIntensity);
    final glowColor = (glowColorOverride ?? SciFiTokens.accentGlow).withValues(alpha: emissionIntensity);
    
    final radius = borderRadius ?? SciFiTokens.borderRadiusMd;

    // The layered composite to mimic the shader:
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: emissionIntensity > 0 
          ? [BoxShadow(color: glowColor, blurRadius: 15 * emissionIntensity, spreadRadius: 2 * emissionIntensity)]
          : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.6), // transparent core
              borderRadius: radius,
              border: Border.all(
                color: edgeColor,
                width: 1.0,
              ),
              // Simulating inner fresnel glow
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 2.0,
                colors: [
                  edgeColor.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
