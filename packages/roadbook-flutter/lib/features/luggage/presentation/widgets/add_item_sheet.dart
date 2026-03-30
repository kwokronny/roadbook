// lib/features/luggage/presentation/widgets/add_item_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../shared/constants/luggage_presets.dart';
import '../../../../shared/models/luggage.dart';
import '../../domain/luggage_provider.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({
    super.key,
    required this.travelId,
    required this.categoryId,
    required this.categoryName,
    required this.existingItems,
  });

  final int travelId;
  final String categoryId;
  final String categoryName;
  final List<LuggageItem> existingItems;

  static Future<void> show(
    BuildContext context, {
    required int travelId,
    required String categoryId,
    required String categoryName,
    required List<LuggageItem> existingItems,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddItemSheet(
        travelId: travelId,
        categoryId: categoryId,
        categoryName: categoryName,
        existingItems: existingItems,
      ),
    );
  }

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _searchCtrl = TextEditingController();
  final Set<String> _selected = {};
  String _query = '';
  late final Set<String> _existingTexts;

  @override
  void initState() {
    super.initState();
    _existingTexts = widget.existingItems.map((i) => i.text).toSet();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _categoryPresets => presetItemsFor(widget.categoryName);

  List<String> get _searchResults {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    final all = {..._categoryPresets, ...universalPresets}.toList();
    return all.where((s) => s.toLowerCase().contains(q)).toList();
  }

  bool get _queryIsNew =>
      _query.isNotEmpty &&
      _searchResults.isEmpty &&
      !_existingTexts.contains(_query) &&
      !_selected.contains(_query);

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
              _buildHandle(),
              _buildTitleBar(),
              _buildSearchBar(),
              const Divider(
                  height: 0.5, thickness: 0.5, color: AppColors.separator),
              Flexible(
                  child: _query.isNotEmpty
                      ? _buildSearchView()
                      : _buildPresetView()),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildTitleBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('添加物品',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            if (_selected.isNotEmpty)
              Text('已选 ${_selected.length}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.primary)),
          ],
        ),
      );

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            style: AppTextStyles.subheadline,
            decoration: InputDecoration(
              hintText: '搜索或输入物品名…',
              hintStyle: AppTextStyles.caption,
              prefixIcon: const Icon(Icons.search,
                  size: 18, color: AppColors.textSecondary),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(Icons.cancel,
                          size: 18, color: AppColors.textSecondary),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );

  Widget _buildSearchView() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ..._searchResults.map(_buildSelectRow),
        if (_queryIsNew)
          ListTile(
            onTap: () => setState(() => _selected.add(_query)),
            title: RichText(
              text: TextSpan(
                text: '添加 "',
                style: AppTextStyles.subheadline,
                children: [
                  TextSpan(
                      text: _query,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  const TextSpan(text: '" 为新物品'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPresetView() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildGroupHeader('${widget.categoryName}常用'),
        ..._categoryPresets.map(_buildSelectRow),
        const SizedBox(height: 8),
        _buildGroupHeader('通用常用'),
        ...universalPresets.map(_buildSelectRow),
        _buildCustomInputRow(),
      ],
    );
  }

  Widget _buildGroupHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(title,
            style: AppTextStyles.caption
                .copyWith(fontWeight: FontWeight.w600)),
      );

  Widget _buildSelectRow(String text) {
    final alreadyHas = _existingTexts.contains(text);
    final selected = _selected.contains(text);
    return ListTile(
      dense: true,
      enabled: !alreadyHas,
      onTap: alreadyHas
          ? null
          : () => setState(() {
                if (selected) {
                  _selected.remove(text);
                } else {
                  _selected.add(text);
                }
              }),
      leading: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? AppColors.primary
              : alreadyHas
                  ? AppColors.background
                  : Colors.transparent,
          border: Border.all(
            color: alreadyHas
                ? AppColors.textTertiary
                : selected
                    ? AppColors.primary
                    : AppColors.border,
            width: 1.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: alreadyHas
              ? AppColors.textTertiary
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCustomInputRow() {
    return ListTile(
      dense: true,
      onTap: _showCustomInput,
      leading: const Icon(Icons.add_circle_outline,
          size: 22, color: AppColors.primary),
      title: const Text('输入自定义物品…',
          style: TextStyle(fontSize: 15, color: AppColors.primary)),
    );
  }

  Future<void> _showCustomInput() async {
    final ctrl = TextEditingController();
    try {
      final text = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('自定义物品'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: '物品名称'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('添加'),
            ),
          ],
        ),
      );
      if (text != null && text.isNotEmpty && !_existingTexts.contains(text)) {
        setState(() => _selected.add(text));
      }
    } finally {
      ctrl.dispose();
    }
  }

  Widget _buildAddButton() {
    final count = _selected.length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: count > 0 ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textTertiary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input)),
            ),
            child: Text(
              '添加 $count 项到「${widget.categoryName}」',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(luggageProvider(widget.travelId).notifier)
        .addItems(widget.categoryId, _selected.toList());
    if (mounted) Navigator.pop(context);
  }
}
