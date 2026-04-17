// lib/shared/widgets/glass_popover.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// A menu item for [GlassPopover].
class PopoverItem {
  const PopoverItem({
    required this.label,
    this.emoji,
    this.icon,
    this.isDestructive = false,
    required this.onTap,
  });
  final String label;
  final String? emoji;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback onTap;
}

/// Shows a glass popover menu with spring scale + blur animation.
/// enter: scale(0.85→1.06→1) + blur(4→0), 350ms spring
/// exit: scale(1→0.92) + blur(0→4) + fade, 200ms
Future<void> showGlassPopover({
  required BuildContext context,
  required RelativeRect position,
  required List<PopoverItem> items,
}) {
  return Navigator.of(context).push(_PopoverRoute(
    position: position,
    items: items,
  ));
}

class _PopoverRoute extends PopupRoute<void> {
  _PopoverRoute({required this.position, required this.items});
  final RelativeRect position;
  final List<PopoverItem> items;

  @override
  Color? get barrierColor => Colors.transparent;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dismiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Enter: spring overshoot scale 0.85→1.06→1
    // Exit: scale 1→0.92 + fade
    final isForward = animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.completed;

    final scaleValue = isForward
        ? TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.06), weight: 60),
            TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 40),
          ]).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut))
        : Tween<double>(begin: 0.92, end: 1.0).animate(animation);

    final opacity = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    // Blur: 4→0 on enter, 0→4 on exit
    final blurValue = Tween<double>(begin: 4.0, end: 0.0)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return FadeTransition(
          opacity: opacity,
          child: Transform.scale(
            scale: scaleValue.value,
            alignment: Alignment.topRight,
            child: ImageFiltered(
              imageFilter: blurValue.value > 0.1
                  ? ImageFilter.blur(
                      sigmaX: blurValue.value, sigmaY: blurValue.value)
                  : ImageFilter.blur(sigmaX: 0.01, sigmaY: 0.01),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return CustomSingleChildLayout(
      delegate: _PopoverLayoutDelegate(position),
      child: _PopoverMenu(items: items),
    );
  }
}

class _PopoverLayoutDelegate extends SingleChildLayoutDelegate {
  _PopoverLayoutDelegate(this.position);
  final RelativeRect position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
        Size(constraints.maxWidth - 32, constraints.maxHeight));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = size.width - position.right - childSize.width;
    double y = position.top;
    // Clamp
    x = x.clamp(16, size.width - childSize.width - 16);
    y = y.clamp(16, size.height - childSize.height - 16);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _PopoverLayoutDelegate old) =>
      position != old.position;
}

class _PopoverMenu extends StatelessWidget {
  const _PopoverMenu({required this.items});
  final List<PopoverItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
            BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _buildItem(context, items[i]),
              if (i < items.length - 1)
                Divider(height: 0.5, thickness: 0.5, indent: 16, endIndent: 16,
                    color: AppColors.inkPrimary.withValues(alpha: 0.06)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, PopoverItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        item.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item.isDestructive
              ? const Color(0x0AFF3B30) // light red tint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (item.icon != null)
              Icon(item.icon, size: 17,
                  color: item.isDestructive ? AppColors.destructive : AppColors.inkSecondary)
            else
              Text(item.emoji ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: item.isDestructive
                    ? AppColors.destructive
                    : AppColors.inkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

