// lib/features/travel/presentation/widgets/travel_form_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lpinyin/lpinyin.dart';
import '../../../../core/cities_data.dart';
import '../../../../core/theme.dart';
import '../../../../features/travel/data/travel_repository.dart';
import '../../../../features/travel/domain/travel_list_provider.dart';
import '../../../../features/travel/domain/travel_detail_provider.dart';
import '../../../../shared/models/travel.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/glass_drawer.dart';

class TravelFormSheet extends ConsumerStatefulWidget {
  const TravelFormSheet({super.key, this.travel});

  /// null → create new; non-null → edit existing
  final Travel? travel;

  static Future<void> show(BuildContext context, {Travel? travel}) {
    return showGlassDrawer<void>(
      context: context,
      title: travel != null ? '编辑旅程' : '新建旅程',
      builder: (_) => TravelFormSheet(travel: travel),
    );
  }

  @override
  ConsumerState<TravelFormSheet> createState() => _TravelFormSheetState();
}

class _TravelFormSheetState extends ConsumerState<TravelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  List<String> _selectedCities = [];
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isPublic;
  late bool _isAbroad;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.travel;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _selectedCities = List<String>.from(t?.cities ?? []);
    _startDate = t?.startDate ?? DateTime.now();
    _endDate = t?.endDate ?? DateTime.now().add(const Duration(days: 3));
    _isPublic = t?.isPublic ?? false;
    _isAbroad = t?.isAbroad ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCityPicker() async {
    final result = await _CityPickerSheet.show(
      context,
      selected: _selectedCities,
    );
    if (result != null) {
      setState(() {
        _selectedCities = result;
        _autoFillName();
      });
    }
  }

  /// Auto-fill name based on cities + days when creating (not editing)
  void _autoFillName() {
    if (widget.travel != null) return; // don't overwrite when editing
    if (_selectedCities.isEmpty) return;
    final days = _endDate.difference(_startDate).inDays + 1;
    final city = _selectedCities.first;
    _nameCtrl.text = '$city ${days}日游';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => _CalendarPickerDialog(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _autoFillName();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final form = TravelFormData(
      id: widget.travel?.id,
      name: _nameCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      isPublic: _isPublic,
      isAbroad: _isAbroad,
      cities: _selectedCities,
    );

    try {
      final repo = ref.read(travelRepositoryProvider);
      await repo.save(form);
      // Refresh the full travel list (save returns incomplete data without Users/Schedules)
      ref.invalidate(travelListProvider);
      if (form.id != null) {
        ref.invalidate(travelDetailProvider(form.id!));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd');
    final isEdit = widget.travel != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                      // ── Grouped form card ─────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xB0FFFFFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                    child: Column(
                      children: [
                        // 目的地
                        _FormRow(
                          label: '目的地',
                          onTap: _selectedCities.isEmpty ? _openCityPicker : null,
                          crossAlign: _selectedCities.isEmpty
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          child: _selectedCities.isEmpty
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('选择城市',
                                        style: TextStyle(fontSize: 15,
                                            color: AppColors.textTertiary)),
                                    SizedBox(width: 4),
                                    Icon(Icons.chevron_right,
                                        size: 16, color: AppColors.textTertiary),
                                  ],
                                )
                              : Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.end,
                                  children: [
                                    for (int i = 0; i < _selectedCities.length; i++)
                                      _CityChip(
                                        label: _selectedCities[i],
                                        onRemove: () {
                                          final city = _selectedCities[i];
                                          setState(() {
                                            _selectedCities = _selectedCities
                                                .where((c) => c != city)
                                                .toList();
                                          });
                                        },
                                        index: i,
                                      ),
                                    GestureDetector(
                                      onTap: _openCityPicker,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0x08000000),
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.pill),
                                          border: Border.all(
                                              color: const Color(0x1E1C1C1E),
                                              width: 1),
                                        ),
                                        child: const Icon(Icons.add,
                                            size: 14,
                                            color: AppColors.inkSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const _FormDivider(),
                        // 出行日期
                        _FormRow(
                          label: '日期',
                          onTap: _pickDateRange,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${fmt.format(_startDate)} → ${fmt.format(_endDate)}',
                                style: const TextStyle(
                                  fontSize: 15, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  size: 16, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                        const _FormDivider(),
                        // 旅程名称
                        _FormRow(
                          label: '名称',
                          child: TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                              hintText: '输入旅程名称',
                              hintStyle: TextStyle(
                                  color: AppColors.textTertiary, fontSize: 15),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                          ),
                        ),
                        const _FormDivider(),
                        // 地图选择
                        _FormRow(
                          label: '地图',
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _MapToggle(
                              isAbroad: _isAbroad,
                              onChanged: (v) => setState(() => _isAbroad = v),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(14, 0, 14, 10),
                          child: Text(
                            '国外旅游请选择 Google',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Dark CTA button ───────────────────────────────────
                  GestureDetector(
                    onTap: _saving ? null : _submit,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkPill,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Center(
                        child: _saving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isEdit ? '保存修改' : '创建旅程',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('→',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                ],
                              ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Calendar Picker Dialog ───────────────────────────────────────────────────

class _CalendarPickerDialog extends StatefulWidget {
  const _CalendarPickerDialog({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  @override
  State<_CalendarPickerDialog> createState() => _CalendarPickerDialogState();
}

class _CalendarPickerDialogState extends State<_CalendarPickerDialog> {
  late DateTime _start;
  DateTime? _end;
  late DateTime _viewMonth;

  /// false → next tap sets start; true → next tap sets end
  bool _pendingEnd = false;

  static const _weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

  static DateTime _d(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isStart(DateTime d) => _sameDay(d, _start);
  bool _isEnd(DateTime d) => _end != null && _sameDay(d, _end!);
  bool _inRange(DateTime d) {
    if (_end == null) return false;
    return d.isAfter(_start) && d.isBefore(_end!);
  }

  @override
  void initState() {
    super.initState();
    _start = _d(widget.start);
    _end = _d(widget.end);
    _viewMonth = DateTime(_start.year, _start.month);
  }

  void _onDayTap(DateTime day) {
    final d = _d(day);
    if (!_pendingEnd) {
      // First tap: set start, clear end
      setState(() {
        _start = d;
        _end = null;
        _pendingEnd = true;
      });
    } else {
      // Second tap: set end (swap if needed) then auto-close
      DateTime newStart = _start;
      DateTime newEnd;
      if (d.isBefore(_start)) {
        newStart = d;
        newEnd = _start;
      } else {
        newEnd = d;
      }
      // Update state briefly for animation, then pop
      setState(() {
        _start = newStart;
        _end = newEnd;
        _pendingEnd = false;
      });
      // Pop after next frame so user sees the selection flash
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context)
              .pop(DateTimeRange(start: newStart, end: newEnd));
        }
      });
    }
  }

  static const _wkNames = ['周一','周二','周三','周四','周五','周六','周日'];

  String _hint() {
    if (!_pendingEnd) return '请选择开始日期';
    return '已选 ${_start.month}/${_start.day} — 请选结束日期';
  }

  String _rangeSummary() {
    if (_end == null) return '';
    final sw = _wkNames[_start.weekday - 1];
    final ew = _wkNames[_end!.weekday - 1];
    final nights = _end!.difference(_start).inDays;
    return '${_start.month}/${_start.day} ($sw) → ${_end!.month}/${_end!.day} ($ew)';
  }

  String _nightsLabel() {
    if (_end == null) return '';
    final n = _end!.difference(_start).inDays;
    return '${n}晚${n + 1}天';
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final offset =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday - 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xB3FFFFFF), // 70% white — more transparent
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x80FFFFFF)),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // ── Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('出行日期',
                    style: AppTextStyles.title.copyWith(fontSize: 18)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0x1A1C1C1E), shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 12,
                        color: AppColors.inkSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Calendar area — white rounded container
            Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
            // ── Month nav
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _viewMonth =
                      DateTime(_viewMonth.year, _viewMonth.month - 1)),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0x0D1C1C1E), shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, size: 24, color: AppColors.inkSecondary),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_viewMonth.year}年${_viewMonth.month}月',
                      style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w500, color: AppColors.inkPrimary),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _viewMonth =
                      DateTime(_viewMonth.year, _viewMonth.month + 1)),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0x0D1C1C1E), shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, size: 24, color: AppColors.inkSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Weekday labels
            Row(
              children: _weekLabels
                  .map((l) => Expanded(
                        child: Center(
                          child: Text(l,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.inkTertiary)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            // ── Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 1),
              itemCount: offset + daysInMonth,
              itemBuilder: (context, i) {
                if (i < offset) return const SizedBox();
                final day = i - offset + 1;
                final date = DateTime(_viewMonth.year, _viewMonth.month, day);
                final isStart = _isStart(date);
                final isEnd = _isEnd(date);
                final inRange = _inRange(date);
                final isToday = _sameDay(date, DateTime.now());

                // Range background strip
                Color? stripColor;
                BorderRadius? stripRadius;
                if (isStart && _end != null) {
                  stripColor = AppColors.coralTint;
                  stripRadius = const BorderRadius.horizontal(
                      left: Radius.circular(50));
                } else if (isEnd) {
                  stripColor = AppColors.coralTint;
                  stripRadius = const BorderRadius.horizontal(
                      right: Radius.circular(50));
                } else if (inRange) {
                  stripColor = AppColors.coralTint;
                  stripRadius = BorderRadius.zero;
                }

                return GestureDetector(
                  onTap: () => _onDayTap(date),
                  child: Container(
                    decoration: stripColor != null
                        ? BoxDecoration(color: stripColor, borderRadius: stripRadius)
                        : null,
                    child: Center(
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: (isStart || isEnd)
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: (isStart || isEnd || isToday)
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: (isStart || isEnd)
                                  ? Colors.white
                                  : (inRange || isToday)
                                      ? const Color(0xFFD4410A)
                                      : AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
                ],
              ),
            ), // end white calendar container
            // ── Range summary
            if (_end != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EB), // opaque coral tint
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(_rangeSummary(),
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500, color: Color(0xFFD4410A))),
                    const Spacer(),
                    Text(_nightsLabel(),
                        style: const TextStyle(fontSize: 12, color: Color(0xFFD4410A))),
                  ],
                ),
              ),
            ],
          ],
          ),
        ),
      ),
      ),
    );
  }
}

// ─── iOS-style form row (label left, content right) ─────────────────────────

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    required this.child,
    this.onTap,
    this.crossAlign = CrossAxisAlignment.center,
  });
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final CrossAxisAlignment crossAlign;

  static const double _labelWidth = 60;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: onTap != null ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: crossAlign,
          children: [
            SizedBox(
              width: _labelWidth,
              child: Padding(
                padding: crossAlign == CrossAxisAlignment.start
                    ? const EdgeInsets.only(top: 2)
                    : EdgeInsets.zero,
                child: Text(label, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400,
                  color: AppColors.inkPrimary,
                )),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FormDivider extends StatelessWidget {
  const _FormDivider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 14),
      child: Divider(height: 0.5, thickness: 0.5, color: Color(0x0F1C1C1E)),
    );
  }
}

// ─── City Picker Sheet (tabbed: 国内·港澳台 / 国际) ────────────────────────────

enum _IntlItemKind { regionHeader, city }

class _IntlItem {
  const _IntlItem.region(this.text)
      : kind = _IntlItemKind.regionHeader,
        country = null;
  _IntlItem.city(this.text, String c)
      : kind = _IntlItemKind.city,
        country = c;

  final String text;
  final _IntlItemKind kind;
  final String? country;
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({required this.selected});
  final List<String> selected;

  static Future<List<String>?> show(BuildContext context, {required List<String> selected}) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(selected: selected),
    );
  }

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet>
    with SingleTickerProviderStateMixin {
  late Set<String> _selected;
  final _searchCtrl = TextEditingController();
  final _domesticScrollCtrl = ScrollController();
  final _intlScrollCtrl = ScrollController();
  late final TabController _tabController;
  String _query = '';

  late final Map<String, List<String>> _grouped;
  late final List<String> _letters;
  final List<String> _regions = kIntlCitiesGrouped.keys.toList();

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selected);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() { if (mounted) setState(() {}); });
    _grouped = _buildGroups();
    _letters = _grouped.keys.toList()..sort();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _domesticScrollCtrl.dispose();
    _intlScrollCtrl.dispose();
    super.dispose();
  }

  // ── Domestic helpers ──────────────────────────────────────────────────────

  void _scrollToLetter(String letter) {
    const double headerHeight = 34;
    const double itemHeight = 38.75;
    const double dividerH = 0.5;
    double offset = 0;
    for (final l in _letters) {
      final cities = _filteredDomestic(_grouped[l]!);
      if (cities.isEmpty) continue;
      if (l == letter) break;
      offset += headerHeight +
          cities.length * itemHeight +
          (cities.length > 1 ? (cities.length - 1) * dividerH : 0);
    }
    _domesticScrollCtrl.animateTo(
      offset.clamp(0, _domesticScrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Map<String, List<String>> _buildGroups() {
    final map = <String, List<String>>{};
    for (final city in kChineseCities) {
      final pinyin = PinyinHelper.getShortPinyin(city);
      final letter = pinyin.isNotEmpty ? pinyin[0].toUpperCase() : '#';
      map.putIfAbsent(letter, () => []).add(city);
    }
    return map;
  }

  List<String> _filteredDomestic(List<String> cities) {
    if (_query.isEmpty) return cities;
    return cities.where((c) {
      if (c.contains(_query)) return true;
      final fullPinyin = PinyinHelper.getPinyinE(c, separator: '').toLowerCase();
      if (fullPinyin.contains(_query)) return true;
      final shortPinyin = PinyinHelper.getShortPinyin(c).toLowerCase();
      if (shortPinyin.contains(_query)) return true;
      return false;
    }).toList();
  }

  // ── International helpers ─────────────────────────────────────────────────

  void _scrollToRegion(String region) {
    const double regionH = 28.0;
    const double cityH = 38.75;
    const double dividerH = 0.5;
    double offset = 0;
    for (final regionEntry in kIntlCitiesGrouped.entries) {
      if (regionEntry.key == region) break;
      offset += regionH;
      int cityCount = 0;
      for (final c in regionEntry.value.values) {
        cityCount += c.length;
      }
      offset += cityCount * cityH + (cityCount - 1) * dividerH;
    }
    _intlScrollCtrl.animateTo(
      offset.clamp(0, _intlScrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  List<_IntlItem> _buildIntlItems() {
    if (_query.isEmpty) {
      final items = <_IntlItem>[];
      for (final regionEntry in kIntlCitiesGrouped.entries) {
        items.add(_IntlItem.region(regionEntry.key));
        for (final countryEntry in regionEntry.value.entries) {
          for (final city in countryEntry.value) {
            items.add(_IntlItem.city(city, countryEntry.key));
          }
        }
      }
      return items;
    }
    final items = <_IntlItem>[];
    for (final regionEntry in kIntlCitiesGrouped.entries) {
      for (final countryEntry in regionEntry.value.entries) {
        final country = countryEntry.key;
        final matched = countryEntry.value
            .where((c) => c.contains(_query) || country.contains(_query))
            .toList();
        for (final city in matched) {
          items.add(_IntlItem.city(city, country));
        }
      }
    }
    return items;
  }

  void _toggle(String city) {
    setState(() {
      if (_selected.contains(city)) {
        _selected.remove(city);
      } else {
        _selected.add(city);
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isIntl = _tabController.index == 1;
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                const Text('选择城市', style: AppTextStyles.title2),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selected.toList()),
                  child: Text(
                    '完成 (${_selected.length})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _selected.isNotEmpty
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.inkTertiary,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: const Color(0x0F1C1C1E),
            tabs: const [
              Tab(text: '国内·港澳台'),
              Tab(text: '国际'),
            ],
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x0D1C1C1E),
                borderRadius: BorderRadius.circular(AppRadius.cardXs),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: isIntl ? '搜索城市或国家' : '搜索城市或拼音',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDomesticTab(),
                _buildIntlTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomesticTab() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: ListView.builder(
            controller: _domesticScrollCtrl,
            padding: EdgeInsets.zero,
            itemCount: _letters.length,
            itemBuilder: (context, i) {
              final letter = _letters[i];
              final cities = _filteredDomestic(_grouped[letter]!);
              if (cities.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    child: Text(letter, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    )),
                  ),
                  for (int j = 0; j < cities.length; j++) ...[
                    _CityItem(
                      city: cities[j],
                      selected: _selected.contains(cities[j]),
                      onTap: () => _toggle(cities[j]),
                    ),
                    if (j < cities.length - 1)
                      const Divider(height: 0.5, thickness: 0.5, indent: 14,
                          color: Color(0x0F1C1C1E)),
                  ],
                ],
              );
            },
          ),
        ),
        Positioned(
          right: 2, top: 0, bottom: 0,
          child: _LetterBar(letters: _letters, onSelect: _scrollToLetter),
        ),
      ],
    );
  }

  Widget _buildIntlTab() {
    final items = _buildIntlItems();
    if (items.isEmpty) {
      return Center(
        child: Text(
          '未找到"$_query"相关城市',
          style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
        ),
      );
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: ListView.builder(
            controller: _intlScrollCtrl,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (context, i) {
        final item = items[i];
        switch (item.kind) {
          case _IntlItemKind.regionHeader:
            return Container(
              width: double.infinity,
              color: const Color(0x061C1C1E),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Text(
                item.text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            );
          case _IntlItemKind.city:
            final isLast = i + 1 >= items.length ||
                items[i + 1].kind != _IntlItemKind.city;
            return Column(
              children: [
                _CityItem(
                  city: item.text,
                  selected: _selected.contains(item.text),
                  trailingLabel: item.country,
                  onTap: () => _toggle(item.text),
                ),
                if (!isLast)
                  const Divider(height: 0.5, thickness: 0.5, indent: 14,
                      color: Color(0x0F1C1C1E)),
              ],
            );
        }
      },
          ),
        ),
        if (_query.isEmpty)
          Positioned(
            right: 2, top: 0, bottom: 0,
            child: _RegionBar(regions: _regions, onSelect: _scrollToRegion),
          ),
      ],
    );
  }
}

class _CityItem extends StatelessWidget {
  const _CityItem({
    required this.city,
    required this.selected,
    required this.onTap,
    this.trailingLabel,
  });
  final String city;
  final bool selected;
  final VoidCallback onTap;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(city,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                      )),
                  ),
                  if (trailingLabel != null) ...[
                    const SizedBox(width: 6),
                    Text(trailingLabel!, style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    )),
                  ],
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, size: 20, color: AppColors.success),
            ],
          ],
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.label, required this.onRemove, required this.index});

  final String label;
  final VoidCallback onRemove;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.cityTagBg(index),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cityTagBorder(index), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.cityTagText(index),
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.cityTagText(index)),
          ),
        ],
      ),
    );
  }
}

// ─── Map provider toggle (高德 / Google) with sliding pill ────────────────────

class _MapToggle extends StatelessWidget {
  const _MapToggle({required this.isAbroad, required this.onChanged});
  final bool isAbroad;
  final ValueChanged<bool> onChanged;

  static const _segW = 64.0;
  static const _pad = 2.0;
  static const _height = 30.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _segW * 2 + _pad * 2,
      height: _height,
      child: Container(
        padding: const EdgeInsets.all(_pad),
        decoration: BoxDecoration(
          color: const Color(0x0F1C1C1E),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Stack(
          children: [
            // Sliding pill
            AnimatedAlign(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              alignment:
                  isAbroad ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: _segW,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                GestureDetector(
                  onTap: () => onChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: _segW,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              !isAbroad ? FontWeight.w500 : FontWeight.w400,
                          color: !isAbroad
                              ? AppColors.inkPrimary
                              : AppColors.inkTertiary,
                        ),
                        child: const Text('高德'),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: _segW,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isAbroad ? FontWeight.w500 : FontWeight.w400,
                          color: isAbroad
                              ? AppColors.inkPrimary
                              : AppColors.inkTertiary,
                        ),
                        child: const Text('Google'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterBar extends StatelessWidget {
  const _LetterBar({required this.letters, required this.onSelect});
  final List<String> letters;
  final void Function(String letter) onSelect;

  static const double _labelH = 15.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final barH = constraints.maxHeight;
        final totalH = letters.length * _labelH;
        final topOffset = totalH < barH ? (barH - totalH) / 2 : 0.0;

        void pick(double dy) {
          final adjustedDy = (dy - topOffset).clamp(0.0, totalH - 0.01);
          final idx = (adjustedDy / _labelH).clamp(0, letters.length - 1).toInt();
          onSelect(letters[idx]);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (d) => pick(d.localPosition.dy),
          onTapDown: (d) => pick(d.localPosition.dy),
          child: SizedBox(
            width: 28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters
                  .map((l) => SizedBox(
                        height: _labelH,
                        child: Center(
                          child: Text(l,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkTertiary,
                              )),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _RegionBar extends StatelessWidget {
  const _RegionBar({required this.regions, required this.onSelect});
  final List<String> regions;
  final void Function(String region) onSelect;

  static const double _labelH = 26.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final barH = constraints.maxHeight;
        final totalH = regions.length * _labelH;
        final topOffset = totalH < barH ? (barH - totalH) / 2 : 0.0;

        void pick(double dy) {
          final adjustedDy = (dy - topOffset).clamp(0.0, totalH - 0.01);
          final idx = (adjustedDy / _labelH).clamp(0, regions.length - 1).toInt();
          onSelect(regions[idx]);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (d) => pick(d.localPosition.dy),
          onTapDown: (d) => pick(d.localPosition.dy),
          child: SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: regions
                  .map((r) => SizedBox(
                        height: _labelH,
                        child: Center(
                          child: Text(
                            r.length > 2 ? r.substring(0, 2) : r,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkTertiary,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
