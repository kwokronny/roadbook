// lib/features/luggage/presentation/widgets/add_item_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../shared/constants/luggage_presets.dart';
import '../../../../shared/models/luggage.dart';
import '../../../../shared/widgets/glass_drawer.dart';
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
    return showGlassDrawer<void>(
      context: context,
      title: '添加物品',
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
  final List<TextEditingController> _customCtrls = [TextEditingController()];
  final List<FocusNode> _customFocusNodes = [FocusNode()];
  final Set<String> _selected = {};
  String _query = '';
  bool _showCustomInput = false;
  late final Set<String> _existingTexts;

  @override
  void initState() {
    super.initState();
    _existingTexts = widget.existingItems.map((i) => i.text).toSet();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchBar(),
        const SizedBox(height: 4),
        Flexible(
          child: _query.isNotEmpty ? _buildSearchView() : _buildPresetView(),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            style: AppTextStyles.subheadline,
            decoration: InputDecoration(
              hintText: '搜索或输入物品名…',
              hintStyle: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search,
                  size: 18, color: AppColors.textSecondary),
              prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(Icons.close,
                          size: 14, color: AppColors.textSecondary),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );

  // ── White card list ──────────────────────────────────────────────────────

  Widget _wrapInCard(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          ),
        ),
      );

  Widget _buildPresetView() {
    final allPresets = {..._categoryPresets, ...universalPresets}.toList();
    allPresets.sort((a, b) {
      final aExists = _existingTexts.contains(a);
      final bExists = _existingTexts.contains(b);
      if (aExists == bExists) return 0;
      return aExists ? 1 : -1;
    });
    final items = ['__custom__', ...allPresets];
    return _wrapInCard(
      ListView.separated(
        shrinkWrap: false,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(left: 50),
          child: Divider(
              height: 0.5, thickness: 0.5, color: Color(0x0F1C1C1E)),
        ),
        itemBuilder: (_, i) {
          if (items[i] == '__custom__') return _buildCustomInputRow();
          return _buildSelectRow(items[i] as String);
        },
      ),
    );
  }

  Widget _buildSearchView() {
    final rows = <Widget>[..._searchResults.map(_buildSelectRow)];
    if (_queryIsNew) rows.add(_buildAddNewRow());
    if (rows.isEmpty) {
      return _wrapInCard(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('无结果', style: AppTextStyles.caption),
          ),
        ),
      );
    }
    return _wrapInCard(
      ListView.separated(
        shrinkWrap: false,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(left: 50),
          child: Divider(
              height: 0.5, thickness: 0.5, color: Color(0x0F1C1C1E)),
        ),
        itemBuilder: (_, i) => rows[i],
      ),
    );
  }

  Widget _buildSelectRow(String text) {
    final alreadyHas = _existingTexts.contains(text);
    final selected = _selected.contains(text);
    return GestureDetector(
      onTap: alreadyHas
          ? null
          : () => setState(() {
                if (selected) {
                  _selected.remove(text);
                } else {
                  _selected.add(text);
                }
              }),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: alreadyHas
                    ? AppColors.background
                    : selected
                        ? AppColors.primary
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: alreadyHas
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (alreadyHas)
              const Text('已有',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewRow() {
    return GestureDetector(
      onTap: () => setState(() => _selected.add(_query)),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(Icons.add, size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                text: '添加 "',
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary),
                children: [
                  TextSpan(
                      text: _query,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                  const TextSpan(text: '" 为新物品'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInputRow() {
    if (!_showCustomInput) {
      return GestureDetector(
        onTap: () => setState(() => _showCustomInput = true),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              const Text('自定义物品',
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
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasText ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: hasText ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: hasText
                ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                hintText: '输入自定义物品名称',
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

  Widget _buildAddButton() {
    final customCount = _showCustomInput
        ? _customCtrls.where((c) => c.text.trim().isNotEmpty).length
        : 0;
    final count = _selected.length + customCount;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: count > 0 ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPill,
              disabledBackgroundColor: AppColors.textTertiary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
            ),
            child: Text(
              count > 0
                  ? '添加 $count 项到「${widget.categoryName}」'
                  : '选择物品',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final items = _selected.toList();
    for (final ctrl in _customCtrls) {
      final text = ctrl.text.trim();
      if (text.isNotEmpty && !_existingTexts.contains(text)) {
        items.add(text);
      }
    }
    await ref
        .read(luggageProvider(widget.travelId).notifier)
        .addItems(widget.categoryId, items);
    if (mounted) Navigator.pop(context);
  }
}
