// lib/shared/widgets/pastel_mesh_background.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ambient Canvas — warm base with three colour orbs.
/// On each route change the orbs animate to new random positions,
/// then gently breathe in place until the next switch.
class PastelMeshBackground extends StatefulWidget {
  const PastelMeshBackground({super.key});

  /// Global key for accessing state from anywhere.
  static final globalKey = GlobalKey<_PastelMeshBgState>();

  /// Call this to randomise orb positions (e.g. on page switch).
  static void shuffle([BuildContext? _]) {
    globalKey.currentState?.shuffle();
  }

  @override
  State<PastelMeshBackground> createState() => _PastelMeshBgState();
}

class _PastelMeshBgState extends State<PastelMeshBackground>
    with TickerProviderStateMixin {
  final _rng = math.Random();

  // ── Breathing loop (continuous)
  late final AnimationController _breatheCtrl;

  // ── Position transition (fires on shuffle)
  late final AnimationController _moveCtrl;

  // Each orb: previous position → current target position (normalised 0–1)
  late List<Offset> _fromPos;
  late List<Offset> _toPos;

  @override
  void initState() {
    super.initState();
    _toPos = _randomPositions();
    _fromPos = List.of(_toPos);

    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..value = 1.0; // start settled
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _moveCtrl.dispose();
    super.dispose();
  }

  List<Offset> _randomPositions() => [
    Offset(0.10 + _rng.nextDouble() * 0.35, 0.08 + _rng.nextDouble() * 0.30),
    Offset(0.50 + _rng.nextDouble() * 0.40, 0.05 + _rng.nextDouble() * 0.30),
    Offset(0.15 + _rng.nextDouble() * 0.50, 0.55 + _rng.nextDouble() * 0.30),
  ];

  void shuffle() {
    setState(() {
      _fromPos = List.of(_toPos);
      _toPos = _randomPositions();
    });
    _moveCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_breatheCtrl, _moveCtrl]),
        builder: (context, _) {
          return CustomPaint(
            painter: _OrbPainter(
              breathe: _breatheCtrl.value * 2 * math.pi,
              moveT: Curves.easeOutCubic.transform(_moveCtrl.value),
              fromPos: _fromPos,
              toPos: _toPos,
            ),
            isComplex: true,
            willChange: true,
          );
        },
      ),
    );
  }
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.breathe,
    required this.moveT,
    required this.fromPos,
    required this.toPos,
  });

  final double breathe; // radians, loops 0→2π
  final double moveT;   // 0→1 position transition progress
  final List<Offset> fromPos;
  final List<Offset> toPos;

  static const _colors = [
    Color(0x50F5D2A0), // Sand warm — 31%, brightest
    Color(0x40FF6B3D), // Coral — 25%, mid
    Color(0x30F0C878), // Honey — 19%, softest
  ];
  static const _radii = [1.0, 0.90, 1.05]; // relative to width — ~half screen diameter
  // Per-orb breathing amplitude and frequency
  static const _bAmpX  = [0.025, 0.020, 0.030];
  static const _bAmpY  = [0.018, 0.022, 0.016];
  static const _bFreqX = [1.0, 0.7, 0.5];
  static const _bFreqY = [0.8, 0.6, 0.9];
  static const _bPhase = [0.0, 2.0, 4.0];

  static const _base = Color(0xFFF2EDE8);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = _base);

    for (int i = 0; i < 3; i++) {
      // Lerp from old position to new position
      final fx = fromPos[i].dx + (toPos[i].dx - fromPos[i].dx) * moveT;
      final fy = fromPos[i].dy + (toPos[i].dy - fromPos[i].dy) * moveT;

      // Add breathing oscillation on top
      final cx = w * fx +
          math.cos(breathe * _bFreqX[i] + _bPhase[i]) * w * _bAmpX[i];
      final cy = h * fy +
          math.sin(breathe * _bFreqY[i] + _bPhase[i]) * h * _bAmpY[i];

      final r = w * _radii[i];
      final color = _colors[i];
      final shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => true;
}
