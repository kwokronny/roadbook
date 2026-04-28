// lib/features/schedule/presentation/collect_import_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/glass_drawer.dart';

import '../data/collect_import_service.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_provider.dart';
import 'package:hugeicons/hugeicons.dart';

enum _Phase { input, importing, done }

enum _ItemStatus { pending, loading, success, error }

class _ImportItem {
  _ImportItem({required this.formData});
  final ScheduleFormData formData;
  _ItemStatus status = _ItemStatus.pending;
  String? errorMessage;
}

class CollectImportSheet extends ConsumerStatefulWidget {
  const CollectImportSheet({super.key, required this.travelId});
  final int travelId;

  static Future<void> show(BuildContext context, int travelId) {
    return showGlassDrawer<void>(
      context: context,
      title: '批量导入',
      builder: (_) => CollectImportSheet(travelId: travelId),
    );
  }

  @override
  ConsumerState<CollectImportSheet> createState() => _CollectImportSheetState();
}

class _CollectImportSheetState extends ConsumerState<CollectImportSheet> {
  _Phase _phase = _Phase.input;
  final _urlCtrl = TextEditingController();
  String? _parseError;
  List<_ImportItem> _items = [];

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _startImport() async {
    setState(() => _parseError = null);

    List<ScheduleFormData> forms;
    try {
      forms = await CollectImportService.fetchDianpingAlbum(
          _urlCtrl.text.trim(),
          tId: widget.travelId);
    } on CollectImportException catch (e) {
      setState(() => _parseError = e.message);
      return;
    }

    if (forms.isEmpty) {
      setState(() => _parseError = '未找到任何行程，请检查 JSON 内容');
      return;
    }

    setState(() {
      _items = forms.map((f) => _ImportItem(formData: f)).toList();
      _phase = _Phase.importing;
    });

    final repo = ref.read(scheduleRepositoryProvider);
    for (int i = 0; i < _items.length; i++) {
      if (!mounted) break;
      setState(() => _items[i].status = _ItemStatus.loading);
      try {
        await repo.add(_items[i].formData);
        if (mounted) setState(() => _items[i].status = _ItemStatus.success);
      } catch (e) {
        if (mounted) {
          setState(() {
            _items[i].status = _ItemStatus.error;
            _items[i].errorMessage = e.toString();
          });
        }
      }
    }

    if (mounted) {
      ref.invalidate(scheduleProvider(widget.travelId));
      setState(() => _phase = _Phase.done);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _phase == _Phase.input
              ? _buildInputPhase()
              : _buildProgressPhase(),
        ),
      ],
    );
  }

  Widget _buildInputPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _urlCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 15, color: AppColors.inkPrimary),
            decoration: InputDecoration(
              hintText: '粘贴大众点评收藏夹的分享链接…',
              hintStyle: const TextStyle(
                  color: AppColors.inkTertiary, fontSize: 15),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.cover),
                borderSide: const BorderSide(color: Color(0x1A1C1C1E)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.cover),
                borderSide: const BorderSide(color: Color(0x1A1C1C1E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.cover),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.40)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              errorText: _parseError,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _phase == _Phase.input ? _startImport : null,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.darkPill,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('开始导入',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    SizedBox(width: 6),
                    Text('→',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPhase() {
    final successCount =
        _items.where((i) => i.status == _ItemStatus.success).length;
    final errorCount =
        _items.where((i) => i.status == _ItemStatus.error).length;
    final isRunning = _phase == _Phase.importing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 12),
          child: Row(
            children: [
              Text(
                isRunning ? '导入中…' : '导入完成',
                style: AppTextStyles.cardTitle,
              ),
              const Spacer(),
              Text(
                '✓ $successCount  ✗ $errorCount',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: AppSpacing.pageHorizontal),
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final item = _items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    _statusIcon(item.status),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.formData.name,
                              style: AppTextStyles.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (item.errorMessage != null)
                            Text(item.errorMessage!,
                                style: AppTextStyles.caption
                                    .copyWith(color: Colors.red),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_phase == _Phase.done)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 8, AppSpacing.pageHorizontal, 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x1F1C1C1E)),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Center(
                  child: Text('关闭',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.inkSecondary)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusIcon(_ItemStatus status) {
    switch (status) {
      case _ItemStatus.pending:
        return const SizedBox(
          width: 20,
          height: 20,
          child: Icon(HugeIcons.strokeRoundedCircle,
              size: 18, color: AppColors.textDisabled),
        );
      case _ItemStatus.loading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        );
      case _ItemStatus.success:
        return const Icon(HugeIcons.strokeRoundedCheckmarkCircle01,
            size: 20, color: AppColors.success);
      case _ItemStatus.error:
        return const Icon(HugeIcons.strokeRoundedCancel01, size: 20, color: Colors.red);
    }
  }
}
