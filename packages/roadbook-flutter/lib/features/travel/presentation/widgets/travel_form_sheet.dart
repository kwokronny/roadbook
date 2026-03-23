// lib/features/travel/presentation/widgets/travel_form_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../features/travel/data/travel_repository.dart';
import '../../../../features/travel/domain/travel_list_provider.dart';
import '../../../../shared/models/travel.dart';

class TravelFormSheet extends ConsumerStatefulWidget {
  const TravelFormSheet({super.key, this.travel});

  /// null → 新建；non-null → 编辑
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
  late final TextEditingController _citiesCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isPublic;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.travel;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _citiesCtrl = TextEditingController(text: t?.cities.join(',') ?? '');
    _startDate = t?.startDate ?? DateTime.now();
    _endDate = t?.endDate ?? DateTime.now().add(const Duration(days: 3));
    _isPublic = t?.isPublic ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _citiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
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

    final cities = _citiesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final form = TravelFormData(
      id: widget.travel?.id,
      name: _nameCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      isPublic: _isPublic,
      cities: cities,
    );

    try {
      final repo = ref.read(travelRepositoryProvider);
      final saved = await repo.save(form);
      ref.read(travelListProvider.notifier).upsert(saved);
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
                  // 标题栏
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
                  // 名称
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: '旅程名称'),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入旅程名称' : null,
                  ),
                  const SizedBox(height: 12),
                  // 城市
                  TextFormField(
                    controller: _citiesCtrl,
                    decoration: const InputDecoration(
                      labelText: '城市（逗号分隔）',
                      hintText: '北京,上海',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  // 日期范围
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '出行日期',
                        suffixIcon: Icon(Icons.calendar_month_outlined, size: 18),
                      ),
                      child: Text(
                        '${fmt.format(_startDate)}  →  ${fmt.format(_endDate)}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 公开开关
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('公开旅程', style: AppTextStyles.body),
                    value: _isPublic,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                  const SizedBox(height: 16),
                  // 保存按钮（渐变）
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
                                  fontSize: 15,
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
