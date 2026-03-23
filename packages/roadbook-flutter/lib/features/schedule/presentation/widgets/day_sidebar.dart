// lib/features/schedule/presentation/widgets/day_sidebar.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class DaySidebar extends StatelessWidget {
  const DaySidebar({
    super.key,
    required this.totalDays,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final int totalDays;        // 旅行总天数
  final int selectedDay;      // 0 = 待规划，1-N = 第 N 天
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    // 1..totalDays + 0（待规划）
    final days = [for (int d = 1; d <= totalDays; d++) d, 0];

    return SizedBox(
      width: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day == selectedDay;
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBorder : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  day == 0 ? '?' : '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
