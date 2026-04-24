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
import 'map_marker_bytes.dart';
import 'google_map_layer.dart';

final _mapTimeFmt = DateFormat('HH:mm');

/// Renders a schedule marker: rounded-rect badge with "D{N}" + time/name text beside it.
/// Renders a coral pill marker: "D{N} · name" + stem + dot below.
Future<BitmapDescriptor> _buildScheduleMarkerBitmap({
  required Color color,
  required String dayLabel,
  required String time,
  required String name,
}) async {
  final bytes = await buildScheduleMarkerBytes(
      color: color, dayLabel: dayLabel, time: time, name: name);
  return BitmapDescriptor.fromBytes(bytes);
}

/// Renders a coral circle marker with white number label.
Future<BitmapDescriptor> _buildMarkerBitmap({
  required Color color,
  required String label,
  double size = 72,
}) async {
  final bytes = await buildCircleMarkerBytes(color: color, label: label, size: size);
  return BitmapDescriptor.fromBytes(bytes);
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
        color: AppColors.primary,
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 68, AppSpacing.pageHorizontal,
          12 + MediaQuery.of(context).padding.bottom),
      child: Stack(
        children: [
          // ── Map container with rounded corners
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x0F1C1C1E)),
                ),
                child: _buildMapLayer(
                  mapState: mapState,
                  scheduleMarkers: scheduleMarkers,
                  poiMarkers: poiMarkers,
                  polylines: polylines,
                  isAbroad: travel?.isAbroad ?? false,
                  validSchedules: validSchedules,
                  travel: travel,
                ),
              ),
            ),
          ),

          // ── Top floating UI (Search bar in search mode only)
          if (mapState.mode == MapMode.search)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
            child: MapSearchBar(
              cities: travel?.cities ?? [],
              selectedCity: mapState.searchCity,
              controller: _searchCtrl,
              onCityChanged: (city) => ref
                  .read(mapStateProvider(widget.travelId).notifier)
                  .setSearchCity(city),
              onSearch: (keyword) => ref
                  .read(mapStateProvider(widget.travelId).notifier)
                  .searchPoi(keyword, isAbroad: travel?.isAbroad ?? false),
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
                initialChildSize: 0.40,
                minChildSize: 0.12,
                maxChildSize: 0.70,
                snap: true,
                snapSizes: const [0.12, 0.40, 0.70],
                builder: (context, scrollController) => Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xE6FFFFFF), // rgba(255,255,255,0.90)
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, -4)),
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
              bottom: 12,
              left: 12,
              right: 68,
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
                        isAbroad: travel?.isAbroad ?? false,
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

          // ── Search FAB (day mode)
          if (mapState.mode == MapMode.day)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => ref
                    .read(mapStateProvider(widget.travelId).notifier)
                    .enterSearchMode(),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coralGlow,
                        blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.search, size: 22, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapLayer({
    required MapState mapState,
    required Set<Marker> scheduleMarkers,
    required Set<Marker> poiMarkers,
    required Set<Polyline> polylines,
    required bool isAbroad,
    required List<Schedule> validSchedules,
    required Travel? travel,
  }) {
    if (isAbroad) {
      return GoogleMapLayer(
        validSchedules: validSchedules,
        poiResults: mapState.poiResults,
        selectedPoiId: mapState.selectedPoiId,
        selectedScheduleId: mapState.selectedScheduleId,
        mode: mapState.mode,
        travelStart: travel?.startDate,
        onScheduleTap: (id) =>
            ref.read(mapStateProvider(widget.travelId).notifier).selectMarker(id),
        onPoiTap: (id) =>
            ref.read(mapStateProvider(widget.travelId).notifier).selectPoi(id),
        onMapTap: () {
          final notifier = ref.read(mapStateProvider(widget.travelId).notifier);
          if (mapState.mode == MapMode.search && _searchCtrl.text.trim().isEmpty) {
            notifier.exitSearchMode();
          } else {
            notifier.clearMarker();
          }
        },
      );
    }
    if (!_platformChecked) {
      return const ColoredBox(color: AppColors.warmCanvas, child: SizedBox.expand());
    }
    if (_isSimulator) {
      return Container(
        color: const Color(0xFFE8E4DF),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 48, color: AppColors.inkTertiary),
              const SizedBox(height: 8),
              Text('地图在模拟器上不可用',
                  style: TextStyle(color: AppColors.inkSecondary, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    return AMapWidget(
      privacyStatement: const AMapPrivacyStatement(
        hasContains: true, hasShow: true, hasAgree: true,
      ),
      labelsEnabled: false,
      onMapCreated: (ctrl) {
        _mapController = ctrl;
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _fitToCurrentDaySchedules());
      },
      markers: mapState.mode == MapMode.day ? scheduleMarkers : poiMarkers,
      polylines: mapState.mode == MapMode.day ? polylines : {},
      onTap: (_) {
        final notifier = ref.read(mapStateProvider(widget.travelId).notifier);
        if (mapState.mode == MapMode.search && _searchCtrl.text.trim().isEmpty) {
          notifier.exitSearchMode();
        } else {
          notifier.clearMarker();
        }
      },
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
      itemCount: mapState.poiResults.length + 1, // header + items
      separatorBuilder: (_, index) => index < 1
          ? const SizedBox.shrink()
          : Divider(height: 1, color: const Color(0x0A1C1C1E),
                indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        // Header: drag handle + result count
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '找到 ${mapState.poiResults.length} 个结果',
                  style: const TextStyle(fontSize: 12, color: AppColors.inkTertiary),
                ),
              ),
            ],
          );
        }
        final poi = mapState.poiResults[index - 1];
        final poiIndex = index - 1;
        final selected = poi.id == mapState.selectedPoiId;
        return GestureDetector(
          onTap: () => ref
              .read(mapStateProvider(widget.travelId).notifier)
              .selectPoi(poi.id),
          child: Container(
            color: selected ? AppColors.coralTint : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Number circle (left)
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${poiIndex + 1}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poi.name,
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkPrimary),
                          overflow: TextOverflow.ellipsis),
                      if (poi.address.isNotEmpty)
                        Text(poi.address,
                            style: const TextStyle(fontSize: 12,
                                color: AppColors.inkTertiary),
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Add button (right)
                GestureDetector(
                  onTap: () async {
                    try {
                      await ref
                          .read(mapStateProvider(widget.travelId).notifier)
                          .quickAddSchedule(poi,
                            selectedDay: ref.read(selectedDayProvider(widget.travelId)),
                            travelStartDate: travel?.startDate,
                          );
                      if (context.mounted) {
                        final day = ref.read(selectedDayProvider(widget.travelId));
                        final msg = day > 0 ? '已加入第 $day 天' : '已加入待规划';
                        _showToast(context, msg);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        _showToast(context, '添加失败', isError: true);
                      }
                    }
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.coralTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x1FFF6B3D)),
                    ),
                    child: const Icon(Icons.add, size: 18,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showToast(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(builder: (ctx) => _Toast(
      message: message,
      isError: isError,
      onDismiss: () => entry.remove(),
    ));
    overlay.insert(entry);
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 6),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0x1F1C1C1E), // rgba(28,28,30,0.12)
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Toast overlay (design spec: dark pill, slide down + fade in, auto dismiss)

class _Toast extends StatefulWidget {
  const _Toast({required this.message, this.isError = false, required this.onDismiss});
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    final curve = CurvedAnimation(parent: _ctrl, curve: const Cubic(0.34, 1.3, 0.64, 1.0));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(curve);
    _slide = Tween(begin: const Offset(0, -0.3), end: Offset.zero).animate(curve);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0, right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkPill,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isError ? Icons.error_outline : Icons.check_circle,
                    size: 18,
                    color: widget.isError ? AppColors.destructive : AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.message, style: const TextStyle(
                      fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Day chip row for map mode (horizontal, scrollable, with indicators) ─────

class _DayChipRow extends StatefulWidget {
  const _DayChipRow({
    required this.travelId,
    required this.totalDays,
    required this.selectedDay,
    required this.onDayTap,
  });
  final int travelId;
  final int totalDays;
  final int selectedDay;
  final ValueChanged<int> onDayTap;

  @override
  State<_DayChipRow> createState() => _DayChipRowState();
}

class _DayChipRowState extends State<_DayChipRow> {
  final _scrollCtrl = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  static const _itemWidth = 72.0;

  List<int> get _days => [for (int d = 1; d <= widget.totalDays; d++) d, 0];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_updateIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicators();
      _scrollToActive();
    });
  }

  @override
  void didUpdateWidget(covariant _DayChipRow old) {
    super.didUpdateWidget(old);
    if (old.selectedDay != widget.selectedDay) {
      _scrollToActive();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicators());
  }

  void _updateIndicators() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final l = pos.pixels > 0;
    final r = pos.pixels < pos.maxScrollExtent - 1;
    if (l != _canScrollLeft || r != _canScrollRight) {
      setState(() { _canScrollLeft = l; _canScrollRight = r; });
    }
  }

  void _scrollToActive() {
    if (!_scrollCtrl.hasClients) return;
    final idx = _days.indexOf(widget.selectedDay);
    if (idx < 0) return;
    final viewW = _scrollCtrl.position.viewportDimension;
    final target = (idx * _itemWidth) - (viewW / 2) + (_itemWidth / 2);
    _scrollCtrl.animateTo(
      target.clamp(0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (context, i) {
              final d = days[i];
              final active = d == widget.selectedDay || (d == 0 && widget.selectedDay == -1);
              return GestureDetector(
                onTap: () => widget.onDayTap(d == 0 ? -1 : d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : const Color(0xB3FFFFFF),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: active ? Colors.transparent : const Color(0x33000000),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    d == 0 ? '待规划' : 'Day $d',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.white : AppColors.inkSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
          // Left indicator
          if (_canScrollLeft)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: GestureDetector(
                onTap: () => _scrollCtrl.animateTo(
                  (_scrollCtrl.offset - 100).clamp(0, _scrollCtrl.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
                ),
                child: Container(
                  width: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      size: 20, color: AppColors.inkPrimary),
                ),
              ),
            ),
          // Right indicator
          if (_canScrollRight)
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: GestureDetector(
                onTap: () => _scrollCtrl.animateTo(
                  (_scrollCtrl.offset + 100).clamp(0, _scrollCtrl.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
                ),
                child: Container(
                  width: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [Color(0x00FFFFFF), Color(0xCCFFFFFF)],
                    ),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.inkPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
