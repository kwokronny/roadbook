import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../domain/luggage_provider.dart';
import 'widgets/luggage_category_section.dart';
import 'widgets/add_item_sheet.dart';
import 'widgets/template_sheet.dart';

class LuggageScreen extends ConsumerWidget {
  const LuggageScreen({super.key, required this.travelId});

  final int travelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onPressed: () =>
                    TemplateSheet.show(context, travelId: travelId),
                child: const Text('导入模板',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 14)),
              ),
          ],
        ),
        floatingActionButton: state.canEdit
            ? FloatingActionButton(
                onPressed: () =>
                    _showAddCategorySheet(context, ref, state.canEdit),
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
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
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

  void _showAddCategorySheet(
      BuildContext context, WidgetRef ref, bool canEdit) {
    if (!canEdit) return;
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet)),
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
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (_, setS) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: ctrl,
                      autofocus: true,
                      onChanged: (_) => setS(() {}),
                      decoration: InputDecoration(
                        hintText: '分类名称',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.input),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: ctrl.text.trim().isEmpty
                            ? null
                            : () async {
                                final name = ctrl.text.trim();
                                Navigator.pop(ctx);
                                await ref
                                    .read(luggageProvider(travelId)
                                        .notifier)
                                    .addCategory(name);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.textTertiary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppRadius.input)),
                        ),
                        child: const Text('添加',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
