// lib/features/travel/presentation/widgets/travel_form_sheet.dart
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
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title bar
                  Row(
                    children: [
                      Text(isEdit ? '编辑旅程' : '新建旅程',
                          style: AppTextStyles.title2),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Name
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: '旅程名称'),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入旅程名称' : null,
                  ),
                  const SizedBox(height: 12),
                  // Cities
                  _CityMultiSelectField(
                    selectedCities: _selectedCities,
                    onChanged: (v) => setState(() => _selectedCities = v),
                  ),
                  const SizedBox(height: 12),
                  // Date range
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '出行日期',
                        suffixIcon:
                            Icon(Icons.calendar_month_outlined, size: 18),
                      ),
                      child: Text(
                        '${fmt.format(_startDate)}  →  ${fmt.format(_endDate)}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Public toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('公开旅程',
                        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                    value: _isPublic,
                    activeThumbColor: AppColors.spearmint,
                    activeTrackColor: AppColors.spearmint.withValues(alpha: 0.22),
                    inactiveThumbColor: const Color(0x381E243C),
                    inactiveTrackColor: const Color(0x121E243C),
                    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                  const SizedBox(height: 16),
                  // Save button
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
                              width: 20,
                              height: 20,
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

// ─── City Multi-Select Field ──────────────────────────────────────────────────

class _CityMultiSelectField extends StatefulWidget {
  const _CityMultiSelectField({
    required this.selectedCities,
    required this.onChanged,
  });

  final List<String> selectedCities;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_CityMultiSelectField> createState() => _CityMultiSelectFieldState();
}

class _CityMultiSelectFieldState extends State<_CityMultiSelectField> {
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _textCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  void _onQueryChanged() {
    final query = _textCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      _removeOverlay();
      _suggestions = [];
      return;
    }
    _suggestions = kChineseCities
        .where((c) {
          if (widget.selectedCities.contains(c)) return false;
          if (c.toLowerCase().contains(query)) return true;
          // Full pinyin match: e.g. "beijing" matches "北京"
          final fullPinyin = PinyinHelper.getPinyinE(c, separator: '').toLowerCase();
          if (fullPinyin.contains(query)) return true;
          // First letter match: e.g. "bj" matches "北京"
          final firstLetters = PinyinHelper.getShortPinyin(c).toLowerCase();
          if (firstLetters.contains(query)) return true;
          return false;
        })
        .take(6)
        .toList();
    if (_suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final width = renderBox.size.width;

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + 4),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _suggestions.map((city) {
                  return InkWell(
                    onTap: () => _addCity(city),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(city, style: AppTextStyles.body),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _addCity(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;
    if (widget.selectedCities.contains(trimmed)) {
      _textCtrl.clear();
      return;
    }
    widget.onChanged([...widget.selectedCities, trimmed]);
    _textCtrl.clear();
    _removeOverlay();
    _suggestions = [];
  }

  void _removeCity(String city) {
    widget.onChanged(widget.selectedCities.where((c) => c != city).toList());
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: '目的地城市',
            suffixIcon: widget.selectedCities.isEmpty
                ? const Icon(Icons.add_location_alt_outlined, size: 18)
                : null,
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < widget.selectedCities.length; i++)
                _CityChip(
                  label: widget.selectedCities[i],
                  onRemove: () => _removeCity(widget.selectedCities[i]),
                  index: i,
                ),
              IntrinsicWidth(
                child: TextField(
                  controller: _textCtrl,
                  focusNode: _focusNode,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: widget.selectedCities.isEmpty
                        ? '搜索城市'
                        : '添加更多',
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    filled: false,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (v) {
                    final trimmed = v.trim();
                    if (trimmed.isNotEmpty) _addCity(trimmed);
                  },
                  onChanged: (v) {
                    if (v.endsWith(',') || v.endsWith('，')) {
                      final city = v.substring(0, v.length - 1).trim();
                      if (city.isNotEmpty) _addCity(city);
                    }
                  },
                ),
              ),
            ],
          ),
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
