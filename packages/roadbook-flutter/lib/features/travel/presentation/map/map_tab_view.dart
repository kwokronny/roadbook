// lib/features/travel/presentation/map/map_tab_view.dart
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../shared/utils/schedule_day_helper.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';
import '../../../../features/travel/domain/travel_detail_provider.dart';
import '../../../../features/schedule/presentation/schedule_edit_sheet.dart';
import 'map_state_notifier.dart';
import 'map_day_selector.dart';
import 'map_search_bar.dart';
import 'map_info_bar.dart';

/// Renders a rounded-rect marker icon to BitmapDescriptor via Canvas.
Future<BitmapDescriptor> _buildMarkerBitmap({
  required Color color,
  required String label,
  double size = 36,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final paint = ui.Paint()..color = color;
  final rrect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(2, 2, size - 4, size - 4),
    const ui.Radius.circular(8),
  );
  canvas.drawRRect(rrect, paint);

  final borderPaint = ui.Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2;
  canvas.drawRRect(rrect, borderPaint);

  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.center),
  )
    ..pushStyle(ui.TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: label.length == 1 ? 14 : 11,
      fontWeight: ui.FontWeight.w800,
    ))
    ..addText(label);
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size));
  canvas.drawParagraph(
    paragraph,
    Offset(0, (size - paragraph.height) / 2),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

class MapTabView extends ConsumerStatefulWidget {
  const MapTabView({super.key, required this.travelId});
  final int travelId;

  @override
  ConsumerState<MapTabView> createState() => _MapTabViewState();
}

class _MapTabViewState extends ConsumerState<MapTabView> {
  // ignore: unused_field
  AMapController? _mapController;
  final Map<String, BitmapDescriptor> _iconCache = {};
  bool _iconsReady = false;

  @override
  void initState() {
    super.initState();
    _preloadIcons();
  }

  Future<void> _preloadIcons() async {
    for (int i = 1; i <= 10; i++) {
      _iconCache['day_$i'] = await _buildMarkerBitmap(
        color: AppColors.primary,
        label: '$i',
      );
      _iconCache['poi_$i'] = await _buildMarkerBitmap(
        color: AppColors.textSecondary,
        label: '$i',
      );
    }
    _iconCache['hotel'] = await _buildMarkerBitmap(
      color: AppColors.hotel,
      label: '🏨',
    );
    if (mounted) setState(() => _iconsReady = true);
  }

  BitmapDescriptor _icon(String key) =>
      _iconCache[key] ?? BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateProvider(widget.travelId));
    final schedulesAsync = ref.watch(scheduleProvider(widget.travelId));
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final selectedDay = ref.watch(selectedDayProvider(widget.travelId));

    final travel = travelAsync.valueOrNull;
    final schedules = schedulesAsync.valueOrNull ?? [];

    final daySchedules = travel != null
        ? schedulesForDay(selectedDay, schedules, travel.startDate)
        : <Schedule>[];

    final validSchedules = daySchedules
        .where((s) => s.coordinate.isNotEmpty && s.coordinate != '0,0')
        .toList();

    // ── Day mode markers
    final Set<Marker> scheduleMarkers = {};
    for (int i = 0; i < validSchedules.length; i++) {
      final s = validSchedules[i];
      final parts = s.coordinate.split(',');
      if (parts.length != 2) continue;
      final iconKey = s.isHotel ? 'hotel' : 'day_${i + 1}';
      scheduleMarkers.add(Marker(
        position: LatLng(double.parse(parts[1]), double.parse(parts[0])),
        icon: _iconsReady ? _icon(iconKey) : BitmapDescriptor.defaultMarker,
        onTap: (_) {
          ref
              .read(mapStateProvider(widget.travelId).notifier)
              .selectMarker(s.id!);
        },
      ));
    }

    // ── Polyline (path between day stops)
    final Set<Polyline> polylines = {};
    if (validSchedules.length > 1) {
      final points = validSchedules.map((s) {
        final p = s.coordinate.split(',');
        return LatLng(double.parse(p[1]), double.parse(p[0]));
      }).toList();
      polylines.add(Polyline(
        points: points,
        color: AppColors.primary,
        width: 2,
        dashLineType: DashLineType.square,
      ));
    }

    // ── Search mode POI markers
    final Set<Marker> poiMarkers = {};
    if (mapState.mode == MapMode.search) {
      for (int i = 0; i < mapState.poiResults.length; i++) {
        final poi = mapState.poiResults[i];
        final selected = poi.id == mapState.selectedPoiId;
        final iconKey = selected ? 'day_${i + 1}' : 'poi_${i + 1}';
        poiMarkers.add(Marker(
          position: LatLng(poi.latitude, poi.longitude),
          icon: _iconsReady ? _icon(iconKey) : BitmapDescriptor.defaultMarker,
          onTap: (_) {
            ref
                .read(mapStateProvider(widget.travelId).notifier)
                .selectPoi(poi.id);
          },
        ));
      }
    }

    final Schedule? selectedSchedule = mapState.selectedScheduleId != null
        ? schedules
            .where((s) => s.id == mapState.selectedScheduleId)
            .firstOrNull
        : null;

    final AmapPoi? selectedPoi = mapState.selectedPoiId != null
        ? mapState.poiResults
            .where((p) => p.id == mapState.selectedPoiId)
            .firstOrNull
        : null;

    final bool showInfoBar = selectedSchedule != null || selectedPoi != null;

    return Stack(
      children: [
        // ── Base map layer
        AMapWidget(
          privacyStatement: const AMapPrivacyStatement(
            hasContains: true,
            hasShow: true,
            hasAgree: true,
          ),
          onMapCreated: (ctrl) => _mapController = ctrl,
          markers: mapState.mode == MapMode.day ? scheduleMarkers : poiMarkers,
          polylines: mapState.mode == MapMode.day ? polylines : {},
          onTap: (_) {
            ref
                .read(mapStateProvider(widget.travelId).notifier)
                .clearMarker();
          },
        ),

        // ── Top floating UI (Day selector OR Search bar)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: mapState.mode == MapMode.day
              ? MapDaySelectorBar(
                  travelId: widget.travelId,
                  totalDays: travel != null
                      ? travel.endDate
                              .difference(travel.startDate)
                              .inDays +
                          1
                      : 1,
                  onSearchTap: () => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .enterSearchMode(),
                )
              : MapSearchBar(
                  cities: travel?.cities ?? [],
                  selectedCity: mapState.searchCity,
                  onCityChanged: (city) => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .setSearchCity(city),
                  onSearch: (keyword) => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .searchPoi(keyword),
                  onClose: () => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .exitSearchMode(),
                ),
        ),

        // ── Bottom info bar (AnimatedSlide)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            offset: showInfoBar ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: showInfoBar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: showInfoBar
                  ? (selectedSchedule != null
                      ? MapInfoBar.schedule(
                          schedule: selectedSchedule,
                          onTap: () {
                            if (travel != null) {
                              ScheduleEditSheet.show(
                                context,
                                travel: travel,
                                schedule: selectedSchedule,
                              );
                            }
                          },
                        )
                      : MapInfoBar.poi(
                          poi: selectedPoi!,
                          isAdding: false,
                          onAdd: () async {
                            try {
                              await ref
                                  .read(mapStateProvider(widget.travelId)
                                      .notifier)
                                  .quickAddSchedule(selectedPoi);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('已加入待规划')),
                                );
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('添加失败，请重试')),
                                );
                              }
                            }
                          },
                        ))
                  : const SizedBox.shrink(),
            ),
          ),
        ),

        // ── Search-in-progress indicator
        if (mapState.isSearching)
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('搜索中...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
