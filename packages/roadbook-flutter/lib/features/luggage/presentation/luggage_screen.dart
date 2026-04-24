import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/app_confirm_dialog.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/glass_drawer.dart';
import '../domain/luggage_provider.dart';
import 'widgets/luggage_category_section.dart';
import 'widgets/add_item_sheet.dart';
import 'package:hugeicons/hugeicons.dart';

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
          if (context.mounted) AppToast.error(context, '保存失败：$msg');
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leadingWidth: AppSpacing.pageHorizontal + 32 + 8,
          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.pageHorizontal),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.darkPill, shape: BoxShape.circle,
                  ),
                  child: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          title: const Text('行李清单', style: AppTextStyles.appBarTitle),
          actions: [
            if (state.canEdit)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.pageHorizontal),
                child: GestureDetector(
                  onTap: () => _confirmClearAllChecks(context, ref),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkPill,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Center(
                      child: Text('重新清点',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
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
                        color: AppColors.darkPill,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(HugeIcons.strokeRoundedAdd01, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text('添加分类', style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xB8FFFFFF), // rgba(255,255,255,0.72)
          borderRadius: BorderRadius.circular(24),
          boxShadow: GlassSpec.cardShadow,
        ),
        child: Row(
          children: [
            Text('$checked / $total 已打包',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, WidgetRef ref, LuggageState state) {
    if (!state.canEdit) return;
    final existingNames = state.categories.map((c) => c.name).toSet();
    showGlassDrawer<void>(
      context: context,
      title: '添加分类',
      builder: (_) => _AddCategorySheet(
        travelId: travelId,
        existingNames: existingNames,
      ),
    );
  }

  Future<void> _confirmClearAllChecks(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '重新清点',
      message: '将取消所有已打包的勾选',
      confirmLabel: '确认',
      isDestructive: false,
    );
    if (confirmed) {
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
  final List<TextEditingController> _customCtrls = [TextEditingController()];
  final List<FocusNode> _customFocusNodes = [FocusNode()];

  @override
  void dispose() {
    for (final c in _customCtrls) c.dispose();
    for (final f in _customFocusNodes) f.dispose();
    super.dispose();
  }

  void _onCustomChanged(int i, String v) {
    setState(() {
      if (v.trim().isNotEmpty) {
        if (i == _customCtrls.length - 1) {
          _customCtrls.add(TextEditingController());
          _customFocusNodes.add(FocusNode());
        }
      } else {
        for (var j = _customCtrls.length - 1; j > i; j--) {
          _customCtrls[j].dispose();
          _customFocusNodes[j].dispose();
          _customCtrls.removeAt(j);
          _customFocusNodes.removeAt(j);
        }
      }
    });
  }

  List<MapEntry<int, Map<String, String>>> get _sortedTemplateEntries {
    final entries = _categoryTemplates.asMap().entries.toList();
    entries.sort((a, b) {
      final aExists = widget.existingNames.contains(a.value['name']);
      final bExists = widget.existingNames.contains(b.value['name']);
      if (aExists == bExists) return 0;
      return aExists ? 1 : -1;
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── List (white card)
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _categoryTemplates.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _buildCustomRow();
                }
                final sortedEntries = _sortedTemplateEntries;
                final entry = sortedEntries[i - 1];
                final originalIdx = entry.key;
                final t = entry.value;
                final name = t['name']!;
                final emoji = t['emoji']!;
                final itemsStr = t['items'] ?? '';
                final itemCount =
                    itemsStr.isNotEmpty ? itemsStr.split(',').length : 0;
                final exists = widget.existingNames.contains(name);
                final selected = _selected.contains(originalIdx);

                return GestureDetector(
                  onTap: exists
                      ? null
                      : () {
                          setState(() {
                            if (selected) {
                              _selected.remove(originalIdx);
                            } else {
                              _selected.add(originalIdx);
                            }
                          });
                        },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: exists
                                ? AppColors.background
                                : selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                            border: Border.all(
                              color: exists
                                  ? AppColors.textTertiary
                                  : selected
                                      ? AppColors.primary
                                      : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: selected
                              ? const Icon(HugeIcons.strokeRoundedTick01,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: exists
                                      ? AppColors.textTertiary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (itemCount > 0)
                                Text(
                                  '$itemCount 件常用物品',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: exists
                                        ? AppColors.textTertiary
                                        : AppColors.inkTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (exists)
                          const Text('已添加',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // ── Add button
        Consumer(
          builder: (_, ref, __) {
            final customCount = _showCustomInput
                ? _customCtrls.where((c) => c.text.trim().isNotEmpty).length
                : 0;
            final total = _selected.length + customCount;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: total == 0
                        ? null
                        : () async {
                            Navigator.pop(context);
                            final notifier = ref.read(
                                luggageProvider(widget.travelId).notifier);
                            for (final idx in _selected) {
                              final t = _categoryTemplates[idx];
                              final itemsStr = t['items'] ?? '';
                              final presetItems = itemsStr.isNotEmpty
                                  ? itemsStr.split(',')
                                  : <String>[];
                              await notifier.addCategory(t['name']!,
                                  emoji: t['emoji']!,
                                  presetItems: presetItems);
                            }
                            for (final ctrl in _customCtrls) {
                              final text = ctrl.text.trim();
                              if (text.isNotEmpty) {
                                await notifier.addCategory(text);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPill,
                      disabledBackgroundColor: AppColors.textTertiary,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill)),
                    ),
                    child: Text(
                      total > 0 ? '添加 $total 个分类' : '选择分类',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomRow() {
    if (!_showCustomInput) {
      return GestureDetector(
        onTap: () => setState(() => _showCustomInput = true),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              const Text('自定义分类',
                  style: TextStyle(fontSize: 15, color: AppColors.primary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < _customCtrls.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Divider(
                  height: 0.5, thickness: 0.5, color: Color(0x0F1C1C1E)),
            ),
          _buildCustomFieldRow(i),
        ],
      ],
    );
  }

  Widget _buildCustomFieldRow(int i) {
    final hasText = _customCtrls[i].text.trim().isNotEmpty;
    return Padding(
      key: ObjectKey(_customCtrls[i]),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasText ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: hasText ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: hasText
                ? const Icon(HugeIcons.strokeRoundedTick01, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _customCtrls[i],
              focusNode: _customFocusNodes[i],
              autofocus: i == 0,
              onChanged: (v) => _onCustomChanged(i, v),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '输入自定义分类名称',
                hintStyle:
                    TextStyle(color: AppColors.textTertiary, fontSize: 15),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
