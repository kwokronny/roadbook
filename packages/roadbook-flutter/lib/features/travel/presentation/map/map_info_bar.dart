// lib/features/travel/presentation/map/map_info_bar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../features/schedule/presentation/widgets/schedule_nav_button.dart';
import '../../../../features/schedule/presentation/schedule_photo_viewer.dart';

final _timeFmt = DateFormat('HH:mm');

/// 底部信息条：两种工厂构造 — schedule（day 模式）和 poi（search 模式）
class MapInfoBar extends StatelessWidget {
  /// Schedule info bar — resembles timeline item style.
  const MapInfoBar._schedule({
    super.key,
    required this.schedule,
    required this.onEditTimeTap,
    required this.onTap,
  })  : poi = null,
        onAction = null,
        isLoading = false;

  /// POI info bar — for search mode.
  const MapInfoBar._poi({
    super.key,
    required this.poi,
    required VoidCallback onAdd,
    required this.isLoading,
  })  : schedule = null,
        onEditTimeTap = null,
        onTap = onAdd,
        onAction = onAdd;

  factory MapInfoBar.schedule({
    Key? key,
    required Schedule schedule,
    required VoidCallback onEditTimeTap,
    required VoidCallback onTap,
  }) {
    return MapInfoBar._schedule(
      key: key,
      schedule: schedule,
      onEditTimeTap: onEditTimeTap,
      onTap: onTap,
    );
  }

  factory MapInfoBar.poi({
    Key? key,
    required AmapPoi poi,
    required VoidCallback onAdd,
    required bool isAdding,
  }) {
    return MapInfoBar._poi(
      key: key,
      poi: poi,
      onAdd: onAdd,
      isLoading: isAdding,
    );
  }

  final Schedule? schedule;
  final AmapPoi? poi;
  final VoidCallback? onEditTimeTap;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        top: false,
        child: schedule != null
            ? _buildScheduleContent(context)
            : _buildPoiContent(context),
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context) {
    final s = schedule!;
    final isHotel = s.isHotel;
    final accentColor = isHotel
        ? AppColors.hotel
        : s.startTime != null
            ? AppColors.primary
            : AppColors.textSecondary;

    String timeLabel;
    if (isHotel) {
      final start = s.startTime != null ? '入住 ${_timeFmt.format(s.startTime!.toLocal())}' : null;
      final end = s.endTime != null ? '退房 ${_timeFmt.format(s.endTime!.toLocal())}' : null;
      timeLabel = start ?? end ?? '住宿';
    } else {
      timeLabel = s.startTime != null
          ? _timeFmt.format(s.startTime!.toLocal())
          : '待规划';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          _CoverImage(schedule: s),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time row — tappable
                GestureDetector(
                  onTap: onEditTimeTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          height: 1,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dashed,
                          decorationColor: accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.schedule, size: 16, color: accentColor),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Name + address + nav button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.name,
                              style: AppTextStyles.appBarTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (s.address.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                s.address,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScheduleNavButton(
                      coordinate: s.coordinate,
                      name: s.name,
                      isHotel: isHotel,
                    ),
                  ],
                ),
                // Notes
                if (s.notes != null && s.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.notes, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.notes!,
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Screenshots
                if (s.screenshotList.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildScreenshots(context, s),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoiContent(BuildContext context) {
    final p = poi!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: AppTextStyles.cardTitle,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(p.address,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
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
                      '+ 加入待规划',
                      style: AppTextStyles.micro.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  static const _maxThumbs = 4;

  Widget _buildScreenshots(BuildContext context, Schedule s) {
    final urls = s.screenshotList;
    final visible = urls.take(_maxThumbs).toList();
    final overflow = urls.length - _maxThumbs;

    return Row(
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          GestureDetector(
            onTap: () => SchedulePhotoViewer.show(
              context,
              urls: urls,
              scheduleName: s.name,
              initialIndex: i,
            ),
            child: SizedBox(
              width: 36,
              height: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.timeCell),
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
              borderRadius: BorderRadius.circular(AppRadius.timeCell),
            ),
            child: Center(
              child: Text('+$overflow',
                  style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

// ─── Cover Image (same as timeline item) ─────────────────────────────────────

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
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
