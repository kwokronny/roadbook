// lib/features/travel/presentation/widgets/travel_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';

enum TravelStatus { upcoming, ongoing, ended }

TravelStatus computeTravelStatus(DateTime start, DateTime end) {
  final now = DateTime.now();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  final today = DateTime(now.year, now.month, now.day);
  if (today.isBefore(startDay)) return TravelStatus.upcoming;
  if (today.isAfter(endDay)) return TravelStatus.ended;
  return TravelStatus.ongoing;
}

class TravelCard extends StatelessWidget {
  const TravelCard({
    super.key,
    required this.travel,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Travel travel;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = computeTravelStatus(travel.startDate, travel.endDate);
    final days = travel.endDate.difference(travel.startDate).inDays + 1;
    final fmt = DateFormat('MM/dd');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap / 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x081C1917),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部行：名称 + 操作菜单
              Row(
                children: [
                  Expanded(
                    child: Text(
                      travel.name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz,
                          size: 18, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      itemBuilder: (_) => [
                        if (onEdit != null)
                          const PopupMenuItem(value: 'edit', child: Text('编辑')),
                        if (onDelete != null)
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除',
                                  style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // 日期范围 + 天数
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${fmt.format(travel.startDate)} — ${fmt.format(travel.endDate)}  ·  $days 天',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              // 城市
              if (travel.cities.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        travel.cities.join(' · '),
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              // 状态徽章
              _StatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TravelStatus status;

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color textColor;
    late Color borderColor;

    switch (status) {
      case TravelStatus.upcoming:
        label = '待出发';
        bg = AppColors.primaryLight;
        textColor = AppColors.primary;
        borderColor = AppColors.primaryBorder;
      case TravelStatus.ongoing:
        label = '旅行中';
        bg = AppColors.successLight;
        textColor = AppColors.success;
        borderColor = const Color(0xFFA7F3D0);
      case TravelStatus.ended:
        label = '已结束';
        bg = const Color(0xFFF5F5F4);
        textColor = AppColors.neutral;
        borderColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: borderColor),
      ),
      child: Text(label, style: AppTextStyles.micro.copyWith(color: textColor)),
    );
  }
}
