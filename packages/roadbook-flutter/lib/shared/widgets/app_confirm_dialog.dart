// lib/shared/widgets/app_confirm_dialog.dart
// Spring-animated confirmation dialog.
// Enter: scale(0.88→1.06→1) + blur(6→0), spring 400ms
// Exit:  scale(1→0.95) + fade + blur, 220ms
// Backdrop: black opacity 0→0.20
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = '确认',
  String cancelLabel = '取消',
  bool isDestructive = true,
}) async {
  final result = await Navigator.of(context, rootNavigator: true)
      .push<bool>(_ConfirmDialogRoute(
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    isDestructive: isDestructive,
  ));
  return result ?? false;
}

// ─── Route ──────────────────────────────────────────────────────────────────

class _ConfirmDialogRoute extends PopupRoute<bool> {
  _ConfirmDialogRoute({
    required this.title,
    this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _ConfirmDialogContent(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Backdrop: 0→20% black
    final backdropFade = Tween<double>(begin: 0.0, end: 0.20)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    // Scale: spring overshoot 0.88→1.06→1.0 on enter, reverses on exit
    final scale = animation.drive(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.88, end: 1.06)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.06, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40,
        ),
      ]),
    );

    // Blur applied to dialog card: 6→0 on enter, 0→6 on exit
    final blurAnim = Tween<double>(begin: 6.0, end: 0.0)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    // Opacity fade
    final fadeCurve =
        CurvedAnimation(parent: animation, curve: Curves.easeOut);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dark backdrop — pointer events fall through to barrier
        IgnorePointer(
          child: FadeTransition(
            opacity: backdropFade,
            child: const ColoredBox(color: Colors.black),
          ),
        ),
        // Dialog
        ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: fadeCurve,
            child: AnimatedBuilder(
              animation: blurAnim,
              builder: (_, c) {
                final sigma = blurAnim.value;
                if (sigma < 0.5) return c!;
                return ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: c,
                );
              },
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card content ────────────────────────────────────────────────────────────

class _ConfirmDialogContent extends StatelessWidget {
  const _ConfirmDialogContent({
    required this.title,
    this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 40,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              const Icon(
                Icons.warning_amber_rounded,
                size: 44,
                color: Color(0xFFFFC107),
              ),
              const SizedBox(height: 14),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 22),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel,
                      onTap: onCancel,
                      isPrimary: false,
                      isDestructive: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel,
                      onTap: onConfirm,
                      isPrimary: true,
                      isDestructive: isDestructive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.isDestructive,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (!isPrimary) {
      bg = const Color(0xFFF2F2F7);
      fg = AppColors.inkSecondary;
    } else if (isDestructive) {
      bg = const Color(0xFFFF3B30);
      fg = Colors.white;
    } else {
      bg = AppColors.primary;
      fg = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
