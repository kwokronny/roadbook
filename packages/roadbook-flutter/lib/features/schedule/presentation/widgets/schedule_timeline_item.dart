// lib/features/schedule/presentation/widgets/schedule_timeline_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../schedule_photo_viewer.dart';
import 'schedule_nav_button.dart';

class ScheduleTimelineItem extends StatelessWidget {
  const ScheduleTimelineItem({
    super.key,
    required this.schedule,
    required this.travelStartDate,
    required this.canEdit,
    this.displayDay,
    this.onEditTimeTap,
    this.onEdit,
    this.onClone,
    this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onToggleSelect,
  });

  final Schedule schedule;
  final DateTime travelStartDate;
  final bool canEdit;
  final int? displayDay;  // 当前显示的天（0=待规划, 1-N=第N天）
  final VoidCallback? onEditTimeTap;
  final VoidCallback? onEdit;
  final VoidCallback? onClone;
  final VoidCallback? onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleSelect;

  static const _maxThumbs = 4;
  static final _timeFmt = DateFormat('HH:mm');

  int? get _checkInDay {
    if (!schedule.isHotel || schedule.startTime == null) return null;
    return schedule.startTime!.toLocal().difference(travelStartDate).inDays + 1;
  }

  int? get _checkOutDay {
    if (!schedule.isHotel || schedule.endTime == null) return null;
    return schedule.endTime!.toLocal().difference(travelStartDate).inDays + 1;
  }

  String get _timeLabel {
    if (displayDay == 0) return '待规划';
    if (schedule.isHotel) {
      final d = displayDay;
      if (d != null && d > 0) {
        if (d == _checkInDay && schedule.startTime != null) {
          return '入住 ${_timeFmt.format(schedule.startTime!.toLocal())}';
        }
        if (d == _checkOutDay && schedule.endTime != null) {
          return '退房 ${_timeFmt.format(schedule.endTime!.toLocal())}';
        }
      }
      return '住宿';
    }
    if (schedule.startTime == null) return '待规划';
    return _timeFmt.format(schedule.startTime!.toLocal());
  }

  Color get _accentColor {
    if (displayDay == 0) return AppColors.textSecondary;
    if (schedule.isHotel) return AppColors.hotel;
    if (schedule.startTime == null) return AppColors.textSecondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionMode ? onToggleSelect : null,
      child: Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 6),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            )
          else
            GestureDetector(
              onLongPress: canEdit ? onLongPress : null,
              child: _CoverImage(schedule: schedule),
            ),
          if (isSelectionMode)
            _CoverImage(schedule: schedule),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeRow(context),
                const SizedBox(height: 8),
                // ── 名称+地址 与 导航按钮 同一容器
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.name,
                            style: AppTextStyles.appBarTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (schedule.address.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              schedule.address,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScheduleNavButton(
                      coordinate: schedule.coordinate,
                      name: schedule.name,
                      isHotel: schedule.isHotel,
                    ),
                  ],
                ),
                if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EDE8),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notes, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            schedule.notes!,
                            style: AppTextStyles.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (schedule.screenshotList.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildScreenshots(context),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildTimeRow(BuildContext context) {
    return Row(
      children: [
        // Time label + edit icon
        GestureDetector(
          onTap: canEdit ? onEditTimeTap : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeLabel,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
                  height: 1,
                  decoration: canEdit ? TextDecoration.underline : null,
                  decorationStyle: TextDecorationStyle.dashed,
                  decorationColor: _accentColor.withValues(alpha: 0.4),
                ),
              ),
              if (canEdit) ...[
                const SizedBox(width: 5),
                Icon(Icons.schedule, key: const Key('editIcon'), size: 18, color: _accentColor),
              ],
            ],
          ),
        ),
        const Spacer(),
        // More dropdown (only when canEdit)
        if (canEdit)
          _MoreMenu(
            accentColor: _accentColor,
            isHotel: schedule.isHotel,
            hasStartTime: schedule.startTime != null,
            onEdit: onEdit,
            onClone: onClone,
            onDelete: onDelete,
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

// ─── More Dropdown ────────────────────────────────────────────────────────────

enum _MenuAction { edit, clone, delete }

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({
    required this.accentColor,
    required this.isHotel,
    required this.hasStartTime,
    this.onEdit,
    this.onClone,
    this.onDelete,
  });

  final Color accentColor;
  final bool isHotel;
  final bool hasStartTime;
  final VoidCallback? onEdit;
  final VoidCallback? onClone;
  final VoidCallback? onDelete;

  Color get _bgColor => isHotel ? AppColors.hotelLight : AppColors.primaryLight;
  Color get _borderColor => isHotel ? AppColors.hotelBorder : AppColors.primaryBorder;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:   onEdit?.call();
          case _MenuAction.clone:  onClone?.call();
          case _MenuAction.delete: onDelete?.call();
        }
      },
      offset: const Offset(0, 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      color: AppColors.surface,
      elevation: 4,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _MenuAction.edit,
          height: 40,
          child: Row(children: [
            const Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Text('编辑', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w400)),
          ]),
        ),
        PopupMenuItem(
          value: _MenuAction.clone,
          height: 40,
          child: Row(children: [
            const Icon(Icons.copy_outlined, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Text('克隆', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w400)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: _MenuAction.delete,
          height: 40,
          child: Row(children: [
            const Icon(Icons.delete_outline, size: 16, color: Colors.red),
            const SizedBox(width: 10),
            Text('删除', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w400, color: Colors.red)),
          ]),
        ),
      ],
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(Icons.more_horiz, size: 18, color: accentColor),
      ),
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
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
