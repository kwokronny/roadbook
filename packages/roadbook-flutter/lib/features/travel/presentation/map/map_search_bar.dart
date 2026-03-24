// lib/features/travel/presentation/map/map_search_bar.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
    required this.onSearch,
    required this.onClose,
  });

  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onClose;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCities = ['全国', ...widget.cities];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedCity,
              items: allCities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) widget.onCityChanged(v);
              },
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              icon: const Icon(Icons.expand_more,
                  size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '搜索地点、景区、餐厅...',
                hintStyle: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              style: AppTextStyles.caption,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) widget.onSearch(v.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}
