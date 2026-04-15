import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../domain/luggage_provider.dart';
import 'widgets/luggage_category_section.dart';
import 'widgets/add_item_sheet.dart';

const _categoryTemplates = [
  {'emoji': '📋', 'name': '证件'},
  {'emoji': '👕', 'name': '衣物'},
  {'emoji': '📱', 'name': '电子'},
  {'emoji': '🪥', 'name': '洗漱'},
  {'emoji': '💊', 'name': '药品'},
  {'emoji': '🧴', 'name': '防晒护肤'},
  {'emoji': '🎒', 'name': '随身'},
  {'emoji': '🍫', 'name': '零食'},
];

class LuggageScreen extends ConsumerWidget {
  const LuggageScreen({super.key, required this.travelId});

  final int travelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<LuggageState>>(luggageProvider(travelId), (_, next) {
      final msg = next.valueOrNull?.errorMessage;
      if (msg != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败：$msg')),
            );
          }
        });
      }
    });

    final async = ref.watch(luggageProvider(travelId));

    return async.when(
      loading: () => const Scaffold(
        body: Center(
            child:
                CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('行李清单')),
        body: Center(
            child:
                Text(e.toString(), style: AppTextStyles.caption)),
      ),
      data: (state) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('行李清单'),
          actions: [
            if (state.canEdit)
              TextButton(
                onPressed: () => _confirmClearAllChecks(context, ref),
                child: const Text('重新清点',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 14)),
              ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildProgress(state)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final cat = state.categories[i];
                  return LuggageCategorySection(
                    travelId: travelId,
                    category: cat,
                    canEdit: state.canEdit,
                    checkedIds: state.checkedIds,
                    onAddItemTap: () => AddItemSheet.show(
                      context,
                      travelId: travelId,
                      categoryId: cat.id,
                      categoryName: cat.name,
                      existingItems: cat.items,
                    ),
                  );
                },
                childCount: state.categories.length,
              ),
            ),
            if (state.canEdit)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal, 8, AppSpacing.pageHorizontal, 24),
                  child: GestureDetector(
                    onTap: () => _showAddCategorySheet(context, ref, state),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x1F1C1C1E)),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18, color: AppColors.inkSecondary),
                          SizedBox(width: 6),
                          Text('添加分类', style: TextStyle(
                            fontSize: 15, color: AppColors.inkSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (!state.canEdit)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(LuggageState state) {
    final total = state.totalItems;
    final checked = state.checkedCount;
    final progress = total == 0 ? 0.0 : checked / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 16, AppSpacing.pageHorizontal, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$checked / $total 已打包',
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, WidgetRef ref, LuggageState state) {
    if (!state.canEdit) return;
    final existingNames = state.categories.map((c) => c.name).toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCategorySheet(
        travelId: travelId,
        existingNames: existingNames,
      ),
    );
  }

  Future<void> _confirmClearAllChecks(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.contentCard)),
        title: const Text('确认重新清点？'),
        content: const Text('将取消所有已打包的勾选'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(luggageProvider(travelId).notifier).clearAllChecks();
    }
  }
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet({
    required this.travelId,
    required this.existingNames,
  });
  final int travelId;
  final Set<String> existingNames;

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  bool _showCustomInput = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        child: BackdropFilter(
          filter: GlassSpec.sheetBlur,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: GlassSpec.sheetBg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              border: Border(top: BorderSide(color: GlassSpec.sheetBorder, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('添加分类',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Consumer(
                  builder: (_, ref, __) => GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      ..._categoryTemplates.map((t) {
                        final name = t['name']!;
                        final emoji = t['emoji']!;
                        final exists = widget.existingNames.contains(name);
                        return GestureDetector(
                          onTap: exists
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await ref
                                      .read(luggageProvider(widget.travelId).notifier)
                                      .addCategory(name, emoji: emoji);
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: exists
                                  ? AppColors.background
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: exists
                                    ? AppColors.border
                                    : const Color(0x1F1C1C1E),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$emoji $name',
                              style: TextStyle(
                                fontSize: 14,
                                color: exists
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () => setState(() => _showCustomInput = !_showCustomInput),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showCustomInput
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: _showCustomInput
                                  ? AppColors.primary
                                  : const Color(0x1F1C1C1E),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '✏️ 自定义',
                            style: TextStyle(
                              fontSize: 14,
                              color: _showCustomInput
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showCustomInput) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '分类名称',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (_, ref, __) => SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _ctrl.text.trim().isEmpty
                            ? null
                            : () async {
                                final name = _ctrl.text.trim();
                                Navigator.pop(context);
                                await ref
                                    .read(luggageProvider(widget.travelId).notifier)
                                    .addCategory(name);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.textTertiary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input)),
                        ),
                        child: const Text('添加',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
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
