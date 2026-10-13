import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

/// An organic, natural flowing river connecting stage nodes with smooth meanders.
///
/// Features:
/// - Natural organic S-curve meanders (not stiff straight strings)
/// - Lush mountain water palette (deep azure, cerulean, soft seafoam) matching the nature theme
/// - Moving foam rapids and drifting water sparkles
/// - Natural water pools with gentle expanding ripples at stage islands
/// - Soft riverbank shoreline texture
class FlowingRiverComponent extends PositionComponent {
  List<Vector2> _points = [];
  Path? _cachedPath;
  
  double _flowTime = 0.0;
  final List<_RiverParticle> _particles = [];
  final List<_Pebble> _pebbles = [];
  final Random _rnd = Random(42);

  FlowingRiverComponent() {
    anchor = Anchor.topLeft;
    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 28; i++) {
      _particles.add(_RiverParticle(
        initialProgress: _rnd.nextDouble(),
        lateralOffset: (_rnd.nextDouble() - 0.5) * 12.0,
        speed: 0.04 + _rnd.nextDouble() * 0.06,
        radius: 1.5 + _rnd.nextDouble() * 1.8,
        seed: _rnd.nextDouble() * 100.0,
      ));
    }
  }

  void setPoints(List<Vector2> points) {
    _points = List.from(points);
    _buildNaturalPath();
    _buildPebbles();
  }

  void _buildNaturalPath() {
    if (_points.length < 2) {
      _cachedPath = null;
      return;
    }

    final path = Path();
    path.moveTo(_points.first.x, _points.first.y);

    for (int i = 1; i < _points.length; i++) {
      final p0 = _points[i - 1];
      final p1 = _points[i];

      final dy = p1.y - p0.y;
      final dx = p1.x - p0.x;

      // Natural, organic meander with non-perfect, varied curves
      final curveIntensity = 0.45 + (sin(i * 2.3).abs() * 0.25);
      final horizontalSwing = (dx.abs() > 30) ? dx * 0.35 : (i % 2 == 0 ? 45.0 : -45.0);

      // Varied Bézier control points creating genuine river meandering
      final c1 = Offset(
        p0.x + horizontalSwing,
        p0.y + (dy * curveIntensity),
      );
      final c2 = Offset(
        p1.x - horizontalSwing,
        p1.y - (dy * (1.0 - curveIntensity)),
      );

      path.cubicTo(
        c1.dx, c1.dy,
        c2.dx, c2.dy,
        p1.x, p1.y,
      );
    }

    _cachedPath = path;
  }

  void _buildPebbles() {
    _pebbles.clear();
    if (_cachedPath == null) return;

    final metrics = _cachedPath!.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLen = metric.length;

    // Distribute small natural river stones along the shoreline
    for (double dist = 40.0; dist < totalLen - 40; dist += 35.0 + _rnd.nextDouble() * 30.0) {
      final tangent = metric.getTangentForOffset(dist);
      if (tangent != null) {
        final dir = tangent.vector;
        final normal = Offset(-dir.dy, dir.dx);
        final side = _rnd.nextBool() ? 1.0 : -1.0;
        final stoneOffset = side * (16.0 + _rnd.nextDouble() * 6.0);
        final pos = tangent.position + normal * stoneOffset;

        _pebbles.add(_Pebble(
          offset: pos,
          radiusX: 2.5 + _rnd.nextDouble() * 2.5,
          radiusY: 1.8 + _rnd.nextDouble() * 2.0,
          rotation: _rnd.nextDouble() * pi,
          color: _rnd.nextBool()
              ? const Color(0xFF4A5568).withValues(alpha: 0.6)
              : const Color(0xFF6B7280).withValues(alpha: 0.5),
        ));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _flowTime += dt;
  }

  @override
  void render(Canvas canvas) {
    if (_cachedPath == null || _points.isEmpty) return;

    final metrics = _cachedPath!.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLength = metric.length;
    if (totalLength <= 0) return;

    // 1. Natural River Pools at Stage Islands
    _renderNodePonds(canvas);

    // 2. Layer 1: Mossy River Shoreline & Wet Mud Trench
    final trenchPaint = Paint()
      ..color = const Color(0xFF132A20) // Deep dark moss earth
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, trenchPaint);

    // 3. Layer 2: Soft Riverbank Transition
    final bankPaint = Paint()
      ..color = const Color(0xFF1C4232) // Wet forest river bank
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, bankPaint);

    // 4. Layer 3: Natural Mountain River Water (Deep Azure)
    final deepWaterPaint = Paint()
      ..color = const Color(0xFF1B6B93) // Natural deep azure blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, deepWaterPaint);

    // 5. Layer 4: Clear Sunlit Surface Stream
    final currentCorePaint = Paint()
      ..color = const Color(0xFF2998C4) // Sunlit mountain stream
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, currentCorePaint);

    // 6. Layer 5: Soft Water Shimmer
    final shimmerPaint = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.50) // Soft sky reflection
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_cachedPath!, shimmerPaint);

    // 7. Render Shoreline Pebbles
    _renderPebbles(canvas);

    // 8. Layer 6: Animated Flowing Foam Waves
    _renderFlowingFoam(canvas, metric, totalLength);

    // 9. Layer 7: Floating Water Sparkles
    _renderWaterParticles(canvas, metric, totalLength);
  }

  void _renderNodePonds(Canvas canvas) {
    for (int i = 0; i < _points.length; i++) {
      final pt = _points[i];
      final ripplePhase = (_flowTime * 2.0 + i * 1.4) % (2 * pi);
      final r1 = 26.0 + sin(ripplePhase) * 5.0;
      final alpha1 = (0.30 + 0.15 * cos(ripplePhase)).clamp(0.0, 1.0);

      final r2 = 36.0 + cos(ripplePhase * 0.85) * 6.0;
      final alpha2 = (0.18 + 0.10 * sin(ripplePhase)).clamp(0.0, 1.0);

      // Deep mountain pool
      final poolPaint = Paint()
        ..color = const Color(0xFF0F2D24).withValues(alpha: 0.80)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pt.x, pt.y), 38.0, poolPaint);

      // Expanding concentric water ripples
      final ringPaint1 = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: alpha1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(pt.x, pt.y), r1, ringPaint1);

      final ringPaint2 = Paint()
        ..color = const Color(0xFFBAE6FD).withValues(alpha: alpha2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawCircle(Offset(pt.x, pt.y), r2, ringPaint2);
    }
  }

  void _renderPebbles(Canvas canvas) {
    final pebblePaint = Paint()..style = PaintingStyle.fill;
    for (final p in _pebbles) {
      pebblePaint.color = p.color;
      canvas.save();
      canvas.translate(p.offset.dx, p.offset.dy);
      canvas.rotate(p.rotation);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: p.radiusX * 2, height: p.radiusY * 2),
        pebblePaint,
      );
      canvas.restore();
    }
  }

  void _renderFlowingFoam(Canvas canvas, dynamic metric, double totalLength) {
    // Primary foam wave: natural soft white crests
    const dashLength = 22.0;
    const dashSpace = 28.0;
    const cycle = dashLength + dashSpace;
    final primaryOffset = (_flowTime * 75.0) % cycle;

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
      ..color = const Color(0xFFF0FDF4).withValues(alpha: 0.75) // Soft creamy foam
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(primaryFoamPath, primaryFoamPaint);

    // Secondary soft stream ripple
    const secondaryDash = 14.0;
    const secondarySpace = 32.0;
    const secCycle = secondaryDash + secondarySpace;
    final secOffset = (_flowTime * 48.0 + 14.0) % secCycle;

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
      ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(secFoamPath, secFoamPaint);
  }

  void _renderWaterParticles(Canvas canvas, dynamic metric, double totalLength) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final progress = (p.initialProgress + (_flowTime * p.speed)) % 1.0;
      final offsetDist = progress * totalLength;
      final tangent = metric.getTangentForOffset(offsetDist);
      if (tangent == null) continue;

      final dir = tangent.vector;
      final normal = Offset(-dir.dy, dir.dx);
      final wobble = sin(_flowTime * 3.0 + p.seed) * 2.2;
      final pos = tangent.position + normal * (p.lateralOffset + wobble);

      double alpha = 0.75;
      if (progress < 0.1) {
        alpha = (progress / 0.1) * 0.75;
      } else if (progress > 0.9) {
        alpha = ((1.0 - progress) / 0.1) * 0.75;
      }

      particlePaint.color = const Color(0xFFE0F2FE).withValues(alpha: alpha);
      canvas.drawCircle(pos, p.radius, particlePaint);
    }
  }
}

class _RiverParticle {
  final double initialProgress;
  final double lateralOffset;
  final double speed;
  final double radius;
  final double seed;

  _RiverParticle({
    required this.initialProgress,
    required this.lateralOffset,
    required this.speed,
    required this.radius,
    required this.seed,
  });
}

class _Pebble {
  final Offset offset;
  final double radiusX;
  final double radiusY;
  final double rotation;
  final Color color;

  _Pebble({
    required this.offset,
    required this.radiusX,
    required this.radiusY,
    required this.rotation,
    required this.color,
  });
}
