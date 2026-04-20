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

/// Shows a glass popover menu that expands downward from the trigger.
/// enter: scaleY(0→1) + fade, 280ms expressive
/// exit: scaleY(1→0) + fade, 200ms easeOut
Future<void> showGlassPopover({
  required BuildContext context,
  required RelativeRect position,
  required List<PopoverItem> items,
  double? width,
}) {
  return Navigator.of(context).push(_PopoverRoute(
    position: position,
    items: items,
    width: width,
  ));
}

class _PopoverRoute extends PopupRoute<void> {
  _PopoverRoute({required this.position, required this.items, this.width});
  final RelativeRect position;
  final List<PopoverItem> items;
  final double? width;

  @override
  Color? get barrierColor => Colors.transparent;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dismiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 280);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  static const _enterCurve = Cubic(0.22, 1.0, 0.36, 1.0); // expressive
  static const _exitCurve = Cubic(0.22, 0.0, 0.36, 1.0);  // easeOut

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isForward = animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.completed;
    final curve = isForward ? _enterCurve : _exitCurve;

    final scaleY = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: animation, curve: curve));
    final opacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: animation, curve: curve));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: opacity.value.clamp(0.0, 1.0),
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: scaleY.value.clamp(0.0, 1.0),
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
      child: _PopoverMenu(items: items, width: width),
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
  const _PopoverMenu({required this.items, this.width});
  final List<PopoverItem> items;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width ?? 180,
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

