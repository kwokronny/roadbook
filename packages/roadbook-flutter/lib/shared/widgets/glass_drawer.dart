// lib/shared/widgets/glass_drawer.dart
// Bottom-anchored drawer with frosted glass surface and a blurred mask.
// Replaces showModalBottomSheet for form-style sheets.
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Push a glass drawer onto the navigator. Returns the value passed to pop().
Future<T?> showGlassDrawer<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
}) {
  final nav = Navigator.of(context, rootNavigator: useRootNavigator);
  return nav.push(_GlassDrawerRoute<T>(
    title: title,
    builder: builder,
    barrierDismissible: barrierDismissible,
  ));
}

class _GlassDrawerRoute<T> extends PopupRoute<T> {
  _GlassDrawerRoute({
    required this.title,
    required this.builder,
    required bool barrierDismissible,
  }) : _barrierDismissible = barrierDismissible;

  final String title;
  final WidgetBuilder builder;
  final bool _barrierDismissible;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 240);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _GlassDrawerScaffold(title: title, child: Builder(builder: builder));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.expressive,
      reverseCurve: AppAnimations.easeOut,
    );
    final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(curved);
    final maskFade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    return Stack(
      children: [
        // Blurred mask — tap to dismiss.
        FadeTransition(
          opacity: maskFade,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _barrierDismissible
                ? () => Navigator.of(context).pop()
                : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: const ColoredBox(color: Color(0x99000000)),
            ),
          ),
        ),
        // Sheet
        SlideTransition(position: slide, child: child),
      ],
    );
  }
}

class _GlassDrawerScaffold extends StatelessWidget {
  const _GlassDrawerScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxHeight = mq.size.height - mq.padding.top - 24;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1AFFFFFF), // light gray 5%
                      Color(0x4DFFFFFF), // light gray 30%
                    ],
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.sheet)),
                  border: Border(
                    top: BorderSide(color: GlassSpec.sheetBorder, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 32,
                        offset: Offset(0, -8)),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  type: MaterialType.transparency,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(top: 10, bottom: 14),
                          decoration: BoxDecoration(
                            color: GlassSpec.dragHandle,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Title bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Row(
                            children: [
                              Text(title,
                                  style: AppTextStyles.title
                                      .copyWith(fontSize: 20)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: Color(0x1A1C1C1E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14,
                                      color: AppColors.inkSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Content — takes remaining space up to maxHeight.
                        Flexible(child: child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
