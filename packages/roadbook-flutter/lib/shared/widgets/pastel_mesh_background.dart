// lib/shared/widgets/pastel_mesh_background.dart
import 'package:flutter/material.dart';

/// Full-screen pastel mesh gradient background for Liquid Glass surfaces.
/// Use inside a Stack as the bottom layer.
class PastelMeshBackground extends StatelessWidget {
  const PastelMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0FF), // base: very light lavender
        ),
        child: Stack(
          children: [
            // Warm coral blob — top-left
            Positioned(
              left: -MediaQuery.sizeOf(context).width * 0.2,
              top: -MediaQuery.sizeOf(context).height * 0.05,
              width: MediaQuery.sizeOf(context).width * 1.2,
              height: MediaQuery.sizeOf(context).height * 0.65,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.4, -0.2),
                    radius: 0.8,
                    colors: [Color(0x4DFFB4A0), Color(0x00FFB4A0)],
                  ),
                ),
              ),
            ),
            // Cool lavender blob — top-right
            Positioned(
              right: -MediaQuery.sizeOf(context).width * 0.15,
              top: -MediaQuery.sizeOf(context).height * 0.1,
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 0.7,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.5, -0.3),
                    radius: 0.7,
                    colors: [Color(0x66C8B9FF), Color(0x00C8B9FF)],
                  ),
                ),
              ),
            ),
            // Mint blob — bottom-center-right
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.1,
              bottom: -MediaQuery.sizeOf(context).height * 0.1,
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.2, 0.3),
                    radius: 0.75,
                    colors: [Color(0x4DA0E6D2), Color(0x00A0E6D2)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
