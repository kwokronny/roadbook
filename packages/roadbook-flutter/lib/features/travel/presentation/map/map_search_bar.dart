// lib/features/travel/presentation/map/map_search_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'package:hugeicons/hugeicons.dart';


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
    return Row(
      children: [
        // Glass search bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.cover),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x40FFFFFF), // 25% white
                  borderRadius: BorderRadius.circular(AppRadius.cover),
                  border: Border.all(color: const Color(0x80FFFFFF)), // 50%
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2)),
                    BoxShadow(color: Color(0x8CFFFFFF), blurRadius: 0, offset: Offset(0, -0.5)), // inset top glow
                  ],
                ),
                child: Row(
                  children: [
                    _buildCityPrefix(allCities),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textInputAction: TextInputAction.search,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: '搜索地点、餐厅...',
                          hintStyle: TextStyle(
                            fontSize: 14, color: AppColors.inkTertiary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        style: const TextStyle(fontSize: 14, color: AppColors.inkPrimary),
                        onSubmitted: (_) => _doSearch(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Close circle button
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xD9FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xB3FFFFFF)),
              boxShadow: const [
                BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(HugeIcons.strokeRoundedCancel01, size: 14, color: AppColors.inkSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCityPrefix(List<String> cities) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.coralTint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: const Color(0x2EFF6B3D)), // rgba(255,107,61,0.18)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedCity,
          items: cities
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 11)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) widget.onCityChanged(v);
          },
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFD4410A),
            fontWeight: FontWeight.w500,
          ),
          icon: Text(' ▾', style: TextStyle(
              fontSize: 10, color: AppColors.primary.withValues(alpha: 0.5))),
          isDense: true,
        ),
      ),
    );
  }
}
