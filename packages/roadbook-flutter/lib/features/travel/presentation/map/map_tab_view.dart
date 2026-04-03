// lib/features/travel/presentation/map/map_tab_view.dart
import 'dart:async';
import 'dart:math' show min, max;
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/utils/schedule_day_helper.dart';
import '../../../../shared/utils/platform_util.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';
import '../../../../features/travel/domain/travel_detail_provider.dart';
import '../../../../features/schedule/presentation/schedule_edit_sheet.dart';
import '../../../../features/schedule/presentation/schedule_quick_time_sheet.dart';
import 'map_state_notifier.dart';
import 'map_day_selector.dart';
import 'map_search_bar.dart';
import 'map_info_bar.dart';

final _mapTimeFmt = DateFormat('HH:mm');

/// Renders a schedule marker: rounded-rect badge with "D{N}" + time/name text beside it.
Future<BitmapDescriptor> _buildScheduleMarkerBitmap({
  required Color color,
  required String dayLabel,
  required String time,
  required String name,
}) async {
  const double badgeSize = 80;
  const double badgeRadius = 16;
  const double badgeFontSize = 36;
  const double textFontSize = 34;
  const double gap = 12;
  const double borderWidth = 4;
  const double maxTextWidth = 400;

  // ── Badge label "D1" etc
  final badgeTextBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.center, maxLines: 1),
  )
    ..pushStyle(ui.TextStyle(
      color: Colors.white,
      fontSize: badgeFontSize,
      fontWeight: ui.FontWeight.w800,
    ))
    ..addText(dayLabel);
  final badgePara = badgeTextBuilder.build()
    ..layout(const ui.ParagraphConstraints(width: badgeSize));

  // ── White-stroke shadows for side text
  const sw = 3.0;
  final strokeShadows = [
    for (final dx in [-sw, 0.0, sw])
      for (final dy in [-sw, 0.0, sw])
        if (dx != 0 || dy != 0)
          ui.Shadow(offset: Offset(dx, dy), blurRadius: sw, color: Colors.white),
  ];

  // ── Time text (line 1)
  final timePara = _buildSideParagraph(time, textFontSize, color, strokeShadows, maxTextWidth);
  // ── Name text (line 2), truncate
  final displayName = name.length > 6 ? '${name.substring(0, 6)}…' : name;
  final namePara = _buildSideParagraph(displayName, textFontSize, color, strokeShadows, maxTextWidth);

  final sideTextWidth = timePara.longestLine > namePara.longestLine
      ? timePara.longestLine
      : namePara.longestLine;
  final sideTextHeight = timePara.height + namePara.height;

  final totalW = badgeSize + gap + sideTextWidth + 8;
  final totalH = badgeSize > sideTextHeight ? badgeSize : sideTextHeight;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Draw badge background
  final badgeRect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(borderWidth, (totalH - badgeSize) / 2 + borderWidth,
        badgeSize - borderWidth * 2, badgeSize - borderWidth * 2),
    const ui.Radius.circular(badgeRadius),
  );
  canvas.drawRRect(badgeRect, ui.Paint()..color = color);
  canvas.drawRRect(
    badgeRect,
    ui.Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = borderWidth,
  );

  // Draw badge text
  canvas.drawParagraph(
    badgePara,
    Offset(0, (totalH - badgePara.height) / 2),
  );

  // Draw side text
  final sideX = badgeSize + gap;
  final sideY = (totalH - sideTextHeight) / 2;
  if (time.isNotEmpty) {
    canvas.drawParagraph(timePara, Offset(sideX, sideY));
  }
  canvas.drawParagraph(
    namePara,
    Offset(sideX, sideY + (time.isNotEmpty ? timePara.height : 0)),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(totalW.ceil(), totalH.ceil());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

ui.Paragraph _buildSideParagraph(
    String text, double size, Color color, List<ui.Shadow> shadows, double maxWidth) {
  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.left, maxLines: 1, ellipsis: '…'),
  )
    ..pushStyle(ui.TextStyle(
      color: color,
      fontSize: size,
      fontWeight: ui.FontWeight.w700,
      shadows: shadows,
    ))
    ..addText(text);
  return builder.build()..layout(ui.ParagraphConstraints(width: maxWidth));
}

/// Renders a rounded-rect marker icon (for POI search results).
Future<BitmapDescriptor> _buildMarkerBitmap({
  required Color color,
  required String label,
  double size = 104,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final paint = ui.Paint()..color = color;
  final rrect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(2, 2, size - 4, size - 4),
    const ui.Radius.circular(20),
  );
  canvas.drawRRect(rrect, paint);

  final borderPaint = ui.Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 5;
  canvas.drawRRect(rrect, borderPaint);

  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.center),
  )
    ..pushStyle(ui.TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: label.length == 1 ? 40 : 30,
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
  AMapController? _mapController;
  final Map<String, BitmapDescriptor> _iconCache = {};
  final Map<String, BitmapDescriptor> _scheduleIconCache = {};
  final TextEditingController _searchCtrl = TextEditingController();
  bool _iconsReady = false;
  bool _platformChecked = false;
  bool _isSimulator = false;
  int _lastScheduleHash = 0;

  @override
  void initState() {
    super.initState();
    _checkSimulator();
    _preloadIcons();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _fitToPoints(List<LatLng> points) {
    final ctrl = _mapController;
    if (ctrl == null || points.isEmpty) return;
    if (points.length == 1) {
      ctrl.moveCamera(CameraUpdate.newLatLngZoom(points.first, 14), animated: true);
      return;
    }
    final minLat = points.map((p) => p.latitude).reduce(min);
    final maxLat = points.map((p) => p.latitude).reduce(max);
    final minLng = points.map((p) => p.longitude).reduce(min);
    final maxLng = points.map((p) => p.longitude).reduce(max);
    ctrl.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
      animated: true,
    );
  }

  void _fitToCurrentDaySchedules() {
    final schedules = ref.read(scheduleProvider(widget.travelId)).valueOrNull ?? [];
    final travel = ref.read(travelDetailProvider(widget.travelId)).valueOrNull;
    if (travel == null) return;
    final selectedDay = ref.read(mapSelectedDayProvider(widget.travelId));
    final daySchedules = selectedDay == -1
        ? schedules
        : schedulesForDay(selectedDay, schedules, travel.startDate);
    final points = daySchedules
        .where((s) => s.coordinate.isNotEmpty && s.coordinate != '0,0')
        .map((s) {
          final p = s.coordinate.split(',');
          if (p.length != 2) return null;
          try {
            return LatLng(double.parse(p[1]), double.parse(p[0]));
          } catch (_) {
            return null;
          }
        })
        .whereType<LatLng>()
        .toList();
    _fitToPoints(points);
  }

  Future<void> _checkSimulator() async {
    final result = await PlatformUtil.isSimulator;
    if (mounted) {
      setState(() {
        _isSimulator = result;
        _platformChecked = true;
      });
    }
  }

  Future<void> _preloadIcons() async {
    for (int i = 1; i <= 10; i++) {
      _iconCache['day_large_$i'] = await _buildMarkerBitmap(
        color: AppColors.primary,
        label: '$i',
      );
      _iconCache['poi_$i'] = await _buildMarkerBitmap(
        color: AppColors.textSecondary,
        label: '$i',
      );
    }
    if (mounted) setState(() => _iconsReady = true);
  }

  /// Build schedule marker icons with day badge + time/name text.
  Future<void> _buildScheduleIcons(List<Schedule> schedules, {DateTime? travelStart}) async {
    for (final s in schedules) {
      if (s.coordinate.isEmpty || s.coordinate == '0,0') continue;

      String timeLabel;
      Color color;
      int dayNum = 0;
      if (s.startTime != null && travelStart != null) {
        dayNum = s.startTime!.toLocal().difference(travelStart).inDays + 1;
      }
      final dayLabel = dayNum > 0 ? 'D$dayNum' : '';

      if (s.isHotel) {
        color = AppColors.hotel;
        timeLabel = s.startTime != null ? _mapTimeFmt.format(s.startTime!.toLocal()) : '';
      } else if (s.startTime != null) {
        color = AppColors.primary;
        timeLabel = _mapTimeFmt.format(s.startTime!.toLocal());
      } else {
        color = AppColors.textSecondary;
        timeLabel = '';
      }

      final cacheKey = '${s.id}_${dayLabel}_${timeLabel}_${s.name}';
      if (!_scheduleIconCache.containsKey(cacheKey)) {
        _scheduleIconCache[cacheKey] = await _buildScheduleMarkerBitmap(
          color: color,
          dayLabel: dayLabel.isEmpty ? '?' : dayLabel,
          time: timeLabel,
          name: s.name,
        );
      }
    }
    if (mounted) setState(() {});
  }

  String _scheduleCacheKey(Schedule s, DateTime? travelStart) {
    int dayNum = 0;
    if (s.startTime != null && travelStart != null) {
      dayNum = s.startTime!.toLocal().difference(travelStart).inDays + 1;
    }
    final dayLabel = dayNum > 0 ? 'D$dayNum' : '';
    String timeLabel;
    if (s.isHotel) {
      timeLabel = s.startTime != null ? _mapTimeFmt.format(s.startTime!.toLocal()) : '';
    } else if (s.startTime != null) {
      timeLabel = _mapTimeFmt.format(s.startTime!.toLocal());
    } else {
      timeLabel = '';
    }
    return '${s.id}_${dayLabel}_${timeLabel}_${s.name}';
  }

  BitmapDescriptor _scheduleIcon(Schedule s, DateTime? travelStart) {
    final cacheKey = _scheduleCacheKey(s, travelStart);
    return _scheduleIconCache[cacheKey] ?? BitmapDescriptor.defaultMarker;
  }

  BitmapDescriptor _icon(String key) =>
      _iconCache[key] ?? BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateProvider(widget.travelId));
    final schedulesAsync = ref.watch(scheduleProvider(widget.travelId));
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final selectedDay = ref.watch(mapSelectedDayProvider(widget.travelId));

    // Fly to fit markers when day changes
    ref.listen<int>(mapSelectedDayProvider(widget.travelId), (prev, next) {
      if (prev != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitToCurrentDaySchedules());
      }
    });

    // Fly to fit POI markers when search results arrive; center on selected POI; fly back on exit
    ref.listen<MapState>(mapStateProvider(widget.travelId), (prev, next) {
      if (next.mode == MapMode.search &&
          next.poiResults.isNotEmpty &&
          prev?.poiResults != next.poiResults) {
        final points = next.poiResults
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitToPoints(points));
      }
      if (next.selectedPoiId != null && prev?.selectedPoiId != next.selectedPoiId) {
        final poi = next.poiResults
            .where((p) => p.id == next.selectedPoiId)
            .firstOrNull;
        if (poi != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              _mapController?.moveCamera(
                CameraUpdate.newLatLng(LatLng(poi.latitude, poi.longitude)),
                animated: true,
              ));
        }
      }
      if (prev?.mode == MapMode.search && next.mode == MapMode.day) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitToCurrentDaySchedules());
      }
    });

    final travel = travelAsync.valueOrNull;
    final schedules = schedulesAsync.valueOrNull ?? [];

    // Rebuild schedule icons when schedules change
    final scheduleHash = Object.hashAll(schedules.map((s) => '${s.id}_${s.startTime}_${s.name}_${s.isHotel}'));
    if (scheduleHash != _lastScheduleHash && schedules.isNotEmpty) {
      _lastScheduleHash = scheduleHash;
      _buildScheduleIcons(schedules, travelStart: travel?.startDate);
    }

    final daySchedules = travel != null
        ? (selectedDay == -1
            ? schedules
            : schedulesForDay(selectedDay, schedules, travel.startDate))
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
      scheduleMarkers.add(Marker(
        position: LatLng(double.parse(parts[1]), double.parse(parts[0])),
        icon: _scheduleIcon(s, travel?.startDate),
        onTap: (_) {
          ref
              .read(mapStateProvider(widget.travelId).notifier)
              .selectMarker(s.id!);
        },
      ));
    }

    // ── Polyline (path between day stops, skip in "all" mode)
    final Set<Polyline> polylines = {};
    if (selectedDay != -1 && validSchedules.length > 1) {
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
        final iconKey = selected ? 'day_large_${i + 1}' : 'poi_${i + 1}';
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

    return Stack(
      children: [
        // ── Base map layer
        if (!_platformChecked)
          const ColoredBox(
            color: Color(0xFFF5F5F5),
            child: SizedBox.expand(),
          )
        else if (_isSimulator)
          Container(
            color: const Color(0xFFE8E8E8),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: Color(0xFFAAAAAA)),
                  SizedBox(height: 8),
                  Text(
                    '地图在模拟器上不可用',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 18),
                  ),
                ],
              ),
            ),
          )
        else
          AMapWidget(
            privacyStatement: const AMapPrivacyStatement(
              hasContains: true,
              hasShow: true,
              hasAgree: true,
            ),
            labelsEnabled: false,
            onMapCreated: (ctrl) {
              _mapController = ctrl;
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _fitToCurrentDaySchedules(),
              );
            },
            markers: mapState.mode == MapMode.day ? scheduleMarkers : poiMarkers,
            polylines: mapState.mode == MapMode.day ? polylines : {},
            onTap: (_) {
              final notifier = ref.read(mapStateProvider(widget.travelId).notifier);
              if (mapState.mode == MapMode.search &&
                  _searchCtrl.text.trim().isEmpty) {
                notifier.exitSearchMode();
              } else {
                notifier.clearMarker();
              }
            },
          ),

        // ── Top floating UI (Day selector OR Search bar)
        if (mapState.mode == MapMode.day)
          Positioned(
            top: 12,
            right: 12,
            child: MapDaySelectorBar(
              travelId: widget.travelId,
              totalDays: travel != null
                  ? travel.endDate.difference(travel.startDate).inDays + 1
                  : 1,
              onSearchTap: () => ref
                  .read(mapStateProvider(widget.travelId).notifier)
                  .enterSearchMode(),
            ),
          )
        else
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapSearchBar(
              cities: travel?.cities ?? [],
              selectedCity: mapState.searchCity,
              controller: _searchCtrl,
              onCityChanged: (city) => ref
                  .read(mapStateProvider(widget.travelId).notifier)
                  .setSearchCity(city),
              onSearch: (keyword) => ref
                  .read(mapStateProvider(widget.travelId).notifier)
                  .searchPoi(keyword),
              onClose: () {
                _searchCtrl.clear();
                ref
                    .read(mapStateProvider(widget.travelId).notifier)
                    .exitSearchMode();
              },
            ),
          ),

        // ── Search results bottom panel (search mode)
        if (mapState.mode == MapMode.search &&
            (mapState.isSearching ||
                mapState.poiResults.isNotEmpty ||
                mapState.searchError != null))
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.1,
              maxChildSize: 0.75,
              snap: true,
              snapSizes: const [0.1, 0.35, 0.75],
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: _buildSearchResults(
                    context, mapState, travel, scrollController),
              ),
            ),
          ),

        // ── Bottom info bar (day mode only)
        if (mapState.mode == MapMode.day)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: selectedSchedule != null
                  ? Offset.zero
                  : const Offset(0, 1),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: selectedSchedule != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: selectedSchedule != null
                    ? MapInfoBar.schedule(
                        schedule: selectedSchedule,
                        onEditTimeTap: () {
                          if (travel != null) {
                            ScheduleQuickTimeSheet.show(
                              context,
                              travel: travel,
                              schedule: selectedSchedule,
                            );
                          }
                        },
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
                    : const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    MapState mapState,
    Travel? travel,
    ScrollController scrollController,
  ) {
    if (mapState.isSearching) {
      return Column(
        children: [
          _dragHandle(),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    if (mapState.searchError != null && mapState.poiResults.isEmpty) {
      return Column(
        children: [
          _dragHandle(),
          Expanded(
            child: Center(
              child: Text(
                mapState.searchError!,
                style: const TextStyle(
                    fontSize: 18, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: mapState.poiResults.length + 1,
      separatorBuilder: (_, index) => index == 0
          ? const SizedBox.shrink()
          : const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == 0) return _dragHandle();
        final poi = mapState.poiResults[index - 1];
        final poiIndex = index - 1;
        final selected = poi.id == mapState.selectedPoiId;
        return ListTile(
          dense: true,
          selected: selected,
          selectedTileColor: AppColors.primaryLight,
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(AppRadius.timeCell),
            ),
            alignment: Alignment.center,
            child: Text(
              '${poiIndex + 1}',
              style: AppTextStyles.cardTitle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            poi.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: poi.address.isNotEmpty
              ? Text(
                  poi.address,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: GestureDetector(
            onTap: () async {
              try {
                await ref
                    .read(mapStateProvider(widget.travelId).notifier)
                    .quickAddSchedule(poi);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已加入待规划')),
                  );
                }
              } catch (e, st) {
                debugPrint('=== quickAddSchedule error ===');
                debugPrint('type: ${e.runtimeType}');
                debugPrint('error: $e');
                if (e is DioException) {
                  debugPrint('dio.message: ${e.message}');
                  debugPrint('dio.response.statusCode: ${e.response?.statusCode}');
                  debugPrint('dio.response.data: ${e.response?.data}');
                }
                debugPrint('stackTrace: $st');
                if (context.mounted) {
                  String msg;
                  if (e is DioException) {
                    msg = e.message ?? e.response?.data?.toString() ?? '添加失败';
                  } else {
                    msg = e.toString();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      duration: const Duration(seconds: 6),
                    ),
                  );
                }
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Text(
                '+ 加入',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          onTap: () {
            ref
                .read(mapStateProvider(widget.travelId).notifier)
                .selectPoi(poi.id);
          },
        );
      },
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
