// lib/features/main/presentation/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
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
      decoration: const BoxDecoration(
        color: Color(0xF0F9F9F9), // rgba(249,249,249,0.94)
        border: Border(
          top: BorderSide(color: Color(0x1A000000), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.filledIcon : tab.outlinedIcon,
                        size: 24,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
  });
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
}
