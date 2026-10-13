import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

/// An animated, stylized high-end Unity-style flowing river connecting stage nodes.
///
/// Features:
/// - Multi-layered water body with deep riverbed and luminous turquoise caustics
/// - Continuous animated foam rapids traveling downstream
/// - Dynamic water sparkle and bubble particles flowing along the river current
/// - Animated water swirls / ripple pools around stage node anchors
class FlowingRiverComponent extends PositionComponent {
  List<Vector2> _points = [];
  Path? _cachedPath;
  ui.PathMetric? _cachedMetric;
  
  double _flowTime = 0.0;
  final List<_RiverParticle> _particles = [];
  final Random _rnd = Random();

  FlowingRiverComponent() {
    anchor = Anchor.topLeft;
    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(_RiverParticle(
        progress: _rnd.nextDouble(),
        lateralOffset: (_rnd.nextDouble() - 0.5) * 16.0,
        speed: 0.04 + _rnd.nextDouble() * 0.07,
        radius: 1.5 + _rnd.nextDouble() * 2.2,
        seed: _rnd.nextDouble() * 100.0,
      ));
    }
  }

  void setPoints(List<Vector2> points) {
    _points = List.from(points);
    _buildPath();
  }

  void _buildPath() {
    if (_points.length < 2) {
      _cachedPath = null;
      _cachedMetric = null;
      return;
    }

    final path = Path();
    path.moveTo(_points.first.x, _points.first.y);

    for (int i = 1; i < _points.length; i++) {
      final p0 = _points[i - 1];
      final p1 = _points[i];

      // Create a smooth organic S-curve between consecutive stage points
      final midY = (p0.y + p1.y) / 2.0;
      final dx = p1.x - p0.x;
      
      // Add horizontal sway for natural water meandering
      final sway = dx.abs() > 20 ? dx * 0.25 : (i % 2 == 0 ? 30.0 : -30.0);
      final c1 = Offset(p0.x + sway, midY - 15);
      final c2 = Offset(p1.x - sway, midY + 15);

      path.cubicTo(
        c1.dx, c1.dy,
        c2.dx, c2.dy,
        p1.x, p1.y,
      );
    }

    _cachedPath = path;
    final metrics = path.computeMetrics().toList();
    _cachedMetric = metrics.isNotEmpty ? metrics.first : null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _flowTime += dt;

    if (_cachedMetric != null) {
      for (final p in _particles) {
        p.progress += dt * p.speed;
        if (p.progress >= 1.0) {
          p.progress = 0.0;
          p.lateralOffset = (_rnd.nextDouble() - 0.5) * 16.0;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_cachedPath == null || _cachedMetric == null || _points.isEmpty) return;

    final metric = _cachedMetric!;
    final totalLength = metric.length;
    if (totalLength <= 0) return;

    // 1. Draw River Pool Ripples around each stage node
    _renderNodePonds(canvas);

    // 2. Layer 1: Deep Riverbed Trench (Dark Teal Shoreline)
    final trenchPaint = Paint()
      ..color = const Color(0xFF04181B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 42.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, trenchPaint);

    // 3. Layer 2: River Bank Mud / Wet Sand Trim
    final bankPaint = Paint()
      ..color = const Color(0xFF0A3033)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, bankPaint);

    // 4. Layer 3: Deep Water Body
    final deepWaterPaint = Paint()
      ..color = const Color(0xFF005A7A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, deepWaterPaint);

    // 5. Layer 4: Cyan River Current Core
    final currentCorePaint = Paint()
      ..color = const Color(0xFF0096C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, currentCorePaint);

    // 6. Layer 5: Glowing Turquoise Caustics Stream
    final causticPaint = Paint()
      ..color = const Color(0xFF48CAE4).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, causticPaint);

    // 7. Layer 6: Animated Flowing Foam Rapids (Primary central rapid)
    _renderFlowingFoam(canvas, metric, totalLength);

    // 8. Layer 7: Floating Sparkle / Bubble Particles
    _renderWaterParticles(canvas, metric, totalLength);
  }

  void _renderNodePonds(Canvas canvas) {
    for (int i = 0; i < _points.length; i++) {
      final pt = _points[i];
      final ripplePhase = (_flowTime * 2.2 + i * 1.3) % (2 * pi);
      final r1 = 30.0 + sin(ripplePhase) * 6.0;
      final alpha1 = (0.25 + 0.15 * cos(ripplePhase)).clamp(0.0, 1.0);

      final r2 = 42.0 + cos(ripplePhase * 0.9) * 8.0;
      final alpha2 = (0.15 + 0.10 * sin(ripplePhase)).clamp(0.0, 1.0);

      // Deep pool underneath node
      final poolPaint = Paint()
        ..color = const Color(0xFF032228).withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pt.x, pt.y), 44.0, poolPaint);

      // Expanding concentric water rings
      final ringPaint1 = Paint()
        ..color = const Color(0xFF48CAE4).withValues(alpha: alpha1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset(pt.x, pt.y), r1, ringPaint1);

      final ringPaint2 = Paint()
        ..color = const Color(0xFF90E0EF).withValues(alpha: alpha2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(pt.x, pt.y), r2, ringPaint2);
    }
  }

  void _renderFlowingFoam(Canvas canvas, ui.PathMetric metric, double totalLength) {
    // Primary rapid: fast flowing white-cyan crests
    const dashLength = 24.0;
    const dashSpace = 28.0;
    const cycle = dashLength + dashSpace;
    final primaryOffset = (_flowTime * 95.0) % cycle;

    final primaryFoamPath = Path();
    double dist = primaryOffset;
    while (dist < totalLength) {
      final len = min(dashLength, totalLength - dist);
      if (len > 0) {
        primaryFoamPath.addPath(metric.extractPath(dist, dist + len), Offset.zero);
      }
      dist += cycle;
    }

    final primaryFoamPaint = Paint()
      ..color = const Color(0xFFE0FBFC).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(primaryFoamPath, primaryFoamPaint);

    // Secondary rapid: slower offset ripples giving depth
    const secondaryDash = 14.0;
    const secondarySpace = 32.0;
    const secCycle = secondaryDash + secondarySpace;
    final secOffset = (_flowTime * 60.0 + 18.0) % secCycle;

    final secFoamPath = Path();
    dist = secOffset;
    while (dist < totalLength) {
      final len = min(secondaryDash, totalLength - dist);
      if (len > 0) {
        secFoamPath.addPath(metric.extractPath(dist, dist + len), Offset.zero);
      }
      dist += secCycle;
    }

    final secFoamPaint = Paint()
      ..color = const Color(0xFFADE8F4).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(secFoamPath, secFoamPaint);
  }

  void _renderWaterParticles(Canvas canvas, ui.PathMetric metric, double totalLength) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final offsetDist = p.progress * totalLength;
      final tangent = metric.getTangentForOffset(offsetDist);
      if (tangent == null) continue;

      // Normal vector perpendicular to the flow direction
      final dir = tangent.vector;
      final normal = Offset(-dir.dy, dir.dx);

      // Meandering wobble
      final wobble = sin(_flowTime * 3.5 + p.seed) * 3.0;
      final pos = tangent.position + normal * (p.lateralOffset + wobble);

      // Fade in at river source, fade out near the end
      double alpha = 0.85;
      if (p.progress < 0.1) {
        alpha = (p.progress / 0.1) * 0.85;
      } else if (p.progress > 0.9) {
        alpha = ((1.0 - p.progress) / 0.1) * 0.85;
      }

      particlePaint.color = const Color(0xFFCAF0F8).withValues(alpha: alpha);
      canvas.drawCircle(pos, p.radius, particlePaint);

      // Tiny inner bright core for sparkles
      if (p.radius > 2.2) {
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.9)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, p.radius * 0.5, corePaint);
      }
    }
  }
}

class _RiverParticle {
  double progress;
  double lateralOffset;
  final double speed;
  final double radius;
  final double seed;

  _RiverParticle({
    required this.progress,
    required this.lateralOffset,
    required this.speed,
    required this.radius,
    required this.seed,
  });
}
