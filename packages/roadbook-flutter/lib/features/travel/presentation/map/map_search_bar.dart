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
    this.controller,
  });

  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onClose;
  final TextEditingController? controller;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  late final TextEditingController _ctrl;
  bool _ownsCtrl = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = TextEditingController();
      _ownsCtrl = true;
    }
  }

  @override
  void dispose() {
    if (_ownsCtrl) _ctrl.dispose();
    super.dispose();
  }

  void _doSearch() {
    final text = _ctrl.text.trim();
    if (text.isNotEmpty) widget.onSearch(text);
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
          Expanded(
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索地点、景区、餐厅...',
                hintStyle: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: _buildCityPrefix(allCities),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  color: AppColors.primary,
                  onPressed: _doSearch,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 18),
              onSubmitted: (_) => _doSearch(),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildCityPrefix(List<String> cities) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedCity,
          items: cities
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) widget.onCityChanged(v);
          },
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.expand_more,
              size: 14, color: AppColors.primary),
          isDense: true,
        ),
      ),
    );
  }
}
