import 'package:flutter/animation.dart';

/// Centralized motion curves (Section 8.1 / 5.4).
/// 
/// The motion vocabulary for the sci-fi URP direction.
/// These curves enforce physical feel, anticipation, and reaction.
class MotionCurves {
  MotionCurves._();

  /// Overshoot past target, settle back.
  /// Used for: Confirmations, toggle knobs, celebratory reveals.
  static const Curve easeOutBack = Curves.easeOutBack;

  /// Symmetric accelerate/decelerate.
  /// Used for: Standard panel transitions.
  static const Curve easeInOutCubic = Curves.easeInOutCubic;

  /// Gentle, no hard start/stop.
  /// Used for: Idle/ambient loops (background drift, breathing glow).
  static const Curve easeInOutSine = Curves.easeInOutSine;

  /// Pulls opposite the main motion slightly before executing main ease.
  /// Used for: Primary button presses (Anticipation - Action - Reaction).
  static const Curve anticipation = _AnticipationCurve();
}

class _AnticipationCurve extends Curve {
  const _AnticipationCurve();

  @override
  double transformInternal(double t) {
    // 10-15% pull opposite the main motion for ~80ms (roughly t < 0.2)
    // then main ease. We can approximate this by returning a negative value initially.
    // Standard backIn curve does this.
    return Curves.easeInBack.transform(t);
  }
}
