// lib/features/schedule/presentation/widgets/day_sidebar.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class DaySidebar extends StatelessWidget {
  const DaySidebar({
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
      width: 66,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day == selectedDay;
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              height: 68,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBorder : Colors.transparent,
                ),
              ),
              child: Center(
                child: day == 0
                    ? Text(
                        '待规划',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'DAY',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.textDisabled,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? AppColors.primary : AppColors.textDisabled,
                              height: 1,
                            ),
                          ),
                          Text(
                            _weekLabel(day),
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : AppColors.textDisabled,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
