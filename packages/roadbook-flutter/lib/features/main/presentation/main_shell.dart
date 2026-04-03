// lib/features/main/presentation/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/pastel_mesh_background.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static final _hideNavPattern = RegExp(r'^/travel/\d+');

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final hideNav = _hideNavPattern.hasMatch(location);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PastelMeshBackground(),
          navigationShell,
          if (!hideNav)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: _FloatingIslandNav(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Floating Island Navigation ─────────────────────────────────────────────

class _FloatingIslandNav extends StatelessWidget {
  const _FloatingIslandNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  static const _tabs = [
    _TabItem(outlinedIcon: Icons.map_outlined,    filledIcon: Icons.map,    label: '旅程'),
    _TabItem(outlinedIcon: Icons.explore_outlined, filledIcon: Icons.explore, label: '发现'),
    _TabItem(outlinedIcon: Icons.person_outline,   filledIcon: Icons.person,  label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: GlassSpec.navShadow,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? tab.filledIcon : tab.outlinedIcon,
                            size: 22,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.outlinedIcon, required this.filledIcon, required this.label});
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
}
