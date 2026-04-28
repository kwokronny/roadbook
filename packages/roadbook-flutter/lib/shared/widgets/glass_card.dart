// lib/shared/widgets/glass_card.dart
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Frosted Warmth glass card — semi-transparent white surface with
/// specular highlight and optional tint overlay.
/// No BackdropFilter (unreliable inside ListView); transparency
/// comes from the alpha of [GlassSpec.cardBg] directly.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.tintColor,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppRadius.card,
    this.onTap,
  });

  final Widget child;
  final Color? tintColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
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
                        colors: [
                          tintColor!,
                          tintColor!.withValues(alpha: tintColor!.a * 0.33),
                        ],
                      ),
                    ),
                  ),
                ),
              // Specular highlight (160deg)
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
    );
  }
}
