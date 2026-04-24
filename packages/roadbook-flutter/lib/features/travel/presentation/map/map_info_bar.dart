// lib/features/travel/presentation/map/map_info_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../features/schedule/presentation/widgets/schedule_nav_button.dart';
import '../../../../features/schedule/presentation/schedule_photo_viewer.dart';
import '../../../../shared/widgets/glass_popover.dart';
import 'package:hugeicons/hugeicons.dart';

final _timeFmt = DateFormat('HH:mm');

void _showNotesDialog(BuildContext context, String title, String notes) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xB3FFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x80FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkPrimary)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 26, height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0x1A1C1C1E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(HugeIcons.strokeRoundedCancel01, size: 12,
                            color: AppColors.inkSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(notes,
                      style: const TextStyle(fontSize: 14,
                          color: AppColors.inkSecondary,
                          fontStyle: FontStyle.italic, height: 1.6)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// 底部信息条：两种工厂构造 — schedule（day 模式）和 poi（search 模式）
class MapInfoBar extends StatelessWidget {
  /// Schedule info bar — resembles timeline item style.
  const MapInfoBar._schedule({
    super.key,
    required this.schedule,
    required this.onEditTimeTap,
    required this.onTap,
    this.isAbroad = false,
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
        onAction = onAdd,
        isAbroad = false;

  factory MapInfoBar.schedule({
    Key? key,
    required Schedule schedule,
    required VoidCallback onEditTimeTap,
    required VoidCallback onTap,
    bool isAbroad = false,
  }) {
    return MapInfoBar._schedule(
      key: key,
      schedule: schedule,
      onEditTimeTap: onEditTimeTap,
      onTap: onTap,
      isAbroad: isAbroad,
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
  final bool isAbroad;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.cardSm),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x99FFFFFF), // 60%
            borderRadius: BorderRadius.circular(AppRadius.cardSm),
            border: Border.all(color: const Color(0x80FFFFFF)),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2)),
            ],
          ),
          child: schedule != null
              ? _buildScheduleContent(context)
              : _buildPoiContent(context),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context) {
    final s = schedule!;
    final isHotel = s.isHotel;

    // Time pill colors (same as schedule card)
    final Color timeBg;
    final Color timeTxt;
    if (isHotel) {
      timeBg = AppColors.lavenderTint;
      timeTxt = AppColors.lavenderText;
    } else if (s.startTime != null) {
      timeBg = AppColors.coralTint;
      timeTxt = const Color(0xFFD4410A);
    } else {
      timeBg = const Color(0x0D1C1C1E);
      timeTxt = AppColors.inkTertiary;
    }

    String timeLabel;
    if (isHotel) {
      timeLabel = s.startTime != null
          ? '入住 ${_timeFmt.format(s.startTime!.toLocal())}'
          : '住宿';
    } else {
      timeLabel = s.startTime != null
          ? _timeFmt.format(s.startTime!.toLocal())
          : '待规划';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: time pill + nav circle
        Row(
          children: [
            // Time pill (tappable to edit)
            GestureDetector(
              onTap: onEditTimeTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: timeBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timeLabel,
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500, color: timeTxt)),
                    const SizedBox(width: 3),
                    Icon(HugeIcons.strokeRoundedCalendarSetting01, size: 12, color: timeTxt),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // More button (glass popover)
            if (onTap != null)
              Builder(builder: (ctx) {
                return GestureDetector(
                  onTap: () {
                    final box = ctx.findRenderObject() as RenderBox;
                    final pos = box.localToGlobal(Offset.zero);
                    showGlassPopover(
                      context: ctx,
                      position: RelativeRect.fromLTRB(
                          pos.dx, pos.dy + 32,
                          MediaQuery.of(ctx).size.width - pos.dx - box.size.width,
                          0),
                      items: [
                        PopoverItem(icon: HugeIcons.strokeRoundedEdit01, label: '编辑', onTap: () => onTap!()),
                        PopoverItem(icon: HugeIcons.strokeRoundedDelete01, label: '删除', isDestructive: true,
                            onTap: () => onAction?.call()),
                      ],
                    );
                  },
                  child: const Icon(HugeIcons.strokeRoundedMoreHorizontal, size: 24,
                      color: AppColors.inkTertiary),
                );
              }),
            // Nav circle button
            if (s.coordinate.isNotEmpty && s.coordinate != '0,0') ...[
              const SizedBox(width: 8),
              _NavCircle(coordinate: s.coordinate, name: s.name, isHotel: isHotel, isAbroad: isAbroad),
            ],
          ],
        ),
        const SizedBox(height: 4),
        // Name (not tappable — use more button to edit)
        Text(
          s.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500,
              color: AppColors.inkPrimary),
          maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
        // Address
        if (s.address.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(s.address,
              style: const TextStyle(fontSize: 12, color: AppColors.inkTertiary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
        // Screenshots
        if (s.screenshotList.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            for (int i = 0; i < s.screenshotList.take(3).length; i++) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(s.screenshotList[i],
                    width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0x0D1C1C1E),
                        borderRadius: BorderRadius.circular(6)))),
              ),
              if (i < 2) const SizedBox(width: 6),
            ],
          ]),
        ],
        // View notes
        if (s.notes != null && s.notes!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showNotesDialog(context, s.name, s.notes!),
              child: const Text('查看备注 ›',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.primary)),
            ),
          ),
        ],
      ],
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
                        fontWeight: FontWeight.w500,
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
                    child: const Icon(HugeIcons.strokeRoundedImageNotFound01,
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
                  style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w500)),
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
    if (schedule.isHotel) return const Color(0x268C5CF6);
    if (schedule.startTime == null) return const Color(0x0F1C1C1E);
    return const Color(0x1FFF6B3D);
  }

  Color get _defaultBg {
    if (schedule.isHotel) return AppColors.lavenderTint;
    if (schedule.startTime == null) return const Color(0x0A1C1C1E);
    return const Color(0x14FF6B3D);
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

// ── Circular navigation button ──────────────────────────────────────────────

class _NavCircle extends StatelessWidget {
  const _NavCircle({
    required this.coordinate,
    required this.name,
    required this.isHotel,
    this.isAbroad = false,
  });
  final String coordinate;
  final String name;
  final bool isHotel;
  final bool isAbroad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36, height: 36,
      child: ScheduleNavButton(
        coordinate: coordinate,
        name: name,
        isHotel: isHotel,
        isAbroad: isAbroad,
        compact: true,
      ),
    );
  }
}
