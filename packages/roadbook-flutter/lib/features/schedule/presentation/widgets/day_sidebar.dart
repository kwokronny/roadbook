// lib/features/schedule/presentation/widgets/day_sidebar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class DayBar extends StatelessWidget {
  const DayBar({
    super.key,
    required this.totalDays,
    required this.selectedDay,
    required this.travelStartDate,
    required this.onDaySelected,
  });

  final int totalDays;
  final int selectedDay;
  final DateTime travelStartDate;
  final ValueChanged<int> onDaySelected;

  static const _weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  String _weekLabel(int day) {
    final date = travelStartDate.add(Duration(days: day - 1));
    return _weekLabels[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = [for (int d = 1; d <= totalDays; d++) d, 0];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day == selectedDay;
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: _DayChip(
              day: day,
              weekLabel: day > 0 ? _weekLabel(day) : null,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, this.weekLabel, required this.isSelected});
  final int day;
  final String? weekLabel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: isSelected
            ? ImageFilter.blur(sigmaX: 16, sigmaY: 16)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x99FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? const Color(0xE6FFFFFF) : Colors.transparent,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0x1A6478B4), blurRadius: 12, offset: Offset(0, 2)),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day == 0 ? '待规划' : 'Day $day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : const Color(0x4D1E243C),
                ),
              ),
              if (weekLabel != null)
                Text(
                  weekLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.55)
                        : const Color(0x381E243C),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
