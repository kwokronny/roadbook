// lib/features/schedule/presentation/widgets/schedule_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({
    super.key,
    required this.schedule,
    required this.onTap,
    this.onClone,
    this.onDelete,
    this.canEdit = true,
  });

  final Schedule schedule;
  final VoidCallback onTap;
  final VoidCallback? onClone;
  final VoidCallback? onDelete;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final timeLabel = schedule.startTime != null
        ? timeFmt.format(schedule.startTime!.toLocal())
        : schedule.isHotel
            ? _hotelLabel()
            : '待规划';

    final shadowColor = schedule.isHotel
        ? const Color(0x148B5CF6)
        : const Color(0x14F97316);
    final borderColor = schedule.isHotel ? AppColors.hotel : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 左侧色条
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.card),
                    bottomLeft: Radius.circular(AppRadius.card),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 时间标签
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: schedule.isHotel ? AppColors.hotelLight : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.timeCell),
                            ),
                            child: Text(
                              timeLabel,
                              style: AppTextStyles.micro.copyWith(
                                color: schedule.isHotel ? AppColors.hotel : AppColors.primary,
                              ),
                            ),
                          ),
                          if (schedule.isHotel) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.hotelLight,
                                borderRadius: BorderRadius.circular(AppRadius.timeCell),
                                border: Border.all(color: AppColors.hotelBorder),
                              ),
                              child: Text('住宿',
                                  style: AppTextStyles.micro.copyWith(color: AppColors.hotel)),
                            ),
                          ],
                          const Spacer(),
                          if (canEdit)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz,
                                  size: 18, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                                if (onClone != null)
                                  const PopupMenuItem(value: 'clone', child: Text('克隆')),
                                if (onDelete != null)
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') onTap();
                                if (v == 'clone') onClone?.call();
                                if (v == 'delete') onDelete?.call();
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(schedule.name,
                          style: AppTextStyles.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (schedule.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(schedule.address,
                            style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(schedule.notes!,
                            style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      // 截图缩略图（最多 4 张，超出显示 +N）
                      if (schedule.screenshotList.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _ScreenshotThumbnails(urls: schedule.screenshotList),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hotelLabel() {
    if (schedule.startTime == null) return '待规划';
    if (schedule.endTime == null) return '入住';
    final checkIn = schedule.startTime!;
    final checkOut = schedule.endTime!;
    final nights = checkOut.difference(checkIn).inDays;
    return '${DateFormat('MM/dd').format(checkIn)}–${DateFormat('MM/dd').format(checkOut)} · $nights 晚';
  }
}

class _ScreenshotThumbnails extends StatelessWidget {
  const _ScreenshotThumbnails({required this.urls});
  final List<String> urls;

  static const _size = 42.0;
  static const _radius = 8.0;
  static const _gap = 6.0;
  static const _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    final visible = urls.take(_maxVisible).toList();
    final overflow = urls.length - _maxVisible;

    return Row(
      children: [
        for (final url in visible) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Image.network(
              url,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: _size,
                height: _size,
                color: AppColors.border,
                child: const Icon(Icons.broken_image_outlined,
                    size: 18, color: AppColors.textDisabled),
              ),
            ),
          ),
          const SizedBox(width: _gap),
        ],
        if (overflow > 0)
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Center(
              child: Text(
                '+$overflow',
                style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
