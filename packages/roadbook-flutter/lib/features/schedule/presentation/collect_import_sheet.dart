// lib/features/schedule/presentation/collect_import_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../data/collect_import_service.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_provider.dart';

enum _ImportMode { ai, dianping }

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
  _ImportMode _mode = _ImportMode.ai;
  _Phase _phase = _Phase.input;
  final _jsonCtrl = TextEditingController();
  String? _parseError;
  List<_ImportItem> _items = [];

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  Future<void> _startImport() async {
    setState(() => _parseError = null);

    // ── 解析 JSON ────────────────────────────────────────────────────────────
    List<ScheduleFormData> forms;
    try {
      forms = _mode == _ImportMode.ai
          ? CollectImportService.parseAiJson(_jsonCtrl.text.trim(),
              tId: widget.travelId)
          : CollectImportService.parseDianpingJson(_jsonCtrl.text.trim(),
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

    if (mounted) setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
      child: Row(
        children: [
          const Text('批量导入', style: AppTextStyles.appBarTitle),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
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
          // ── 模式切换
          SegmentedButton<_ImportMode>(
            segments: const [
              ButtonSegment(
                  value: _ImportMode.ai,
                  label: Text('AI 采集'),
                  icon: Icon(Icons.auto_awesome, size: 16)),
              ButtonSegment(
                  value: _ImportMode.dianping,
                  label: Text('点评收藏'),
                  icon: Icon(Icons.star_outline, size: 16)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) =>
                setState(() => _mode = s.first),
            style: const ButtonStyle(
              iconSize: WidgetStatePropertyAll(16),
            ),
          ),
          const SizedBox(height: 12),
          // ── 说明文字
          Text(
            _mode == _ImportMode.ai
                ? 'AI 采集：粘贴行程 JSON 数组（包含 name / coordinate / address 字段）'
                : '点评收藏：粘贴大众点评导出的完整 JSON（含 records[0].collectItemList）',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          // ── JSON 输入框
          TextField(
            controller: _jsonCtrl,
            maxLines: 10,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '在此粘贴 JSON…',
              filled: true,
              fillColor: const Color(0xFFF5F5F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide.none,
              ),
              errorText: _parseError,
            ),
          ),
          const SizedBox(height: 16),
          // ── 导入按钮
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.fab),
            ),
            child: TextButton(
              onPressed: _startImport,
              child: const Text(
                '开始导入',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
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
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
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
          child: Icon(Icons.circle_outlined,
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
        return const Icon(Icons.check_circle,
            size: 20, color: AppColors.success);
      case _ItemStatus.error:
        return const Icon(Icons.cancel, size: 20, color: Colors.red);
    }
  }
}
