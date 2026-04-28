// lib/features/travel/presentation/map/map_day_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class MapDaySelectorBar extends ConsumerWidget {
  const MapDaySelectorBar({
    super.key,
    required this.travelId,
    required this.totalDays,
    required this.onSearchTap,
  });

  final int travelId;
  final int totalDays;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(mapSelectedDayProvider(travelId));

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          _SearchButton(onTap: onSearchTap),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DayChip(
              label: '全部',
              selected: selectedDay == -1,
              onTap: () => ref
                  .read(mapSelectedDayProvider(travelId).notifier)
                  .state = -1,
            ),
          ),
          for (int day = 1; day <= totalDays; day++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DayChip(
                label: 'Day $day',
                selected: selectedDay == day,
                onTap: () => ref
                    .read(mapSelectedDayProvider(travelId).notifier)
                    .state = day,
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : const Color(0xB3FFFFFF), // rgba(255,255,255,0.70)
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected
              ? [BoxShadow(
                  color: AppColors.coralGlow,
                  blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : AppColors.inkSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xB3FFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: const Center(child: Icon(HugeIcons.strokeRoundedSearch01, size: 20, color: AppColors.inkSecondary)),
      ),
    );
  }
}
