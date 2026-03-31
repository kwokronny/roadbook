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
  final int? initialDay;     // 保留参数，暂不使用

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
  bool _saving = false;
  late List<String> _screenshots;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _screenshots = s?.screenshotList ?? [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Build form data ─────────────────────────────────────────────────────────

  ScheduleFormData _buildFormData() {
    final s = widget.schedule;
    return ScheduleFormData(
      id: s?.id,
      tId: widget.travel.id!,
      name: _nameCtrl.text.trim(),
      coordinate: s?.coordinate ?? '0,0',
      address: s?.address ?? '',
      isHotel: s?.isHotel ?? false,
      startTime: s?.startTime,   // 保留原有时间，不在此处修改
      endTime: s?.endTime,
      cover: s?.cover,
      dianpingUUID: s?.dianpingUUID,
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
                  const SizedBox(height: 16),
                  // ── 截图上传
                  Text('截图', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  ScreenshotPickerField(
                    value: _screenshots,
                    onChanged: (v) => setState(() => _screenshots = v),
                  ),
                  const SizedBox(height: 16),
                  // ── 备注
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      hintText: '添加备注（可选）',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    style: AppTextStyles.body,
                    maxLines: 4,
                    minLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 24),
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
                                  color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600),
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
