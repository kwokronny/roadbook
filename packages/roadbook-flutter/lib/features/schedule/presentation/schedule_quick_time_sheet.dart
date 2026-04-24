// lib/features/schedule/presentation/schedule_quick_time_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';

import '../../../shared/models/schedule.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/widgets/app_toast.dart';
import '../domain/schedule_provider.dart';
import 'package:hugeicons/hugeicons.dart';

// ─── Pure logic helpers (exported for testing) ────────────────────────────────

enum HotelHourPhase { awaitingCheckIn, awaitingCheckOut, complete }

class HotelHourRangeState {
  const HotelHourRangeState({
    required this.checkInHour,
    required this.checkOutHour,
    required this.phase,
  });

  final int? checkInHour;
  final int? checkOutHour;
  final HotelHourPhase phase;

  factory HotelHourRangeState.empty() => const HotelHourRangeState(
        checkInHour: null,
        checkOutHour: null,
        phase: HotelHourPhase.awaitingCheckIn,
      );

  HotelHourRangeState tap(int hour) {
    switch (phase) {
      case HotelHourPhase.awaitingCheckIn:
        return HotelHourRangeState(
          checkInHour: hour,
          checkOutHour: null,
          phase: HotelHourPhase.awaitingCheckOut,
        );
      case HotelHourPhase.awaitingCheckOut:
        return HotelHourRangeState(
          checkInHour: checkInHour,
          checkOutHour: hour,
          phase: HotelHourPhase.complete,
        );
      case HotelHourPhase.complete:
        return HotelHourRangeState.empty();
    }
  }

  bool isInRange(int hour) {
    if (phase != HotelHourPhase.complete) return false;
    return hour > checkInHour! && hour < checkOutHour!;
  }
}

/// 普通行程：计算 startTime。selectedDay=0 → null（待规划）
DateTime? buildStartTime({
  required DateTime travelStart,
  required int selectedDay,
  required int? selectedHour,
}) {
  if (selectedDay == 0) return null;
  final base = travelStart.add(Duration(days: selectedDay - 1));
  return DateTime(base.year, base.month, base.day, selectedHour ?? 0, 0, 0);
}

/// 住宿：计算 startTime 或 endTime。无 hour 时默认正午。
DateTime buildHotelDateTime({
  required DateTime travelStart,
  required int day,
  required int? hour,
}) {
  final base = travelStart.add(Duration(days: day - 1));
  return DateTime(base.year, base.month, base.day, hour ?? 12, 0, 0);
}

// ─── Sheet entry point ────────────────────────────────────────────────────────

class ScheduleQuickTimeSheet extends ConsumerStatefulWidget {
  const ScheduleQuickTimeSheet({
    super.key,
    required this.travel,
    required this.schedule,
  });

  final Travel travel;
  final Schedule schedule;

  static Future<void> show(
    BuildContext context, {
    required Travel travel,
    required Schedule schedule,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ScheduleQuickTimeSheet(travel: travel, schedule: schedule),
    );
  }

  @override
  ConsumerState<ScheduleQuickTimeSheet> createState() =>
      _ScheduleQuickTimeSheetState();
}

class _ScheduleQuickTimeSheetState
    extends ConsumerState<ScheduleQuickTimeSheet> {
  // ── Regular schedule state
  late int? _selectedDay;
  late int? _selectedHour;

  // ── Hotel state
  late int? _checkInDay;
  late int? _checkOutDay;
  bool _hotelDayIsCheckIn = true;
  late HotelHourRangeState _hourRange;

  bool _saving = false;

  int get _totalDays =>
      widget.travel.endDate.difference(widget.travel.startDate).inDays + 1;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    final start = widget.travel.startDate;
    if (s.isHotel) {
      _checkInDay = s.startTime != null
          ? s.startTime!.toLocal().difference(start).inDays + 1
          : null;
      _checkOutDay = s.endTime != null
          ? s.endTime!.toLocal().difference(start).inDays + 1
          : null;
      _hotelDayIsCheckIn = true;
      _selectedDay = null;
      _selectedHour = null;
      final inHour = s.startTime?.toLocal().hour;
      final outHour = s.endTime?.toLocal().hour;
      if (inHour != null && outHour != null) {
        _hourRange = HotelHourRangeState(
          checkInHour: inHour,
          checkOutHour: outHour,
          phase: HotelHourPhase.complete,
        );
      } else if (inHour != null) {
        _hourRange = HotelHourRangeState(
          checkInHour: inHour,
          checkOutHour: null,
          phase: HotelHourPhase.awaitingCheckOut,
        );
      } else {
        _hourRange = HotelHourRangeState.empty();
      }
    } else {
      if (s.startTime != null) {
        _selectedDay = s.startTime!.toLocal().difference(start).inDays + 1;
        _selectedHour = s.startTime!.toLocal().hour;
      } else {
        _selectedDay = 0;
        _selectedHour = null;
      }
      _checkInDay = null;
      _checkOutDay = null;
      _hourRange = HotelHourRangeState.empty();
    }
  }

  void _onHotelDayTap(int day) {
    if (day == 0) return;
    setState(() {
      if (_hotelDayIsCheckIn) {
        _checkInDay = day;
        _checkOutDay = null;
        _hotelDayIsCheckIn = false;
      } else {
        _checkOutDay = day;
        _hotelDayIsCheckIn = true;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    Navigator.of(context).pop();

    final s = widget.schedule;
    DateTime? newStart, newEnd;

    if (!s.isHotel) {
      newStart = buildStartTime(
        travelStart: widget.travel.startDate,
        selectedDay: _selectedDay ?? 0,
        selectedHour: _selectedHour,
      );
    } else {
      newStart = _checkInDay != null
          ? buildHotelDateTime(
              travelStart: widget.travel.startDate,
              day: _checkInDay!,
              hour: _hourRange.checkInHour,
            )
          : null;
      newEnd = _checkOutDay != null
          ? buildHotelDateTime(
              travelStart: widget.travel.startDate,
              day: _checkOutDay!,
              hour: _hourRange.checkOutHour,
            )
          : null;
    }

    try {
      await ref.read(scheduleProvider(widget.travel.id!).notifier).quickEditTime(
            schedule: s,
            travelId: widget.travel.id!,
            newStartTime: newStart,
            newEndTime: newEnd,
          );
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        child: BackdropFilter(
          filter: GlassSpec.sheetBlur,
          child: Container(
            decoration: const BoxDecoration(
              color: GlassSpec.sheetBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              border: Border(top: BorderSide(color: GlassSpec.sheetBorder, width: 1)),
            ),
            child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 0,
                AppSpacing.pageHorizontal, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 14),
                    decoration: BoxDecoration(
                      color: GlassSpec.dragHandle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (widget.schedule.isHotel)
                  _buildHotelContent()
                else
                  _buildRegularContent(),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildRegularContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHeader(
          title: '修改时间',
          subtitle: widget.schedule.name,
        ),
        const SizedBox(height: 16),
        Text('选择日期', style: TextStyle(fontSize: 11, color: AppColors.inkTertiary)),
        const SizedBox(height: 8),
        _DayScrollRow(
          totalDays: _totalDays,
          travelStartDate: widget.travel.startDate,
          selectedDay: _selectedDay,
          isHotel: false,
          checkInDay: null,
          checkOutDay: null,
          onTap: (d) => setState(() => _selectedDay = d),
        ),
        const SizedBox(height: 16),
        const Text('选择时间',
            style: TextStyle(fontSize: 11, color: AppColors.inkTertiary)),
        const SizedBox(height: 8),
        _HourGrid(
          selectedHour: _selectedHour,
          isHotel: false,
          onTap: (h) =>
              setState(() => _selectedHour = h == _selectedHour ? null : h),
        ),
        const SizedBox(height: 20),
        _ConfirmButton(
          label: _selectedHour != null
              ? '确认 ${_selectedHour.toString().padLeft(2, '0')}:30'
              : '确认修改',
          saving: _saving, onTap: _submit),
      ],
    );
  }

  Widget _buildHotelContent() {
    final nights = (_checkInDay != null && _checkOutDay != null)
        ? _checkOutDay! - _checkInDay!
        : null;
    final nightsLabel = nights == null
        ? null
        : nights == 0
            ? '当日退房'
            : '$nights晚';

    String dayPrompt;
    if (!_hotelDayIsCheckIn && _checkInDay != null) {
      dayPrompt = '点击选择退房日';
    } else if (_checkInDay != null && _checkOutDay != null) {
      dayPrompt = '';
    } else {
      dayPrompt = '点击选择入住日';
    }

    String hourPrompt;
    switch (_hourRange.phase) {
      case HotelHourPhase.awaitingCheckIn:
        hourPrompt = '点击选择入住时间';
        break;
      case HotelHourPhase.awaitingCheckOut:
        hourPrompt = '点击选择退房时间';
        break;
      case HotelHourPhase.complete:
        hourPrompt = '';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHeader(
          title: '修改住宿时间',
          subtitle: widget.schedule.name,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Text('住宿周期',
              style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
          const Spacer(),
          if (dayPrompt.isNotEmpty)
            Text(dayPrompt,
                style: AppTextStyles.micro
                    .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        _DayScrollRow(
          totalDays: _totalDays,
          travelStartDate: widget.travel.startDate,
          selectedDay: null,
          isHotel: true,
          checkInDay: _checkInDay,
          checkOutDay: _checkOutDay,
          onTap: _onHotelDayTap,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Text('入退房时间（可选）',
              style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
          const Spacer(),
          if (hourPrompt.isNotEmpty)
            Text(hourPrompt,
                style: AppTextStyles.micro
                    .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        _HourGrid(
          isHotel: true,
          hourRange: _hourRange,
          onTap: (h) => setState(() => _hourRange = _hourRange.tap(h)),
        ),
        const SizedBox(height: 12),
        _HotelSummaryBar(
          checkInDay: _checkInDay,
          checkOutDay: _checkOutDay,
          checkInHour: _hourRange.checkInHour,
          checkOutHour: _hourRange.checkOutHour,
          nightsLabel: nightsLabel,
        ),
        const SizedBox(height: 20),
        _ConfirmButton(label: '确认修改', saving: _saving, onTap: _submit),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.title.copyWith(fontSize: 20)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
      ]),
      const Spacer(),
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 26, height: 26,
          decoration: const BoxDecoration(
            color: Color(0x1A1C1C1E),
            shape: BoxShape.circle,
          ),
          child: const Icon(HugeIcons.strokeRoundedCancel01, size: 14, color: AppColors.inkSecondary),
        ),
      ),
    ]);
  }
}

class _DayScrollRow extends StatelessWidget {
  const _DayScrollRow({
    required this.totalDays,
    required this.travelStartDate,
    required this.selectedDay,
    required this.isHotel,
    required this.checkInDay,
    required this.checkOutDay,
    required this.onTap,
  });

  final int totalDays;
  final DateTime travelStartDate;
  final int? selectedDay;
  final bool isHotel;
  final int? checkInDay;
  final int? checkOutDay;
  final ValueChanged<int> onTap;

  static const _weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  String _weekLabel(int day) {
    final date = travelStartDate.add(Duration(days: day - 1));
    return _weekLabels[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = [for (int d = 1; d <= totalDays; d++) d, if (!isHotel) 0];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          bool isSelected = false;
          String? tag;

          if (isHotel) {
            if (day == checkInDay) { isSelected = true; tag = '入住'; }
            else if (day == checkOutDay) { isSelected = true; tag = '退房'; }
          } else {
            isSelected = day == selectedDay;
          }

          final bg = isSelected
              ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
              : const Color(0x0A1C1C1E);
          final border = isSelected
              ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
              : Colors.transparent;
          final textColor = isSelected
              ? (isHotel ? AppColors.lavenderText : const Color(0xFFD4410A))
              : AppColors.inkTertiary;

          return GestureDetector(
            onTap: () => onTap(day),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              width: day == 0 ? 72 : 52,
              height: 60,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: day == 0
                    ? [
                        Text('待规划',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textColor)),
                      ]
                    : [
                        Text('DAY',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                height: 1.1)),
                        Text('$day',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: textColor,
                                height: 1.2)),
                        if (tag != null && tag!.isNotEmpty)
                          Text(tag!,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  height: 1.1)),
                      ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HourGrid extends StatelessWidget {
  const _HourGrid({
    required this.isHotel,
    this.selectedHour,
    this.hourRange,
    required this.onTap,
  });

  final bool isHotel;
  final int? selectedHour;
  final HotelHourRangeState? hourRange;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.5,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: 24,
      itemBuilder: (_, h) {
        bool isSelected = false;

        if (!isHotel) {
          isSelected = h == selectedHour;
        } else {
          final r = hourRange!;
          isSelected = h == r.checkInHour || h == r.checkOutHour;
        }

        final bg = isSelected
            ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
            : const Color(0x0A1C1C1E);
        final border = isSelected
            ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
            : Colors.transparent;
        final textColor = isSelected
            ? (isHotel ? AppColors.lavenderText : const Color(0xFFD4410A))
            : AppColors.inkTertiary;

        return GestureDetector(
          onTap: () => onTap(h),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Center(
              child: Text(
                '$h'.padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HotelSummaryBar extends StatelessWidget {
  const _HotelSummaryBar({
    required this.checkInDay,
    required this.checkOutDay,
    required this.checkInHour,
    required this.checkOutHour,
    required this.nightsLabel,
  });

  final int? checkInDay;
  final int? checkOutDay;
  final int? checkInHour;
  final int? checkOutHour;
  final String? nightsLabel;

  String _dayStr(int? d) => d != null ? 'Day$d' : 'Day--';
  String _hourStr(int? h) => h != null ? '${h.toString().padLeft(2, '0')}:00' : '--:--';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.hotelLight,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(children: [
        Text('${_dayStr(checkInDay)} 入住 ${_hourStr(checkInHour)}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w500)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('→', style: AppTextStyles.caption),
        ),
        Text('${_dayStr(checkOutDay)} 退房 ${_hourStr(checkOutHour)}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w500)),
        const Spacer(),
        if (nightsLabel != null)
          Text('· $nightsLabel', style: AppTextStyles.caption),
      ]),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.saving,
    required this.onTap,
  });
  final String label;
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.darkPill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Text('→', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
        ),
      ),
    );
  }
}
