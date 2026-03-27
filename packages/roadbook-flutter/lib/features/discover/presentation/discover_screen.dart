// lib/features/discover/presentation/discover_screen.dart
//
// Placeholder — full implementation in Plan 2.
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('发现', style: AppTextStyles.largeTitle),
              const SizedBox(height: 24),
              Center(
                child: Text('发现页 — 即将推出',
                    style: AppTextStyles.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
