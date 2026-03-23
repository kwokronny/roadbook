// lib/features/schedule/presentation/schedule_edit_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/schedule.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_provider.dart';
import 'widgets/screenshot_picker_field.dart';

class ScheduleEditSheet extends ConsumerStatefulWidget {
  const ScheduleEditSheet({
    super.key,
    required this.travel,
    this.schedule,
    this.initialDay,
  });

  final Travel travel;
  final Schedule? schedule;  // null = 新建
  final int? initialDay;     // 打开时预选天

  static Future<void> show(
    BuildContext context, {
    required Travel travel,
    Schedule? schedule,
    int? initialDay,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleEditSheet(
        travel: travel,
        schedule: schedule,
        initialDay: initialDay,
      ),
    );
  }

  @override
  ConsumerState<ScheduleEditSheet> createState() => _ScheduleEditSheetState();
}

class _ScheduleEditSheetState extends ConsumerState<ScheduleEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late bool _isHotel;
  bool _saving = false;
  late List<String> _screenshots;

  // 普通地点选择
  late int? _selectedDay;   // 0=待规划, 1-N=第N天, null=未选
  late int? _selectedHour;  // 0-23, null=不选时间

  // 酒店选择
  late int? _checkInDay;
  late int? _checkOutDay;
  bool _hotelTapIsCheckIn = true;

  int get _totalDays =>
      widget.travel.endDate.difference(widget.travel.startDate).inDays + 1;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _isHotel = s?.isHotel ?? false;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _screenshots = s?.screenshotList ?? [];

    if (s != null) {
      _initFromSchedule(s);
    } else {
      _selectedDay = widget.initialDay ?? 1;
      _selectedHour = null;
      _checkInDay = null;
      _checkOutDay = null;
      _hotelTapIsCheckIn = true;
    }
  }

  void _initFromSchedule(Schedule s) {
    // 统一转为 local time，避免服务端返回 UTC 与本地 travelStart 混用导致天数偏移
    final start = widget.travel.startDate;
    if (s.isHotel) {
      _checkInDay = s.startTime != null
          ? s.startTime!.toLocal().difference(start).inDays + 1
          : null;
      _checkOutDay = s.endTime != null
          ? s.endTime!.toLocal().difference(start).inDays + 1
          : null;
      _hotelTapIsCheckIn = false;
      _selectedDay = null;
      _selectedHour = null;
    } else {
      if (s.startTime != null) {
        _selectedDay = s.startTime!.toLocal().difference(start).inDays + 1;
        _selectedHour = s.startTime!.toLocal().hour;
      } else {
        _selectedDay = 0; // 待规划
        _selectedHour = null;
      }
      _checkInDay = null;
      _checkOutDay = null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Day grid tap ────────────────────────────────────────────────────────────

  void _onDayTap(int day) {
    if (!_isHotel) {
      setState(() => _selectedDay = day);
    } else {
      setState(() {
        if (_hotelTapIsCheckIn) {
          _checkInDay = day;
          _checkOutDay = null;
          _hotelTapIsCheckIn = false;
        } else {
          if (day <= (_checkInDay ?? 0)) {
            _checkInDay = day;
            _checkOutDay = null;
          } else {
            _checkOutDay = day;
            _hotelTapIsCheckIn = true;
          }
        }
      });
    }
  }

  // ── Build form data ─────────────────────────────────────────────────────────

  ScheduleFormData _buildFormData() {
    final travelStart = widget.travel.startDate;
    DateTime? startTime, endTime;

    if (!_isHotel) {
      if (_selectedDay != null && _selectedDay! > 0) {
        final base = travelStart.add(Duration(days: _selectedDay! - 1));
        final h = _selectedHour ?? 0;
        startTime = DateTime(base.year, base.month, base.day, h, 0, 0);
      }
      // day == 0 (待规划) → startTime = null
    } else {
      if (_checkInDay != null) {
        final ci = travelStart.add(Duration(days: _checkInDay! - 1));
        startTime = DateTime(ci.year, ci.month, ci.day, 12, 0, 0);
      }
      if (_checkOutDay != null) {
        final co = travelStart.add(Duration(days: _checkOutDay! - 1));
        endTime = DateTime(co.year, co.month, co.day, 12, 0, 0);
      }
    }

    return ScheduleFormData(
      id: widget.schedule?.id,
      tId: widget.travel.id!,
      name: _nameCtrl.text.trim(),
      coordinate: widget.schedule?.coordinate ?? '0,0',
      address: widget.schedule?.address ?? '',
      isHotel: _isHotel,
      startTime: startTime,
      endTime: endTime,
      cover: widget.schedule?.cover,
      dianpingUUID: widget.schedule?.dianpingUUID,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      screenshots: _screenshots.isEmpty ? null : _screenshots.join(','),
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final form = _buildFormData();
    try {
      final notifier = ref.read(scheduleProvider(widget.travel.id!).notifier);
      if (widget.schedule == null) {
        await notifier.add(form);
      } else {
        await notifier.edit(form);  // NOTE: named 'edit' not 'update' (Riverpod conflict)
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.schedule != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 标题栏
                  Row(
                    children: [
                      Text(isEdit ? '编辑行程' : '新建行程',
                          style: AppTextStyles.appBarTitle),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── 名称
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: '名称'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                  ),
                  const SizedBox(height: 12),
                  // ── 备注
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(labelText: '备注（可选）'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // ── 截图上传
                  Text('截图', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  ScreenshotPickerField(
                    value: _screenshots,
                    onChanged: (v) => setState(() => _screenshots = v),
                  ),
                  const SizedBox(height: 16),
                  // ── 天选择宫格
                  Text('出行天', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  _DayGrid(
                    totalDays: _totalDays,
                    travelStart: widget.travel.startDate,
                    isHotel: _isHotel,
                    selectedDay: _selectedDay,
                    checkInDay: _checkInDay,
                    checkOutDay: _checkOutDay,
                    onTap: _onDayTap,
                  ),
                  if (!_isHotel) ...[
                    const SizedBox(height: 16),
                    // ── 小时宫格
                    Text('出发时间（可选）', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 8),
                    _HourGrid(
                      selectedHour: _selectedHour,
                      onTap: (h) => setState(() => _selectedHour = h == _selectedHour ? null : h),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // ── 保存按钮
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.fab),
                    ),
                    child: TextButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEdit ? '保存修改' : '创建行程',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Day Grid ─────────────────────────────────────────────────────────────────

class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.totalDays,
    required this.travelStart,
    required this.isHotel,
    required this.selectedDay,
    required this.checkInDay,
    required this.checkOutDay,
    required this.onTap,
  });

  final int totalDays;
  final DateTime travelStart;
  final bool isHotel;
  final int? selectedDay;
  final int? checkInDay;
  final int? checkOutDay;
  final ValueChanged<int> onTap;

  static const _weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    // Days 1..totalDays + 0 (待规划)
    final days = [for (int d = 1; d <= totalDays; d++) d, 0];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        bool isSelected = false;
        bool isRangeMiddle = false;
        String? tag;

        if (isHotel) {
          if (day > 0) {
            if (day == checkInDay) {
              isSelected = true;
              tag = '入住';
            } else if (day == checkOutDay) {
              isSelected = true;
              tag = '退房';
            } else if (checkInDay != null && checkOutDay != null &&
                day > checkInDay! && day < checkOutDay!) {
              isRangeMiddle = true;
            }
          }
        } else {
          isSelected = day == selectedDay;
        }

        Color bg;
        Color textColor;
        Color borderColor;
        if (isSelected) {
          bg = AppColors.primaryLight;
          textColor = AppColors.primary;
          borderColor = AppColors.primaryBorder;
        } else if (isRangeMiddle) {
          bg = const Color(0xFFFFF7ED);
          textColor = AppColors.textSecondary;
          borderColor = Colors.transparent;
        } else {
          bg = const Color(0xFFF5F5F4);
          textColor = AppColors.textSecondary;
          borderColor = Colors.transparent;
        }

        final weekday = day > 0
            ? _weekLabels[travelStart.add(Duration(days: day - 1)).weekday - 1]
            : null;

        return GestureDetector(
          onTap: () => onTap(day),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day == 0 ? '待规划' : '第 $day 天',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
                      if (weekday != null)
                        Text(
                          '周$weekday',
                          style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7)),
                        ),
                    ],
                  ),
                ),
                if (tag != null)
                  Positioned(
                    right: 4, top: 3,
                    child: Text(tag,
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Hour Grid ────────────────────────────────────────────────────────────────

class _HourGrid extends StatelessWidget {
  const _HourGrid({required this.selectedHour, required this.onTap});
  final int? selectedHour;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.4,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 24,
      itemBuilder: (context, h) {
        final isSelected = h == selectedHour;
        return GestureDetector(
          onTap: () => onTap(h),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(AppRadius.timeCell),
              border: Border.all(
                  color: isSelected ? AppColors.primaryBorder : Colors.transparent),
            ),
            child: Center(
              child: Text(
                '$h',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
