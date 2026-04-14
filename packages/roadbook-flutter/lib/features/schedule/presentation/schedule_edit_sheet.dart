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
  final Schedule? schedule;
  final int? initialDay;

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
  late bool _isHotel;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _screenshots = s?.screenshotList ?? [];
    _isHotel = s?.isHotel ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  ScheduleFormData _buildFormData() {
    final s = widget.schedule;
    return ScheduleFormData(
      id: s?.id,
      tId: widget.travel.id!,
      name: _nameCtrl.text.trim(),
      coordinate: s?.coordinate ?? '0,0',
      address: s?.address ?? '',
      isHotel: _isHotel,
      startTime: s?.startTime,
      endTime: s?.endTime,
      cover: s?.cover,
      dianpingUUID: s?.dianpingUUID,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      screenshots: _screenshots.isEmpty ? null : _screenshots.join(','),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final form = _buildFormData();
    try {
      final notifier = ref.read(scheduleProvider(widget.travel.id!).notifier);
      if (widget.schedule == null) {
        await notifier.add(form);
      } else {
        await notifier.edit(form);
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
    final isEdit = widget.schedule != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        child: BackdropFilter(
          filter: GlassSpec.sheetBlur,
          child: Container(
            decoration: const BoxDecoration(
              color: GlassSpec.sheetBg, // 72% white
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              border: Border(top: BorderSide(color: GlassSpec.sheetBorder, width: 1)),
            ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle
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
                  // ── Title bar
                  Row(
                    children: [
                      Text(isEdit ? '编辑行程' : '新建行程',
                          style: AppTextStyles.title.copyWith(fontSize: 20)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 26, height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0x1A1C1C1E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 12,
                              color: AppColors.inkSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── iOS grouped form card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        // 类型
                        _FormRow(
                          label: '类型',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _TypeChip(
                                emoji: '📍',
                                label: '地点',
                                selected: !_isHotel,
                                color: AppColors.primary,
                                onTap: () => setState(() => _isHotel = false),
                              ),
                              const SizedBox(width: 8),
                              _TypeChip(
                                emoji: '🏨',
                                label: '酒店',
                                selected: _isHotel,
                                color: AppColors.lavender,
                                onTap: () => setState(() => _isHotel = true),
                              ),
                            ],
                          ),
                        ),
                        const _FormDivider(),
                        // 名称
                        _FormRow(
                          label: '名称',
                          child: TextFormField(
                            controller: _nameCtrl,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14, color: AppColors.inkPrimary),
                            decoration: _noBorderDecoration('输入名称'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                          ),
                        ),
                        const _FormDivider(),
                        // 截图
                        _FormRow(
                          label: '截图',
                          crossAlign: CrossAxisAlignment.center,
                          child: ScreenshotPickerField(
                            value: _screenshots,
                            onChanged: (v) => setState(() => _screenshots = v),
                          ),
                        ),
                        const _FormDivider(),
                        // 备注
                        _FormRow(
                          label: '备注',
                          crossAlign: CrossAxisAlignment.start,
                          child: TextField(
                            controller: _notesCtrl,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14, color: AppColors.inkSecondary),
                            maxLines: 4,
                            minLines: 2,
                            decoration: _noBorderDecoration('添加备注（可选）'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Dark CTA
                  GestureDetector(
                    onTap: _saving ? null : _submit,
                    child: Container(
                      height: 48,
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
                                  Text(isEdit ? '保存修改' : '创建行程',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  const SizedBox(width: 6),
                                  const Text('→',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ],
                              ),
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

InputDecoration _noBorderDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.inkTertiary, fontSize: 14),
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  filled: false,
  isDense: true,
  contentPadding: EdgeInsets.zero,
);

// ── iOS-style form row ──────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    required this.child,
    this.crossAlign = CrossAxisAlignment.center,
  });
  final String label;
  final Widget child;
  final CrossAxisAlignment crossAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: crossAlign,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: crossAlign == CrossAxisAlignment.start
                  ? const EdgeInsets.only(top: 2)
                  : EdgeInsets.zero,
              child: Text(label, style: const TextStyle(
                fontSize: 14, color: AppColors.inkPrimary)),
            ),
          ),
          Expanded(child: child),
        ],
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : const Color(0x0A1C1C1E),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.25) : const Color(0x0F1C1C1E),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? color : AppColors.inkTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
