// lib/features/travel/presentation/map/google_map_layer.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../shared/models/schedule.dart';
import 'map_marker_bytes.dart';
import 'map_state_notifier.dart';

class GoogleMapLayer extends StatefulWidget {
  const GoogleMapLayer({
    super.key,
    required this.validSchedules,
    required this.poiResults,
    required this.selectedPoiId,
    required this.selectedScheduleId,
    required this.mode,
    required this.travelStart,
    required this.onScheduleTap,
    required this.onPoiTap,
    required this.onMapTap,
  });

  final List<Schedule> validSchedules;
  final List<AmapPoi> poiResults;
  final String? selectedPoiId;
  final int? selectedScheduleId;
  final MapMode mode;
  final DateTime? travelStart;
  final void Function(int id) onScheduleTap;
  final void Function(String id) onPoiTap;
  final VoidCallback onMapTap;

  @override
  State<GoogleMapLayer> createState() => _GoogleMapLayerState();
}

class _GoogleMapLayerState extends State<GoogleMapLayer> {
  gm.GoogleMapController? _ctrl;
  Map<gm.MarkerId, gm.Marker> _scheduleMarkers = {};
  Map<gm.MarkerId, gm.Marker> _poiMarkers = {};
  final Map<String, gm.BitmapDescriptor> _iconCache = {};

  static final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _rebuildMarkers();
  }

  @override
  void didUpdateWidget(covariant GoogleMapLayer old) {
    super.didUpdateWidget(old);
    final schedulesChanged = widget.validSchedules != old.validSchedules ||
        widget.travelStart != old.travelStart;
    final poisChanged = widget.poiResults != old.poiResults ||
        widget.selectedPoiId != old.selectedPoiId;

    if (schedulesChanged || poisChanged ||
        widget.mode != old.mode ||
        widget.selectedScheduleId != old.selectedScheduleId) {
      _rebuildMarkers();
    }
    if (poisChanged && widget.poiResults.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToPois());
    } else if (schedulesChanged && widget.validSchedules.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToSchedules());
    }
    if (widget.selectedPoiId != old.selectedPoiId && widget.selectedPoiId != null) {
      final poi = widget.poiResults.where((p) => p.id == widget.selectedPoiId).firstOrNull;
      if (poi != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            _ctrl?.animateCamera(gm.CameraUpdate.newLatLng(gm.LatLng(poi.latitude, poi.longitude))));
      }
    }
  }

  Future<void> _rebuildMarkers() async {
    await Future.wait([_buildScheduleMarkers(), _buildPoiMarkers()]);
    if (mounted) setState(() {});
  }

  Future<void> _buildScheduleMarkers() async {
    final Map<gm.MarkerId, gm.Marker> markers = {};
    for (final s in widget.validSchedules) {
      final parts = s.coordinate.split(',');
      if (parts.length != 2) continue;
      final lng = double.tryParse(parts[0]);
      final lat = double.tryParse(parts[1]);
      if (lng == null || lat == null) continue;

      int dayNum = 0;
      if (s.startTime != null && widget.travelStart != null) {
        dayNum = s.startTime!.toLocal().difference(widget.travelStart!).inDays + 1;
      }
      final dayLabel = dayNum > 0 ? 'D$dayNum' : '?';
      Color color;
      String timeLabel;
      if (s.isHotel) {
        color = AppColors.hotel;
        timeLabel = s.startTime != null ? _timeFmt.format(s.startTime!.toLocal()) : '';
      } else if (s.startTime != null) {
        color = AppColors.primary;
        timeLabel = _timeFmt.format(s.startTime!.toLocal());
      } else {
        color = AppColors.textSecondary;
        timeLabel = '';
      }

      final cacheKey = '${s.id}_${dayLabel}_${timeLabel}_${s.name}';
      if (!_iconCache.containsKey(cacheKey)) {
        final bytes = await buildScheduleMarkerBytes(
            color: color, dayLabel: dayLabel, time: timeLabel, name: s.name);
        _iconCache[cacheKey] = gm.BitmapDescriptor.fromBytes(bytes);
      }

      final id = gm.MarkerId('schedule_${s.id}');
      markers[id] = gm.Marker(
        markerId: id,
        position: gm.LatLng(lat, lng),
        icon: _iconCache[cacheKey]!,
        onTap: () => widget.onScheduleTap(s.id!),
      );
    }
    _scheduleMarkers = markers;
  }

  Future<void> _buildPoiMarkers() async {
    final Map<gm.MarkerId, gm.Marker> markers = {};
    for (int i = 0; i < widget.poiResults.length; i++) {
      final poi = widget.poiResults[i];
      final cacheKey = 'poi_${i + 1}';
      if (!_iconCache.containsKey(cacheKey)) {
        final bytes = await buildCircleMarkerBytes(color: AppColors.primary, label: '${i + 1}');
        _iconCache[cacheKey] = gm.BitmapDescriptor.fromBytes(bytes);
      }
      final id = gm.MarkerId('poi_${poi.id}');
      markers[id] = gm.Marker(
        markerId: id,
        position: gm.LatLng(poi.latitude, poi.longitude),
        icon: _iconCache[cacheKey]!,
        onTap: () => widget.onPoiTap(poi.id),
      );
    }
    _poiMarkers = markers;
  }

  void _fitToSchedules() {
    final ctrl = _ctrl;
    if (ctrl == null || widget.validSchedules.isEmpty) return;
    final points = widget.validSchedules
        .map((s) {
          final p = s.coordinate.split(',');
          final lng = double.tryParse(p[0]);
          final lat = double.tryParse(p[1]);
          if (lng == null || lat == null) return null;
          return gm.LatLng(lat, lng);
        })
        .whereType<gm.LatLng>()
        .toList();
    _fitToGmPoints(ctrl, points);
  }

  void _fitToPois() {
    final ctrl = _ctrl;
    if (ctrl == null || widget.poiResults.isEmpty) return;
    final points = widget.poiResults
        .map((p) => gm.LatLng(p.latitude, p.longitude))
        .toList();
    _fitToGmPoints(ctrl, points);
  }

  static void _fitToGmPoints(gm.GoogleMapController ctrl, List<gm.LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      ctrl.animateCamera(gm.CameraUpdate.newLatLngZoom(points.first, 14));
      return;
    }
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    ctrl.animateCamera(gm.CameraUpdate.newLatLngBounds(
      gm.LatLngBounds(
        southwest: gm.LatLng(minLat, minLng),
        northeast: gm.LatLng(maxLat, maxLng),
      ),
      60,
    ));
  }

  Set<gm.Marker> get _activeMarkers => widget.mode == MapMode.day
      ? _scheduleMarkers.values.toSet()
      : _poiMarkers.values.toSet();

  Set<gm.Polyline> get _polylines {
    if (widget.mode != MapMode.day || widget.validSchedules.length < 2) return {};
    final points = widget.validSchedules
        .map((s) {
          final p = s.coordinate.split(',');
          final lng = double.tryParse(p[0]);
          final lat = double.tryParse(p[1]);
          if (lng == null || lat == null) return null;
          return gm.LatLng(lat, lng);
        })
        .whereType<gm.LatLng>()
        .toList();
    return {
      gm.Polyline(
        polylineId: const gm.PolylineId('route'),
        points: points,
        color: AppColors.primary,
        width: 2,
        patterns: [gm.PatternItem.dot, gm.PatternItem.gap(10)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return gm.GoogleMap(
      initialCameraPosition: const gm.CameraPosition(
        target: gm.LatLng(48.8566, 2.3522),
        zoom: 4,
      ),
      mapType: gm.MapType.normal,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: _activeMarkers,
      polylines: _polylines,
      onMapCreated: (ctrl) {
        _ctrl = ctrl;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.validSchedules.isNotEmpty) _fitToSchedules();
        });
      },
      onTap: (_) => widget.onMapTap(),
    );
  }
}
