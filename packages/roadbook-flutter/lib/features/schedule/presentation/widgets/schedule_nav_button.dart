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
    if (parts.length < 2) return false;
    return true;
  }

  Color get _bgColor => isHotel ? AppColors.hotelLight : AppColors.primaryLight;
  Color get _borderColor => isHotel ? AppColors.hotelBorder : AppColors.primaryBorder;
  Color get _iconColor => isHotel ? AppColors.hotel : AppColors.primary;

  String _buildUrl(String mapMode) {
    final parts = coordinate.split(',');
    final lon = parts[0];
    final lat = parts[1];
    final encodedName = Uri.encodeComponent(name);
    final t = {'car': 0, 'taxi': 0, 'bus': 1, 'walk': 2, 'ride': 3}[mapMode] ?? 0;

    if (Platform.isIOS) {
      return 'iosamap://path?sourceApplication=roadbook'
          '&dlat=$lat&dlon=$lon&dname=$encodedName&dev=0&t=$t';
    } else {
      return 'amapuri://route/plan/'
          '?dlat=$lat&dlon=$lon&dname=$encodedName&dev=0&t=$t';
    }
  }

  Future<void> _launch(String mapMode) async {
    final urlStr = _buildUrl(mapMode);
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showModeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('导航至 $name', style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text('选择出行方式', style: AppTextStyles.caption),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ModeCell(icon: '🚗', label: '驾车', onTap: () { Navigator.pop(context); _launch('car'); }),
                  _ModeCell(icon: '🚕', label: '打车', onTap: () { Navigator.pop(context); _launch('taxi'); }),
                  _ModeCell(icon: '🚌', label: '公交', onTap: () { Navigator.pop(context); _launch('bus'); }),
                  _ModeCell(icon: '🚶', label: '步行', onTap: () { Navigator.pop(context); _launch('walk'); }),
                  _ModeCell(icon: '🚲', label: '骑行', onTap: () { Navigator.pop(context); _launch('ride'); }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isEnabled ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: _isEnabled ? () => _showModeSheet(context) : null,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Center(
            child: Icon(Icons.navigation_rounded, size: 14, color: _iconColor),
          ),
        ),
      ),
    );
  }
}

class _ModeCell extends StatelessWidget {
  const _ModeCell({required this.icon, required this.label, required this.onTap});
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
