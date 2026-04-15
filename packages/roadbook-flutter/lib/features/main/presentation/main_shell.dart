// lib/features/main/presentation/main_shell.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/pastel_mesh_background.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static final _hideNavPattern = RegExp(r'^/travel/\d+|^/profile/(edit|settings|api-keys)');

  // Dock has 2 tabs (旅程=0, 我的=1) but router has 3 branches (travel=0, discover=1, profile=2)
  static int _branchToDock(int branch) => branch >= 2 ? 1 : 0;
  static int _dockToBranch(int dock) => dock == 0 ? 0 : 2;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final hideNav = _hideNavPattern.hasMatch(location);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PastelMeshBackground(key: PastelMeshBackground.globalKey),
          navigationShell,
          if (!hideNav)
            Positioned(
              left: AppSpacing.dockInset,
              right: AppSpacing.dockInset,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.dockInset,
              child: _BouncyGlassDock(
                // Map 3-branch index → 2-tab dock index (0→0, 2→1)
                currentIndex: _branchToDock(navigationShell.currentIndex),
                onTap: (dockIndex) {
                  final branchIndex = _dockToBranch(dockIndex);
                  if (branchIndex != navigationShell.currentIndex) {
                    PastelMeshBackground.shuffle();
                  }
                  navigationShell.goBranch(
                    branchIndex,
                    initialLocation: branchIndex == navigationShell.currentIndex,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Tab definition ─────────────────────────────────────────────────────────

class _TabDef {
  const _TabDef({required this.outlinedIcon, required this.filledIcon, required this.label});
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
}

const _tabs = [
  _TabDef(outlinedIcon: Icons.map_outlined,     filledIcon: Icons.map,     label: '旅程'),
  _TabDef(outlinedIcon: Icons.person_outline,    filledIcon: Icons.person,   label: '我的'),
];

// ─── Bouncy Glass Dock ──────────────────────────────────────────────────────
//
// Three-layer animation from design spec:
//   1. Dock bounce — squash & stretch jelly on the entire dock shell
//   2. Glass indicator slide — pill slides to new tab with motion blur
//   3. Icon bounce + color — selected icon scales up, color transitions

class _BouncyGlassDock extends StatefulWidget {
  const _BouncyGlassDock({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  State<_BouncyGlassDock> createState() => _BouncyGlassDockState();
}

class _BouncyGlassDockState extends State<_BouncyGlassDock>
    with TickerProviderStateMixin {
  // ── Layer 1: Dock bounce (squash & stretch)
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScaleX;
  late final Animation<double> _bounceScaleY;

  // ── Layer 2: Glass indicator slide
  late final AnimationController _slideCtrl;
  late int _prevIndex;

  // ── Layer 3: Icon scale + color
  late final AnimationController _iconCtrl;

  static const _springCurve = Cubic(0.34, 1.3, 0.64, 1.0);
  static const _bounceCurve = Cubic(0.34, 1.2, 0.64, 1.0);
  static const _dockPad = 5.0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;

    // Dock bounce: 650ms
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    // Squash-stretch keyframes via TweenSequence
    _bounceScaleX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.96), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.02), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 0.99), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.99, end: 1.0), weight: 45),
    ]).animate(_bounceCtrl);
    _bounceScaleY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 0.97), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.01), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.01, end: 1.0), weight: 45),
    ]).animate(_bounceCtrl);

    // Indicator slide: 600ms
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..value = 1.0; // start settled

    // Icon transition: 300ms
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 1.0;
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _slideCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BouncyGlassDock old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = old.currentIndex;
      _triggerSwitch();
    }
  }

  void _triggerSwitch() {
    // 1. Dock bounce
    _bounceCtrl.forward(from: 0);

    // 2. Indicator slide (with motion blur during)
    _slideCtrl.forward(from: 0);

    // 3. Icon color/scale
    _iconCtrl.forward(from: 0);
  }

  // Indicator position (fraction of dock width)
  double _indicatorLeft(double dockWidth, int index) {
    final usable = dockWidth - _dockPad * 2;
    final tabW = usable / _tabs.length;
    return _dockPad + index * tabW + 2;
  }

  double _indicatorWidth(double dockWidth) {
    final usable = dockWidth - _dockPad * 2;
    return usable / _tabs.length - 4;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceCtrl, _slideCtrl, _iconCtrl]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(_bounceScaleX.value, _bounceScaleY.value),
          child: child,
        );
      },
      child: _buildDockShell(),
    );
  }

  Widget _buildDockShell() {
    return Container(
      height: AppSpacing.dockHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 32, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: GlassSpec.navBlur,
          child: Container(
            decoration: BoxDecoration(
              color: GlassSpec.navBg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: GlassSpec.navBorder, width: 1),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dockW = constraints.maxWidth;
                return Stack(
                  children: [
                    // ── Specular top-line
                    Positioned(
                      top: 0, left: dockW * 0.18, right: dockW * 0.18,
                      child: IgnorePointer(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x00FFFFFF),
                                Color(0xCCFFFFFF),
                                Color(0x00FFFFFF),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ── Glass indicator (Layer 2)
                    _buildGlassIndicator(dockW),
                    // ── Tab items (Layer 3)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _dockPad),
                        child: Row(
                          children: List.generate(_tabs.length, (i) =>
                            Expanded(child: _buildTab(i)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Layer 2: Glass indicator with slide + motion blur
  Widget _buildGlassIndicator(double dockW) {
    final fromLeft = _indicatorLeft(dockW, _prevIndex);
    final toLeft = _indicatorLeft(dockW, widget.currentIndex);
    final width = _indicatorWidth(dockW);

    return AnimatedBuilder(
      animation: _slideCtrl,
      builder: (context, _) {
        final t = CurvedAnimation(
          parent: _slideCtrl,
          curve: _springCurve,
        ).value;
        final left = fromLeft + (toLeft - fromLeft) * t;

        // Motion blur: peak at t=0.5, clear at t=0 and t=1
        final blurProgress = (1.0 - (2.0 * t - 1.0).abs()).clamp(0.0, 1.0);
        final blurSigma = blurProgress * 6.0; // 0→6→0
        final bgAlpha = 0.45 - blurProgress * 0.20; // 0.45→0.25→0.45

        return Positioned(
          left: left,
          top: _dockPad,
          width: width,
          height: AppSpacing.dockHeight - _dockPad * 2,
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: BackdropFilter(
                filter: blurSigma > 0.5
                    ? ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma)
                    : ImageFilter.blur(sigmaX: 0.01, sigmaY: 0.01),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, bgAlpha),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: const Color(0x99FFFFFF), // rgba(255,255,255,0.60)
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inset top highlight
                      Positioned(
                        top: 0, left: 0, right: 0, height: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0x00FFFFFF), Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                      ),
                      // Specular gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            gradient: const LinearGradient(
                              begin: Alignment(-0.5, -0.87),
                              end: Alignment(0.5, 0.87),
                              colors: [Color(0x80FFFFFF), Color(0x00FFFFFF)],
                              stops: [0.0, 0.45],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Layer 3: Tab icon + label with scale bounce & color transition
  Widget _buildTab(int index) {
    return _TabButton(
      index: index,
      tab: _tabs[index],
      isTarget: index == widget.currentIndex,
      wasActive: index == _prevIndex,
      colorAnimation: _iconCtrl,
      onTap: () => widget.onTap(index),
    );
  }
}

// ── Tab Button with press scale (0.88) + spring recovery ────────────────────

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.index,
    required this.tab,
    required this.isTarget,
    required this.wasActive,
    required this.colorAnimation,
    required this.onTap,
  });

  final int index;
  final _TabDef tab;
  final bool isTarget;
  final bool wasActive;
  final AnimationController colorAnimation;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _pressCtrl,
        curve: Curves.easeOut,
        reverseCurve: const Cubic(0.34, 1.2, 0.64, 1.0),
      ),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, widget.colorAnimation]),
        builder: (context, _) {
          final t = CurvedAnimation(
            parent: widget.colorAnimation,
            curve: Curves.easeOut,
          ).value;

          Color iconColor;
          Color labelColor;
          double iconScale = 1.0;
          double iconDy = 0.0;
          FontWeight labelWeight = FontWeight.w400;
          bool showFilled = false;

          if (widget.isTarget) {
            iconColor = Color.lerp(AppColors.inkTertiary, AppColors.primary, t)!;
            labelColor = iconColor;
            iconScale = 1.0 + 0.12 * t;
            iconDy = -1.0 * t;
            labelWeight = t > 0.5 ? FontWeight.w500 : FontWeight.w400;
            showFilled = t > 0.3;
          } else if (widget.wasActive) {
            iconColor = Color.lerp(AppColors.primary, AppColors.inkTertiary, t)!;
            labelColor = iconColor;
            showFilled = t < 0.7;
          } else {
            iconColor = AppColors.inkTertiary;
            labelColor = AppColors.inkTertiary;
          }

          return Transform.scale(
            scale: _pressScale.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, iconDy),
                  child: Transform.scale(
                    scale: iconScale,
                    child: Icon(
                      showFilled ? widget.tab.filledIcon : widget.tab.outlinedIcon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  widget.tab.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: labelWeight,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
