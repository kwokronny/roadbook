import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../domain/luggage_provider.dart';
import 'widgets/luggage_category_section.dart';
import 'widgets/add_item_sheet.dart';

const _categoryTemplates = [
  {'emoji': '📋', 'name': '证件', 'items': '护照,身份证,签证,机票打印件,酒店预订单,旅行保险单'},
  {'emoji': '👕', 'name': '衣物', 'items': 'T恤,内衣内裤,外套,袜子,运动鞋,睡衣'},
  {'emoji': '📱', 'name': '电子', 'items': '充电宝,手机充电线,转换插头,相机,耳机'},
  {'emoji': '🪥', 'name': '洗漱', 'items': '牙刷,牙膏,洗发水,沐浴露,护手霜,剃须刀'},
  {'emoji': '💊', 'name': '药品', 'items': '感冒药,肠胃药,止痛药,创可贴,防蚊液'},
  {'emoji': '🧴', 'name': '防晒护肤', 'items': '防晒霜,晒后修复乳,保湿喷雾,护唇膏,面膜'},
  {'emoji': '🎒', 'name': '随身', 'items': '钱包,钥匙,充电宝,纸巾,口罩,雨伞'},
  {'emoji': '🍫', 'name': '零食', 'items': '巧克力,坚果,饼干,糖果,牛肉干'},
  {'emoji': '🧥', 'name': '冬季御寒', 'items': '羽绒服,围巾,手套,毛帽,保暖内衣,暖宝宝'},
  {'emoji': '👗', 'name': '夏季清凉', 'items': '短裤,凉鞋,墨镜,泳衣,遮阳帽,防晒衣'},
  {'emoji': '⛷️', 'name': '滑雪装备', 'items': '滑雪手套,护目镜,面罩,暖宝宝,防水裤,厚袜子'},
  {'emoji': '💇', 'name': '洗护造型', 'items': '梳子,发胶,发夹,皮筋,干发帽,卷发棒'},
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
  final Set<int> _selected = {};
  bool _showCustomInput = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        child: BackdropFilter(
          filter: GlassSpec.sheetBlur,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: const BoxDecoration(
              color: GlassSpec.sheetBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              border: Border(top: BorderSide(color: GlassSpec.sheetBorder, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // ── Title bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('添加分类',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      const Spacer(),
                      if (_selected.isNotEmpty)
                        Text('已选 ${_selected.length}',
                            style: const TextStyle(fontSize: 14, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 0.5, thickness: 0.5, color: AppColors.separator),
                // ── List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _categoryTemplates.length + 1, // +1 for custom
                    itemBuilder: (_, i) {
                      if (i == _categoryTemplates.length) {
                        // Custom input row
                        return _buildCustomRow();
                      }
                      final t = _categoryTemplates[i];
                      final name = t['name']!;
                      final emoji = t['emoji']!;
                      final itemsStr = t['items'] ?? '';
                      final itemCount = itemsStr.isNotEmpty ? itemsStr.split(',').length : 0;
                      final exists = widget.existingNames.contains(name);
                      final selected = _selected.contains(i);

                      return GestureDetector(
                        onTap: exists ? null : () {
                          setState(() {
                            if (selected) {
                              _selected.remove(i);
                            } else {
                              _selected.add(i);
                            }
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              // Checkbox
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: exists
                                      ? AppColors.background
                                      : selected ? AppColors.primary : Colors.transparent,
                                  border: Border.all(
                                    color: exists
                                        ? AppColors.textTertiary
                                        : selected ? AppColors.primary : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Emoji
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              // Name + item count
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: exists ? AppColors.textTertiary : AppColors.textPrimary,
                                    )),
                                    if (itemCount > 0)
                                      Text('$itemCount 件常用物品', style: TextStyle(
                                        fontSize: 12,
                                        color: exists ? AppColors.textTertiary : AppColors.inkTertiary,
                                      )),
                                  ],
                                ),
                              ),
                              if (exists)
                                const Text('已添加', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // ── Add button
                Consumer(
                  builder: (_, ref, __) {
                    final hasCustom = _showCustomInput && _ctrl.text.trim().isNotEmpty;
                    final total = _selected.length + (hasCustom ? 1 : 0);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: total == 0 ? null : () async {
                              Navigator.pop(context);
                              final notifier = ref.read(luggageProvider(widget.travelId).notifier);
                              for (final idx in _selected) {
                                final t = _categoryTemplates[idx];
                                final itemsStr = t['items'] ?? '';
                                final presetItems = itemsStr.isNotEmpty ? itemsStr.split(',') : <String>[];
                                await notifier.addCategory(t['name']!, emoji: t['emoji']!, presetItems: presetItems);
                              }
                              if (hasCustom) {
                                await notifier.addCategory(_ctrl.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.textTertiary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.input)),
                            ),
                            child: Text(
                              total > 0 ? '添加 $total 个分类' : '选择分类',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showCustomInput = !_showCustomInput),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('自定义分类', style: TextStyle(fontSize: 15, color: AppColors.primary)),
                ],
              ),
            ),
          ),
          if (_showCustomInput) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '输入分类名称',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
