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
  final int? displayDay;
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

  Color get _tintBg {
    if (schedule.isHotel) return const Color(0x0D8B5CF6); // lavender tint
    return const Color(0x0DFF5B2E); // coral tint
  }

  Color get _navBg {
    if (schedule.isHotel) return AppColors.hotelLight;
    return AppColors.primaryLight;
  }

  Color get _navBorder {
    if (schedule.isHotel) return AppColors.hotelBorder;
    return AppColors.primaryBorder;
  }

  Color get _navIcon {
    if (schedule.isHotel) return AppColors.hotel;
    return AppColors.primary;
  }

  bool get _hasExtras =>
      (schedule.notes != null && schedule.notes!.isNotEmpty) ||
      schedule.screenshotList.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionMode ? onToggleSelect : null,
      onLongPress: canEdit && !isSelectionMode ? onLongPress : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Glass card
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: BackdropFilter(
                filter: GlassSpec.cardBlur,
                child: Container(
                  decoration: BoxDecoration(
                    color: schedule.isHotel
                        ? const Color(0x80F5F3FF) // lavender tint overlay
                        : GlassSpec.cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: GlassSpec.cardBorder),
                    boxShadow: GlassSpec.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Upper section: cover + info + nav
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selection checkbox or cover
                            if (isSelectionMode)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, right: 10),
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 24,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            // Cover image
                            _CoverImage(schedule: schedule),
                            const SizedBox(width: 12),
                            // Center: time pill + name + address
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time pill badge
                                  GestureDetector(
                                    onTap: canEdit ? onEditTimeTap : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withValues(alpha: 0.10),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.pill),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _timeLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _accentColor,
                                            ),
                                          ),
                                          if (canEdit) ...[
                                            const SizedBox(width: 3),
                                            Icon(Icons.schedule,
                                                size: 12, color: _accentColor),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Name + address row with nav button
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              schedule.name,
                                              style: AppTextStyles.headline,
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
                                      if (!isSelectionMode) ...[
                                        const SizedBox(width: 8),
                                        _GlassNavButton(
                                          coordinate: schedule.coordinate,
                                          name: schedule.name,
                                          isHotel: schedule.isHotel,
                                          bgColor: _navBg,
                                          borderColor: _navBorder,
                                          iconColor: _navIcon,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Lower section: dashed divider + notes/screenshots
                      if (_hasExtras) ...[
                        // Dashed divider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: CustomPaint(
                            painter: _DashedLinePainter(
                              color: AppColors.border,
                            ),
                            size: const Size(double.infinity, 1),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                          decoration: BoxDecoration(
                            color: _tintBg,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(AppRadius.card),
                              bottomRight: Radius.circular(AppRadius.card),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Screenshots first
                              if (schedule.screenshotList.isNotEmpty) ...[
                                _buildScreenshots(context),
                              ],
                              if (schedule.screenshotList.isNotEmpty &&
                                  schedule.notes != null &&
                                  schedule.notes!.isNotEmpty)
                                const SizedBox(height: 6),
                              // Notes
                              if (schedule.notes != null &&
                                  schedule.notes!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.notes,
                                        size: 14,
                                        color: AppColors.textSecondary),
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
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // ── More button (top-right, with concave mask cutout)
            if (canEdit && !isSelectionMode)
              Positioned(
                top: -4,
                right: -4,
                child: _ConcaveMoreButton(
                  accentColor: _accentColor,
                  isHotel: schedule.isHotel,
                  hasStartTime: schedule.startTime != null,
                  onEdit: onEdit,
                  onClone: onClone,
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
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
                  style: AppTextStyles.micro
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

// ─── Concave More Button ─────────────────────────────────────────────────────

enum _MenuAction { edit, clone, delete }

class _ConcaveMoreButton extends StatelessWidget {
  const _ConcaveMoreButton({
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

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:
            onEdit?.call();
          case _MenuAction.clone:
            onClone?.call();
          case _MenuAction.delete:
            onDelete?.call();
        }
      },
      offset: const Offset(0, 30),
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
            const Icon(Icons.edit_outlined,
                size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Text('编辑',
                style: AppTextStyles.cardTitle
                    .copyWith(fontWeight: FontWeight.w400)),
          ]),
        ),
        PopupMenuItem(
          value: _MenuAction.clone,
          height: 40,
          child: Row(children: [
            const Icon(Icons.copy_outlined,
                size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Text('克隆',
                style: AppTextStyles.cardTitle
                    .copyWith(fontWeight: FontWeight.w400)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: _MenuAction.delete,
          height: 40,
          child: Row(children: [
            const Icon(Icons.delete_outline, size: 16, color: Colors.red),
            const SizedBox(width: 10),
            Text('删除',
                style: AppTextStyles.cardTitle
                    .copyWith(fontWeight: FontWeight.w400, color: Colors.red)),
          ]),
        ),
      ],
      child: CustomPaint(
        painter: _ConcaveMaskPainter(),
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: Icon(Icons.more_horiz, size: 16, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Draws a 30px circle with concave cutout mask on bottom-left
class _ConcaveMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 15.0;

    // Circle fill
    final fillPaint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Circle border
    final borderPaint = Paint()
      ..color = const Color(0xE6FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Glass Nav Button (38x38 rounded square) ─────────────────────────────────

class _GlassNavButton extends StatelessWidget {
  const _GlassNavButton({
    required this.coordinate,
    required this.name,
    required this.isHotel,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  final String coordinate;
  final String name;
  final bool isHotel;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: ScheduleNavButton(
        coordinate: coordinate,
        name: name,
        isHotel: isHotel,
      ),
    );
  }
}

// ─── Dashed Line Painter ─────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Cover Image (56x56) ─────────────────────────────────────────────────────

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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 2),
        color: _defaultBg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: schedule.cover != null && schedule.cover!.isNotEmpty
            ? Image.network(
                schedule.cover!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _DefaultIcon(schedule: schedule),
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
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}
