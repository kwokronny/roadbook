// lib/features/travel/presentation/map/map_info_bar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/models/amap_poi.dart';

final _timeFmt = DateFormat('HH:mm');

/// 底部信息条：两种工厂构造 — schedule（day 模式）和 poi（search 模式）
class MapInfoBar extends StatelessWidget {
  const MapInfoBar._({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  factory MapInfoBar.schedule({
    Key? key,
    required Schedule schedule,
    required VoidCallback onTap,
  }) {
    final start = schedule.startTime != null ? _timeFmt.format(schedule.startTime!) : null;
    final end = schedule.endTime != null ? _timeFmt.format(schedule.endTime!) : null;
    final time = (start != null && end != null)
        ? '$start — $end'
        : start ?? '待规划';
    return MapInfoBar._(
      key: key,
      title: schedule.name,
      subtitle: time,
      onTap: onTap,
    );
  }

  factory MapInfoBar.poi({
    Key? key,
    required AmapPoi poi,
    required VoidCallback onAdd,
    required bool isAdding,
  }) {
    return MapInfoBar._(
      key: key,
      title: poi.name,
      subtitle: poi.address,
      onTap: onAdd,
      actionLabel: '+ 加入待规划',
      onAction: onAdd,
      isLoading: isAdding,
    );
  }

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.cardTitle,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 12),
              isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          actionLabel!,
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ] else
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
