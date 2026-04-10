// lib/shared/widgets/pastel_mesh_background.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen pastel mesh gradient background with slow drifting animation.
/// Use inside a Stack as the bottom layer.
class PastelMeshBackground extends StatefulWidget {
  const PastelMeshBackground({super.key});

  @override
  State<PastelMeshBackground> createState() => _PastelMeshBackgroundState();
}

class _PastelMeshBackgroundState extends State<PastelMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;
          return CustomPaint(
            painter: _MeshPainter(t),
            isComplex: true,
            willChange: true,
          );
        },
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter(this.t);
  final double t;

  // Very light warm tints — clean, not muddy
  static const _peachColor = Color(0x1AFFCBB8);     // barely-there peach
  static const _apricotColor = Color(0x18FFE0C0);   // hint of warm gold
  static const _roseColor = Color(0x15FFD0D0);      // whisper of rose
  static const _baseColor = Color(0xFFFFFBF9);      // near-white warm base

  @override
  void paint(Canvas canvas, Size size) {
    // Base fill
    canvas.drawRect(Offset.zero & size, Paint()..color = _baseColor);

    // Each blob drifts slowly in a small elliptical path
    _drawBlob(
      canvas, size,
      // Coral — drifts around top-left
      centerX: size.width * 0.20 + math.cos(t) * size.width * 0.06,
      centerY: size.height * 0.22 + math.sin(t * 0.8) * size.height * 0.04,
      radius: size.width * 0.55,
      color: _peachColor,
    );

    _drawBlob(
      canvas, size,
      // Apricot — drifts around top-right
      centerX: size.width * 0.80 + math.cos(t * 0.7 + 2.0) * size.width * 0.05,
      centerY: size.height * 0.18 + math.sin(t * 0.6 + 1.0) * size.height * 0.05,
      radius: size.width * 0.50,
      color: _apricotColor,
    );

    _drawBlob(
      canvas, size,
      // Rose — drifts around bottom-center
      centerX: size.width * 0.60 + math.cos(t * 0.5 + 4.0) * size.width * 0.07,
      centerY: size.height * 0.80 + math.sin(t * 0.9 + 3.0) * size.height * 0.04,
      radius: size.width * 0.55,
      color: _roseColor,
    );
  }

  void _drawBlob(Canvas canvas, Size size, {
    required double centerX,
    required double centerY,
    required double radius,
    required Color color,
  }) {
    final shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0)],
    ).createShader(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) => old.t != t;
}
