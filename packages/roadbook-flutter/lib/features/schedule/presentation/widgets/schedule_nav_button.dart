// lib/features/schedule/presentation/widgets/schedule_nav_button.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme.dart';

import '../../../../shared/widgets/glass_popover.dart';
import 'package:hugeicons/hugeicons.dart';

class ScheduleNavButton extends StatelessWidget {
  const ScheduleNavButton({
    super.key,
    required this.coordinate,
    required this.name,
    required this.isHotel,
    this.isAbroad = false,
    this.compact = false,
  });

  final String coordinate;
  final String name;
  final bool isHotel;
  final bool isAbroad;
  final bool compact;

  bool get _isEnabled {
    if (coordinate.isEmpty) return false;
    if (coordinate == '0,0') return false;
    final parts = coordinate.split(',');
    return parts.length >= 2;
  }

  Color get _textColor => isHotel ? AppColors.lavender : AppColors.primary;

  // ── Coordinate helpers ─────────────────────────────────────────────────────
  // Stored as "longitude,latitude"
  String get _lng => coordinate.split(',')[0];
  String get _lat => coordinate.split(',')[1];

  // ── Domestic: AMap + DiDi ──────────────────────────────────────────────────

  String _buildAmapUrl(String mapMode) {
    final encodedName = Uri.encodeComponent(name);
    final t = {'car': 0, 'bus': 1, 'walk': 2, 'ride': 3}[mapMode] ?? 0;
    if (Platform.isIOS) {
      return 'iosamap://path?sourceApplication=roadbook'
          '&dlat=$_lat&dlon=$_lng&dname=$encodedName&dev=0&t=$t';
    } else {
      return 'amapuri://route/plan/'
          '?dlat=$_lat&dlon=$_lng&dname=$encodedName&dev=0&t=$t';
    }
  }

  String _buildDidiUrl() {
    final encodedName = Uri.encodeComponent(name);
    return 'diditaxi://taxi?'
        'dlat=$_lat&dlng=$_lng&dname=$encodedName&maptype=gaode';
  }

  // ── Overseas: Apple Maps (iOS) + Google Maps ───────────────────────────────

  String _buildAppleMapsUrl(String dirflg) {
    // dirflg: d=drive, r=transit, w=walk
    return 'maps://?daddr=$_lat,$_lng&dirflg=$dirflg';
  }

  /// Google Maps app → falls back to web if not installed.
  Future<void> _launchGoogleMaps(String mode) async {
    // mode: driving | transit | walking
    final appUri = Uri.parse(Platform.isIOS
        ? 'comgooglemaps://?daddr=$_lat,$_lng&directionsmode=$mode'
        : 'google.navigation:q=$_lat,$_lng&mode=${mode[0]}');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$_lat,$_lng&travelmode=$mode');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Launch dispatch ────────────────────────────────────────────────────────

  Future<void> _launch(String mode) async {
    if (isAbroad) {
      if (mode.startsWith('apple_')) {
        final dirflg = mode.split('_')[1]; // apple_d → d
        final uri = Uri.parse(_buildAppleMapsUrl(dirflg));
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        await _launchGoogleMaps(mode);
      }
    } else {
      final url =
          mode == 'didi' ? _buildDidiUrl() : _buildAmapUrl(mode);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // ── Mode lists ─────────────────────────────────────────────────────────────

  static const _domesticModes = [
    {'mode': 'car',  'emoji': '🚗', 'label': '驾车'},
    {'mode': 'didi', 'emoji': '🚕', 'label': '滴滴打车'},
    {'mode': 'bus',  'emoji': '🚌', 'label': '公交'},
    {'mode': 'walk', 'emoji': '🚶', 'label': '步行'},
    {'mode': 'ride', 'emoji': '🚲', 'label': '骑行'},
  ];

  static final _abroadModes = Platform.isIOS
      ? [
          {'mode': 'apple_d', 'emoji': '🚗', 'label': 'Apple Maps 驾车'},
          {'mode': 'apple_r', 'emoji': '🚇', 'label': 'Apple Maps 公交'},
          {'mode': 'apple_w', 'emoji': '🚶', 'label': 'Apple Maps 步行'},
          {'mode': 'driving', 'emoji': '🗺️', 'label': 'Google Maps'},
        ]
      : [
          {'mode': 'driving', 'emoji': '🚗', 'label': 'Google Maps 驾车'},
          {'mode': 'transit', 'emoji': '🚇', 'label': 'Google Maps 公交'},
          {'mode': 'walking', 'emoji': '🚶', 'label': 'Google Maps 步行'},
        ];

  List<Map<String, String>> get _modes =>
      isAbroad ? _abroadModes : _domesticModes;

  // ── Popover ────────────────────────────────────────────────────────────────

  void _showNavPopover(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset buttonPos =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    showGlassPopover(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPos.dx,
        buttonPos.dy + button.size.height + 4,
        overlay.size.width - buttonPos.dx - button.size.width,
        0,
      ),
      width: button.size.width,
      items: _modes
          .map((m) => PopoverItem(
                emoji: m['emoji'],
                label: m['label']!,
                onTap: () => _launch(m['mode']!),
              ))
          .toList(),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Opacity(
        opacity: _isEnabled ? 1.0 : 0.38,
        child: GestureDetector(
          onTap: _isEnabled ? () => _showNavPopover(context) : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(HugeIcons.strokeRoundedNavigation01,
                size: 16, color: Colors.white),
          ),
        ),
      );
    }

    return Opacity(
      opacity: _isEnabled ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: _isEnabled ? () => _showNavPopover(context) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x85FFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border:
                    Border.all(color: const Color(0xA6FFFFFF), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HugeIcons.strokeRoundedNavigation01,
                      size: 12, color: _textColor),
                  const SizedBox(width: 5),
                  Text(
                    '导航前往',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
