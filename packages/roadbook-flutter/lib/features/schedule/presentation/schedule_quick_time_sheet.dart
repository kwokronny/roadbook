// lib/features/schedule/presentation/schedule_quick_time_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/travel.dart';
import '../domain/schedule_provider.dart';

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
        final ci = checkInHour!;
        final inH = hour < ci ? hour : ci;
        final outH = hour < ci ? ci : hour;
        return HotelHourRangeState(
          checkInHour: inH,
          checkOutHour: outH,
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
        final ci = _checkInDay!;
        if (day < ci) {
          _checkInDay = day;
          _checkOutDay = ci;
        } else {
          _checkOutDay = day;
        }
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 20,
                AppSpacing.pageHorizontal, 24),
            child: widget.schedule.isHotel
                ? _buildHotelContent()
                : _buildRegularContent(),
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
          title: '修改出发时间',
          subtitle: widget.schedule.name,
        ),
        const SizedBox(height: 16),
        Text('出行日', style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _DayScrollRow(
          totalDays: _totalDays,
          selectedDay: _selectedDay,
          isHotel: false,
          checkInDay: null,
          checkOutDay: null,
          onTap: (d) => setState(() => _selectedDay = d),
        ),
        const SizedBox(height: 16),
        Text('出发时间（可选）',
            style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _HourGrid(
          selectedHour: _selectedHour,
          isHotel: false,
          onTap: (h) =>
              setState(() => _selectedHour = h == _selectedHour ? null : h),
        ),
        const SizedBox(height: 20),
        _ConfirmButton(isHotel: false, saving: _saving, onTap: _submit),
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
                    .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        _DayScrollRow(
          totalDays: _totalDays,
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
                    .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        _HourGrid(
          isHotel: true,
          hourRange: _hourRange,
          onTap: (h) => setState(() => _hourRange = _hourRange.tap(h)),
        ),
        if (_checkInDay != null && _checkOutDay != null) ...[
          const SizedBox(height: 12),
          _HotelSummaryBar(
            checkInDay: _checkInDay!,
            checkOutDay: _checkOutDay!,
            checkInHour: _hourRange.checkInHour,
            checkOutHour: _hourRange.checkOutHour,
            nightsLabel: nightsLabel!,
          ),
        ],
        const SizedBox(height: 20),
        _ConfirmButton(isHotel: true, saving: _saving, onTap: _submit),
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
        Text(title, style: AppTextStyles.appBarTitle),
        const SizedBox(height: 2),
        Text(subtitle,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ]),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.close, size: 20),
        onPressed: () => Navigator.of(context).pop(),
        color: AppColors.textSecondary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ]);
  }
}

class _DayScrollRow extends StatelessWidget {
  const _DayScrollRow({
    required this.totalDays,
    required this.selectedDay,
    required this.isHotel,
    required this.checkInDay,
    required this.checkOutDay,
    required this.onTap,
  });

  final int totalDays;
  final int? selectedDay;
  final bool isHotel;
  final int? checkInDay;
  final int? checkOutDay;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final days = [for (int d = 1; d <= totalDays; d++) d, if (!isHotel) 0];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          bool isSelected = false;
          bool isRange = false;
          String? tag;

          if (isHotel) {
            if (day == checkInDay) { isSelected = true; tag = '入住'; }
            else if (day == checkOutDay) { isSelected = true; tag = '退房'; }
            else if (checkInDay != null && checkOutDay != null &&
                day > checkInDay! && day < checkOutDay!) {
              isRange = true;
            }
          } else {
            isSelected = day == selectedDay;
          }

          final bg = isSelected
              ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
              : isRange
                  ? (isHotel ? AppColors.hotelLight : const Color(0xFFFFF7ED))
                  : const Color(0xFFF5F5F4);
          final border = isSelected
              ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
              : Colors.transparent;
          final textColor = isSelected || isRange
              ? (isHotel ? AppColors.hotel : AppColors.primary)
              : AppColors.textSecondary;

          return GestureDetector(
            onTap: () => onTap(day),
            child: Container(
              margin: const EdgeInsets.only(right: 5),
              width: day == 0 ? 64 : 48,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: border),
              ),
              child: Stack(
                children: [
                  Center(
                    child: day == 0
                        ? Text('待规划',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textColor))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('DAY',
                                  style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      height: 1.1)),
                              Text('$day',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                      height: 1.1)),
                            ],
                          ),
                  ),
                  if (tag != null)
                    Positioned(
                      bottom: 1,
                      left: 0,
                      right: 0,
                      child: Text(tag,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                    ),
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
        bool isRange = false;

        if (!isHotel) {
          isSelected = h == selectedHour;
        } else {
          final r = hourRange!;
          isSelected = h == r.checkInHour || h == r.checkOutHour;
          isRange = r.isInRange(h);
        }

        final bg = isSelected
            ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
            : isRange
                ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
                : const Color(0xFFF5F5F4);
        final border = isSelected
            ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
            : isRange
                ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
                : Colors.transparent;
        final textColor = isSelected || isRange
            ? (isHotel ? AppColors.hotel : AppColors.primary)
            : AppColors.textSecondary;

        return GestureDetector(
          onTap: () => onTap(h),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.timeCell),
              border: Border.all(color: border),
            ),
            child: Center(
              child: Text(
                '$h',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
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

  final int checkInDay;
  final int checkOutDay;
  final int? checkInHour;
  final int? checkOutHour;
  final String nightsLabel;

  String _hourStr(int? h) => h != null ? '${h.toString().padLeft(2, '0')}:00' : '--';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.hotelLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Text('Day$checkInDay 入住 ${_hourStr(checkInHour)}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('→', style: AppTextStyles.caption),
        ),
        Text('Day$checkOutDay 退房 ${_hourStr(checkOutHour)}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('· $nightsLabel', style: AppTextStyles.caption),
      ]),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton(
      {required this.isHotel, required this.saving, required this.onTap});
  final bool isHotel;
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: isHotel
            ? const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.fab),
      ),
      child: TextButton(
        onPressed: saving ? null : onTap,
        child: saving
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Text('确认修改',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }
}
