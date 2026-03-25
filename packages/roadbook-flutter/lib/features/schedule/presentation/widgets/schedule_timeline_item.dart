// lib/features/schedule/presentation/widgets/schedule_timeline_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../schedule_photo_viewer.dart';

class ScheduleTimelineItem extends StatelessWidget {
  const ScheduleTimelineItem({
    super.key,
    required this.schedule,
    required this.travelStartDate,
    required this.canEdit,
    this.onEditTimeTap,
    this.onMoreTap,
  });

  final Schedule schedule;
  final DateTime travelStartDate;
  final bool canEdit;
  final VoidCallback? onEditTimeTap;
  final VoidCallback? onMoreTap;

  static const _maxThumbs = 4;

  String get _timeLabel {
    if (schedule.isHotel) return '住宿';
    if (schedule.startTime == null) return '待规划';
    return DateFormat('HH:mm').format(schedule.startTime!.toLocal());
  }

  Color get _accentColor {
    if (schedule.isHotel) return AppColors.hotel;
    if (schedule.startTime == null) return AppColors.textSecondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover image (replaces dot)
          _CoverImage(schedule: schedule),
          const SizedBox(width: 10),
          // ── Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time row
                _buildTimeRow(context),
                const SizedBox(height: 3),
                // Name
                Text(
                  schedule.name,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Address
                if (schedule.address.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    schedule.address,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Screenshots
                if (schedule.screenshotList.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildScreenshots(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context) {
    return Row(
      children: [
        // Time + edit icon (tappable area)
        GestureDetector(
          onTap: canEdit ? onEditTimeTap : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
                  height: 1,
                ),
              ),
              if (canEdit) ...[
                const SizedBox(width: 5),
                Container(
                  key: const Key('editIcon'),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: schedule.isHotel
                        ? AppColors.hotelLight
                        : schedule.startTime == null
                            ? const Color(0xFFF5F5F4)
                            : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: schedule.isHotel
                          ? AppColors.hotelBorder
                          : schedule.startTime == null
                              ? const Color(0xFFE8E0D8)
                              : AppColors.primaryBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 10,
                    color: _accentColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: schedule.isHotel
                    ? AppColors.hotelLight
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: schedule.isHotel
                      ? AppColors.hotelBorder
                      : AppColors.primaryBorder,
                ),
              ),
              child: Icon(Icons.more_horiz,
                  size: 14, color: _accentColor),
            ),
          ),
      ],
    );
  }

  Widget _buildScreenshots(BuildContext context) {
    final urls = schedule.screenshotList;
    final visible = urls.take(_maxThumbs).toList();
    final overflow = urls.length - _maxThumbs;

    return Row(
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          GestureDetector(
            onTap: () => SchedulePhotoViewer.show(
              context,
              urls: urls,
              scheduleName: schedule.name,
              initialIndex: i,
            ),
            child: SizedBox(
              key: const Key('screenshotThumb'),
              width: 36,
              height: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  visible[i],
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: AppColors.border,
                    child: const Icon(Icons.broken_image_outlined,
                        size: 14, color: AppColors.textDisabled),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (overflow > 0)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('+$overflow',
                  style: AppTextStyles.micro
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

// ─── Cover Image ──────────────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.schedule});
  final Schedule schedule;

  Color get _borderColor {
    if (schedule.isHotel) return AppColors.hotel;
    if (schedule.startTime == null) return AppColors.unplanned;
    return AppColors.primary;
  }

  Color get _defaultBg {
    if (schedule.isHotel) return AppColors.hotelLight;
    if (schedule.startTime == null) return AppColors.unplannedLight;
    return const Color(0xFFFEE2C8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 2),
        color: _defaultBg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: schedule.cover != null && schedule.cover!.isNotEmpty
            ? Image.network(
                schedule.cover!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _DefaultIcon(schedule: schedule),
              )
            : _DefaultIcon(schedule: schedule),
      ),
    );
  }
}

class _DefaultIcon extends StatelessWidget {
  const _DefaultIcon({required this.schedule});
  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        schedule.isHotel ? '🏨' : '📍',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
