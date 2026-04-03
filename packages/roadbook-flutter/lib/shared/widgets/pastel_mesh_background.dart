// lib/shared/widgets/pastel_mesh_background.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Full-screen pastel mesh gradient background for Liquid Glass surfaces.
/// Use inside a Stack as the bottom layer.
class PastelMeshBackground extends StatelessWidget {
  const PastelMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: CustomPaint(painter: _MeshPainter(), isComplex: true, willChange: false),
    );
  }
}

class _MeshPainter extends CustomPainter {
  const _MeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base fill: very light lavender
    canvas.drawRect(rect, Paint()..color = const Color(0xFFF2F0FF));

    // Warm coral blob — top-left
    _drawBlob(canvas, size,
      center: Offset(size.width * 0.15, size.height * 0.25),
      radiusX: size.width * 0.7,
      radiusY: size.height * 0.55,
      color: const Color(0x4DFFB4A0), // rgba(255,180,160,0.30)
    );

    // Cool lavender blob — top-right
    _drawBlob(canvas, size,
      center: Offset(size.width * 0.85, size.height * 0.15),
      radiusX: size.width * 0.55,
      radiusY: size.height * 0.65,
      color: const Color(0x66C8B9FF), // rgba(200,185,255,0.40)
    );

    // Mint blob — bottom-center-right
    _drawBlob(canvas, size,
      center: Offset(size.width * 0.65, size.height * 0.85),
      radiusX: size.width * 0.65,
      radiusY: size.height * 0.50,
      color: const Color(0x4DA0E6D2), // rgba(160,230,210,0.30)
    );
  }

  void _drawBlob(Canvas canvas, Size size, {
    required Offset center,
    required double radiusX,
    required double radiusY,
    required Color color,
  }) {
    final radius = radiusX > radiusY ? radiusX : radiusY;
    final shader = ui.Gradient.radial(
      center,
      radius,
      [color, color.withValues(alpha: 0)],
      [0.0, 1.0],
    );
    // Scale to ellipse
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, radiusY / radiusX);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(
      Rect.fromCenter(center: center, width: radiusX * 2, height: radiusX * 2),
      Paint()..shader = shader,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) => false;
}
