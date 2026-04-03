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

class TravelFormSheet extends ConsumerStatefulWidget {
  const TravelFormSheet({super.key, this.travel});

  /// null → create new; non-null → edit existing
  final Travel? travel;

  static Future<void> show(BuildContext context, {Travel? travel}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
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
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
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
      cities: _selectedCities,
    );

    try {
      final repo = ref.read(travelRepositoryProvider);
      final saved = await repo.save(form);
      ref.read(travelListProvider.notifier).upsert(saved);
      if (saved.id != null) {
        ref.invalidate(travelDetailProvider(saved.id!));
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

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd');
    final isEdit = widget.travel != null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xB8FFFFFF), // rgba(255,255,255,0.72)
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              border: Border(
                top: BorderSide(color: Color(0xE6FFFFFF), width: 1),
              ),
              boxShadow: [
                BoxShadow(color: Color(0x1A6478B4), blurRadius: 24, offset: Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal, 16, AppSpacing.pageHorizontal, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Drag handle ───────────────────────────────────────
                      Center(
                        child: Container(
                          width: 36, height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0x281E243C),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // ── Title bar ─────────────────────────────────────────
                      Row(
                        children: [
                          Text(isEdit ? '编辑旅程' : '新建旅程',
                              style: AppTextStyles.title2),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0x141E243C),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0x0A1E243C)),
                              ),
                              child: const Icon(Icons.close, size: 16,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Grouped form card ─────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0x0D1E243C), // subtle fill on glass
                          borderRadius: BorderRadius.circular(AppRadius.cardSm),
                          border: Border.all(color: const Color(0x0A1E243C)),
                        ),
                    child: Column(
                      children: [
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
                        // 目的地
                        _FormRow(
                          label: '目的地',
                          onTap: () async {
                            final result = await _CityPickerSheet.show(
                              context,
                              selected: _selectedCities,
                            );
                            if (result != null) {
                              setState(() => _selectedCities = result);
                            }
                          },
                          crossAlign: _selectedCities.length > 2
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
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
                                          setState(() {
                                            _selectedCities = _selectedCities
                                                .where((c) => c != _selectedCities[i])
                                                .toList();
                                          });
                                        },
                                        index: i,
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
                        // 公开
                        _FormRow(
                          label: '公开',
                          child: SizedBox(
                            height: 28,
                            child: FittedBox(
                              child: Switch(
                                value: _isPublic,
                                activeThumbColor: AppColors.spearmint,
                                activeTrackColor: AppColors.spearmint.withValues(alpha: 0.22),
                                inactiveThumbColor: const Color(0x381E243C),
                                inactiveTrackColor: const Color(0x121E243C),
                                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                                onChanged: (v) => setState(() => _isPublic = v),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Save button ───────────────────────────────────────
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: TextButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEdit ? '保存修改' : '创建旅程',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500),
                            ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

  String _hint() {
    if (!_pendingEnd) return '请选择开始日期';
    final fmt = DateFormat('M月d日');
    return '已选 ${fmt.format(_start)}，请选择结束日期';
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
          borderRadius: BorderRadius.circular(AppRadius.sheet)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.cardPadding, 20, AppSpacing.cardPadding, AppSpacing.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('出行日期',
                        style: AppTextStyles.appBarTitle),
                    const SizedBox(height: 2),
                    Text(_hint(),
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Month navigation
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 22),
                  color: AppColors.textSecondary,
                  onPressed: () => setState(() => _viewMonth =
                      DateTime(_viewMonth.year, _viewMonth.month - 1)),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_viewMonth.year}年${_viewMonth.month}月',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 22),
                  color: AppColors.textSecondary,
                  onPressed: () => setState(() => _viewMonth =
                      DateTime(_viewMonth.year, _viewMonth.month + 1)),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
            // Weekday labels
            Row(
              children: _weekLabels
                  .map((l) => Expanded(
                        child: Center(
                          child: Text(l,
                              style: AppTextStyles.caption),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: offset + daysInMonth,
              itemBuilder: (context, i) {
                if (i < offset) return const SizedBox();
                final day = i - offset + 1;
                final date =
                    DateTime(_viewMonth.year, _viewMonth.month, day);
                final isStart = _isStart(date);
                final isEnd = _isEnd(date);
                final inRange = _inRange(date);
                final isToday = _sameDay(date, DateTime.now());

                Color? bgColor;
                BorderRadius? bgRadius;
                if (isStart && isEnd) {
                  bgColor = AppColors.primaryLight;
                  bgRadius = BorderRadius.circular(AppRadius.badge);
                } else if (isStart) {
                  bgColor = AppColors.primaryLight;
                  bgRadius = const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.badge));
                } else if (isEnd) {
                  bgColor = AppColors.primaryLight;
                  bgRadius = const BorderRadius.horizontal(
                      right: Radius.circular(AppRadius.badge));
                } else if (inRange) {
                  bgColor = AppColors.primaryLight;
                  bgRadius = BorderRadius.zero;
                }

                return GestureDetector(
                  onTap: () => _onDayTap(date),
                  child: Container(
                    decoration: bgColor != null
                        ? BoxDecoration(
                            color: bgColor,
                            borderRadius: bgRadius,
                          )
                        : null,
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
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
                              fontSize: 17,
                              fontWeight: (isStart || isEnd || isToday)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: (isStart || isEnd)
                                  ? Colors.white
                                  : isToday
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
          ],
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: crossAlign,
          children: [
            Padding(
              padding: crossAlign == CrossAxisAlignment.start
                  ? const EdgeInsets.only(top: 2)
                  : EdgeInsets.zero,
              child: Text(label, style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              )),
            ),
            const SizedBox(width: 16),
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
      padding: EdgeInsets.only(left: 16),
      child: Divider(height: 0.5, thickness: 0.5, color: Color(0x0F1E243C)),
    );
  }
}

// ─── City Picker Sheet (grouped by pinyin letter, searchable, multi-select) ──

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

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late Set<String> _selected;
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Grouped data: letter → cities
  late final Map<String, List<String>> _grouped;
  late final List<String> _letters;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selected);
    _grouped = _buildGroups();
    _letters = _grouped.keys.toList()..sort();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  List<String> _filteredCities(List<String> cities) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
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

          // ── Search bar ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x0D1E243C),
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
                      decoration: const InputDecoration(
                        hintText: '搜索城市或拼音',
                        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Selected chips ────────────────────────────────────────
          if (_selected.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selected.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final city = _selected.elementAt(i);
                  return _CityChip(
                    label: city,
                    index: i,
                    onRemove: () => setState(() => _selected.remove(city)),
                  );
                },
              ),
            ),
          if (_selected.isNotEmpty) const SizedBox(height: 8),

          // ── City list grouped by letter ────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: _letters.length,
              itemBuilder: (context, sectionIndex) {
                final letter = _letters[sectionIndex];
                final cities = _filteredCities(_grouped[letter]!);
                if (cities.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(letter, style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      )),
                    ),
                    // City items
                    for (final city in cities)
                      _CityItem(
                        city: city,
                        selected: _selected.contains(city),
                        onTap: () {
                          setState(() {
                            if (_selected.contains(city)) {
                              _selected.remove(city);
                            } else {
                              _selected.add(city);
                            }
                          });
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CityItem extends StatelessWidget {
  const _CityItem({
    required this.city,
    required this.selected,
    required this.onTap,
  });
  final String city;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Text(city, style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            )),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: AppColors.spearmint),
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
