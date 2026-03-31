// lib/features/travel/presentation/widgets/travel_form_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                          style: AppTextStyles.appBarTitle),
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
                    title: Text('公开旅程', style: AppTextStyles.body),
                    value: _isPublic,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                  const SizedBox(height: 16),
                  // Save button
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEdit ? '保存修改' : '创建旅程',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600),
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
                          fontWeight: FontWeight.w600,
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
                                  ? FontWeight.w700
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
  List<String> _suggestions = [];
  bool _isFocused = false;

  bool get _showSuggestions => _isFocused && _textCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _textCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _textCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() {
      _suggestions = kChineseCities
          .where((c) =>
              c.toLowerCase().contains(query) &&
              !widget.selectedCities.contains(c))
          .toList();
    });
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
    setState(() => _suggestions = []);
  }

  void _removeCity(String city) {
    widget.onChanged(widget.selectedCities.where((c) => c != city).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input container: chips + inline text field
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.input),
            color: AppColors.surface,
          ),
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Selected city chips
              for (final city in widget.selectedCities)
                _CityChip(
                  label: city,
                  onRemove: () => _removeCity(city),
                ),
              // Inline text field
              SizedBox(
                height: 32,
                width: 160,
                child: TextField(
                  controller: _textCtrl,
                  focusNode: _focusNode,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: '搜索或输入城市',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isNotEmpty) {
                      // Remove trailing comma if present
                      final city = trimmed.endsWith(',')
                          ? trimmed.substring(0, trimmed.length - 1)
                          : trimmed;
                      _addCity(city);
                    }
                  },
                  onChanged: (value) {
                    // Add city when comma is typed
                    if (value.endsWith(',')) {
                      final city = value.substring(0, value.length - 1).trim();
                      if (city.isNotEmpty) _addCity(city);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Suggestion dropdown
        if (_showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: _suggestions.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final city = _suggestions[index];
                      return InkWell(
                        onTap: () => _addCity(city),
                        child: Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(city, style: AppTextStyles.body),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primaryBorder),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
