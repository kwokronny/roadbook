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

  // Lighter colors (reduced opacity)
  static const _coralColor = Color(0x33FFB4A0);    // was 0x4D → 0x33 (~20%)
  static const _lavenderColor = Color(0x40C8B9FF);  // was 0x66 → 0x40 (~25%)
  static const _mintColor = Color(0x33A0E6D2);      // was 0x4D → 0x33 (~20%)
  static const _baseColor = Color(0xFFF5F3FF);      // lighter base

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
      color: _coralColor,
    );

    _drawBlob(
      canvas, size,
      // Lavender — drifts around top-right
      centerX: size.width * 0.80 + math.cos(t * 0.7 + 2.0) * size.width * 0.05,
      centerY: size.height * 0.18 + math.sin(t * 0.6 + 1.0) * size.height * 0.05,
      radius: size.width * 0.50,
      color: _lavenderColor,
    );

    _drawBlob(
      canvas, size,
      // Mint — drifts around bottom-center
      centerX: size.width * 0.60 + math.cos(t * 0.5 + 4.0) * size.width * 0.07,
      centerY: size.height * 0.80 + math.sin(t * 0.9 + 3.0) * size.height * 0.04,
      radius: size.width * 0.55,
      color: _mintColor,
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
