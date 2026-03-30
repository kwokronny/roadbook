// lib/features/luggage/presentation/widgets/luggage_category_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/luggage.dart';
import '../../domain/luggage_provider.dart';

class LuggageCategorySection extends ConsumerStatefulWidget {
  const LuggageCategorySection({
    super.key,
    required this.travelId,
    required this.category,
    required this.canEdit,
    required this.checkedIds,
    required this.onAddItemTap,
  });

  final int travelId;
  final LuggageCategory category;
  final bool canEdit;
  final Set<String> checkedIds;
  final VoidCallback onAddItemTap;

  @override
  ConsumerState<LuggageCategorySection> createState() =>
      _LuggageCategorySectionState();
}

class _LuggageCategorySectionState
    extends ConsumerState<LuggageCategorySection> {
  bool _expanded = true;

  int get _checkedInCat => widget.category.items
      .where((i) => widget.checkedIds.contains(i.id))
      .length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.contentCard),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_expanded) ...[
            const Divider(
                height: 0.5, thickness: 0.5, color: AppColors.separator),
            ...widget.category.items.map(_buildItemRow),
            if (widget.canEdit) _buildAddItemRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      onLongPress: widget.canEdit ? _confirmDelete : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Text(widget.category.emoji,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.category.name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ),
              Text(
                '$_checkedInCat/${widget.category.items.length}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _expanded ? 0 : -0.25,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more,
                    size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(LuggageItem item) {
    final checked = widget.checkedIds.contains(item.id);
    return Dismissible(
      key: ValueKey(item.id),
      direction: widget.canEdit
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.destructive,
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 20),
      ),
      onDismissed: (_) => ref
          .read(luggageProvider(widget.travelId).notifier)
          .deleteItem(widget.category.id, item.id),
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(luggageProvider(widget.travelId).notifier)
                    .toggleCheck(item.id),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: checked ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: checked
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.text,
                style: TextStyle(
                  fontSize: 15,
                  color: checked
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddItemRow() {
    return GestureDetector(
      onTap: widget.onAddItemTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.add, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('添加物品',
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.contentCard)),
        title: const Text('删除分类'),
        content: Text('确认删除「${widget.category.name}」及其所有物品？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除',
                style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref
          .read(luggageProvider(widget.travelId).notifier)
          .deleteCategory(widget.category.id);
    }
  }
}
