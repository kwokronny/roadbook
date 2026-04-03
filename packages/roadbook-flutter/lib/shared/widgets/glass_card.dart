// lib/shared/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Reusable Liquid Glass card surface with BackdropFilter, specular highlight,
/// and optional tint overlay.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.tintColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppRadius.card,
    this.onTap,
  });

  final Widget child;
  /// Optional tint gradient overlay (e.g. status color).
  final Color? tintColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: GlassSpec.cardBg,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: GlassSpec.cardBorder, width: 1),
                boxShadow: GlassSpec.cardShadow,
              ),
              child: Stack(
                children: [
                  // Tint overlay
                  if (tintColor != null)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          gradient: LinearGradient(
                            begin: const Alignment(-0.5, -0.5),
                            end: const Alignment(0.5, 0.5),
                            colors: [tintColor!, tintColor!.withValues(alpha: tintColor!.a * 0.33)],
                          ),
                        ),
                      ),
                    ),
                  // Specular highlight
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          gradient: GlassSpec.specularHighlight,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(padding: padding, child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
