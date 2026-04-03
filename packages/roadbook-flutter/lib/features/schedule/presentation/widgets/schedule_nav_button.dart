// lib/features/schedule/presentation/widgets/schedule_nav_button.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme.dart';

class ScheduleNavButton extends StatelessWidget {
  const ScheduleNavButton({
    super.key,
    required this.coordinate,
    required this.name,
    required this.isHotel,
  });

  final String coordinate;
  final String name;
  final bool isHotel;

  bool get _isEnabled {
    if (coordinate.isEmpty) return false;
    if (coordinate == '0,0') return false;
    final parts = coordinate.split(',');
    return parts.length >= 2;
  }

  Color get _bgColor => isHotel ? AppColors.hotelLight : AppColors.primaryLight;
  Color get _borderColor => isHotel ? AppColors.hotelBorder : AppColors.primaryBorder;
  Color get _iconColor => isHotel ? AppColors.hotel : AppColors.primary;

  String _buildAmapUrl(String mapMode) {
    final parts = coordinate.split(',');
    final lon = parts[0];
    final lat = parts[1];
    final encodedName = Uri.encodeComponent(name);
    final t = {'car': 0, 'bus': 1, 'walk': 2, 'ride': 3}[mapMode] ?? 0;
    if (Platform.isIOS) {
      return 'iosamap://path?sourceApplication=roadbook'
          '&dlat=$lat&dlon=$lon&dname=$encodedName&dev=0&t=$t';
    } else {
      return 'amapuri://route/plan/'
          '?dlat=$lat&dlon=$lon&dname=$encodedName&dev=0&t=$t';
    }
  }

  String _buildDidiUrl() {
    final parts = coordinate.split(',');
    final lon = parts[0];
    final lat = parts[1];
    final encodedName = Uri.encodeComponent(name);
    return 'diditaxi://taxi?'
        'dlat=$lat&dlng=$lon&dname=$encodedName&maptype=gaode';
  }

  Future<void> _launch(String mapMode) async {
    final url = mapMode == 'didi' ? _buildDidiUrl() : _buildAmapUrl(mapMode);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static const List<Map<String, String>> _modes = [
    {'mode': 'car',  'emoji': '🚗', 'label': '驾车'},
    {'mode': 'didi', 'emoji': '🚕', 'label': '滴滴打车'},
    {'mode': 'bus',  'emoji': '🚌', 'label': '公交'},
    {'mode': 'walk', 'emoji': '🚶', 'label': '步行'},
    {'mode': 'ride', 'emoji': '🚲', 'label': '骑行'},
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isEnabled ? 1.0 : 0.38,
      child: PopupMenuButton<String>(
        enabled: _isEnabled,
        onSelected: _launch,
        offset: const Offset(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        color: AppColors.surface,
        elevation: 4,
        itemBuilder: (_) => _modes.map((m) {
          return PopupMenuItem<String>(
            value: m['mode'],
            height: 44,
            child: Row(children: [
              Text(m['emoji']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(m['label']!,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
            ]),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.navigation_rounded, size: 18, color: _iconColor),
              const SizedBox(width: 4),
              Text('导航', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _iconColor)),
            ],
          ),
        ),
      ),
    );
  }
}
