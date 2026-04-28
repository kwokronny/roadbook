// lib/shared/widgets/skeleton.dart
import 'dart:async';
import 'package:flutter/material.dart';

// ─── Shared animation scope ─────────────────────────────────────────────────

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({required this.controller, required super.child});
  final AnimationController controller;

  @override
  bool updateShouldNotify(_SkeletonScope old) => controller != old.controller;

  static AnimationController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonScope>()?.controller;
}

/// Provides a shared 1.6s shimmer animation to all [Bone] descendants.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key, required this.child});
  final Widget child;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _SkeletonScope(controller: _ctrl, child: widget.child);
}

// ─── Bone ───────────────────────────────────────────────────────────────────

/// A single skeleton bone with shimmer sweep.
/// Bone base: rgba(28,28,30,0.04). Shimmer: white 50%, 1.6s.
class Bone extends StatelessWidget {
  const Bone({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
    this.isCircle = false,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final ctrl = _SkeletonScope.of(context);
    final br = isCircle
        ? BorderRadius.circular(height / 2)
        : (borderRadius ?? BorderRadius.circular(6));

    if (ctrl == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0x0A1C1C1E),
          borderRadius: br,
        ),
      );
    }

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => ClipRRect(
        borderRadius: br,
        child: CustomPaint(
          painter: _BonePainter(ctrl.value),
          child: SizedBox(width: width, height: height),
        ),
      ),
    );
  }
}

class _BonePainter extends CustomPainter {
  const _BonePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x0A1C1C1E),
    );

    // Wide soft shimmer: band is 2× bone width, gentle 16% peak.
    final pos = -1.0 + t * 3.0;
    final s0 = (pos - 1.0).clamp(0.0, 1.0);
    final s1 = (pos - 0.4).clamp(0.0, 1.0);
    final s2 = pos.clamp(0.0, 1.0);
    final s3 = (pos + 0.4).clamp(0.0, 1.0);
    final s4 = (pos + 1.0).clamp(0.0, 1.0);
    if (s0 < s4) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: const [
              Color(0x00FFFFFF),
              Color(0x14FFFFFF), // 8%
              Color(0x28FFFFFF), // 16% peak
              Color(0x14FFFFFF), // 8%
              Color(0x00FFFFFF),
            ],
            stops: [s0, s1, s2, s3, s4],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_BonePainter old) => t != old.t;
}

// ─── SkeletonTransition ─────────────────────────────────────────────────────

/// Handles the skeleton → content transition.
/// - Enforces min 300ms skeleton display time.
/// - Skeleton fades out in 200ms (ease-out).
/// - Content fades in + slides up 12px in 320ms.
class SkeletonTransition extends StatefulWidget {
  const SkeletonTransition({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
  });

  final bool isLoading;
  final Widget skeleton;
  final Widget child;

  @override
  State<SkeletonTransition> createState() => _SkeletonTransitionState();
}

enum _Phase { skeleton, transitioning, content }

class _SkeletonTransitionState extends State<SkeletonTransition>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.skeleton;
  DateTime? _skeletonShownAt;
  bool _triggered = false;

  late final AnimationController _ctrl;
  late final Animation<double> _skeletonAlpha;
  late final Animation<double> _contentAlpha;
  late final Animation<double> _contentSlide;

  @override
  void initState() {
    super.initState();
    _skeletonShownAt = DateTime.now();
    if (!widget.isLoading) _phase = _Phase.content;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _skeletonAlpha = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 200 / 320, curve: Curves.easeOut),
      ),
    );
    _contentAlpha = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _contentSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant SkeletonTransition old) {
    super.didUpdateWidget(old);
    if (old.isLoading && !widget.isLoading && !_triggered) {
      _triggered = true;
      _triggerTransition();
    }
  }

  Future<void> _triggerTransition() async {
    final elapsed =
        DateTime.now().difference(_skeletonShownAt!).inMilliseconds;
    final remaining = (300 - elapsed).clamp(0, 300);
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
    if (!mounted) return;
    setState(() => _phase = _Phase.transitioning);
    await _ctrl.forward();
    if (!mounted) return;
    setState(() => _phase = _Phase.content);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.content => widget.child,
      _Phase.skeleton => widget.skeleton,
      _Phase.transitioning => Stack(
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => Opacity(
                opacity: _contentAlpha.value,
                child: Transform.translate(
                  offset: Offset(0, _contentSlide.value),
                  child: child,
                ),
              ),
              child: widget.child,
            ),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) =>
                  Opacity(opacity: _skeletonAlpha.value, child: child),
              child: widget.skeleton,
            ),
          ],
        ),
    };
  }
}
