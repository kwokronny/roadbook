// lib/features/schedule/presentation/collect_import_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';

import '../data/collect_import_service.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_provider.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

    // ── 解析数据 ─────────────────────────────────────────────────────────────
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

    // ── 逐条导入 ─────────────────────────────────────────────────────────────
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        child: BackdropFilter(
          filter: GlassSpec.sheetBlur,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: GlassSpec.sheetBg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              border: Border(top: BorderSide(color: GlassSpec.sheetBorder, width: 1)),
            ),
            child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: GlassSpec.dragHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _buildHeader(),
              Flexible(
                child: _phase == _Phase.input
                    ? _buildInputPhase()
                    : _buildProgressPhase(),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
      child: Row(
        children: [
          Text('批量导入', style: AppTextStyles.title.copyWith(fontSize: 20)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                color: Color(0x1A1C1C1E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14,
                  color: AppColors.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 12, AppSpacing.pageHorizontal, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 说明文字
          Text(
            '粘贴大众点评收藏夹的分享链接',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          // ── 输入框
          TextField(
            controller: _urlCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: '粘贴点评收藏分享链接…',
              filled: true,
              fillColor: const Color(0x0A1C1C1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide.none,
              ),
              errorText: _parseError,
            ),
          ),
          const SizedBox(height: 16),
          // ── 导入按钮
          GestureDetector(
            onTap: _phase == _Phase.input ? _startImport : null,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.darkPill,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('开始导入',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    SizedBox(width: 6),
                    Text('→', style: TextStyle(color: Colors.white, fontSize: 15)),
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
        // ── 统计行
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
        // ── 进度列表
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
                                style: AppTextStyles.caption.copyWith(
                                    color: Colors.red),
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
        // ── 关闭按钮（仅完成后显示）
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
                  child: Text('关闭', style: TextStyle(
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
          width: 20, height: 20,
          child: Icon(Icons.circle_outlined,
              size: 18, color: AppColors.textDisabled),
        );
      case _ItemStatus.loading:
        return const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        );
      case _ItemStatus.success:
        return const Icon(Icons.check_circle,
            size: 20, color: AppColors.success);
      case _ItemStatus.error:
        return const Icon(Icons.close, size: 20, color: Colors.red);
    }
  }
}
