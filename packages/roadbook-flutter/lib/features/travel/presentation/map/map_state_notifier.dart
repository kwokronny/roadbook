// lib/features/travel/presentation/map/map_state_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';
import '../../../../features/schedule/data/schedule_repository.dart';

enum MapMode { day, search }

class MapState {
  const MapState({
    this.mode = MapMode.day,
    this.selectedScheduleId,
    this.searchCity = '全国',
    this.poiResults = const [],
    this.selectedPoiId,
    this.isSearching = false,
  });

  final MapMode mode;
  final int? selectedScheduleId;
  final String searchCity;
  final List<AmapPoi> poiResults;
  final String? selectedPoiId;
  final bool isSearching;

  MapState copyWith({
    MapMode? mode,
    Object? selectedScheduleId = _sentinel,
    String? searchCity,
    List<AmapPoi>? poiResults,
    Object? selectedPoiId = _sentinel,
    bool? isSearching,
  }) =>
      MapState(
        mode: mode ?? this.mode,
        selectedScheduleId: selectedScheduleId == _sentinel
            ? this.selectedScheduleId
            : selectedScheduleId as int?,
        searchCity: searchCity ?? this.searchCity,
        poiResults: poiResults ?? this.poiResults,
        selectedPoiId: selectedPoiId == _sentinel
            ? this.selectedPoiId
            : selectedPoiId as String?,
        isSearching: isSearching ?? this.isSearching,
      );
}

const _sentinel = Object();

// ─── Provider ─────────────────────────────────────────────────────────────────

final mapStateProvider = NotifierProvider.autoDispose
    .family<MapStateNotifier, MapState, int>(MapStateNotifier.new);

class MapStateNotifier extends AutoDisposeFamilyNotifier<MapState, int> {
  @override
  MapState build(int arg) => const MapState();

  void enterSearchMode() {
    state = state.copyWith(
      mode: MapMode.search,
      selectedScheduleId: null,
      poiResults: [],
    );
  }

  void exitSearchMode() {
    state = state.copyWith(
      mode: MapMode.day,
      poiResults: [],
      selectedPoiId: null,
      isSearching: false,
    );
  }

  void selectMarker(int scheduleId) {
    state = state.copyWith(selectedScheduleId: scheduleId);
  }

  void clearMarker() {
    state = state.copyWith(selectedScheduleId: null);
  }

  void selectPoi(String poiId) {
    state = state.copyWith(selectedPoiId: poiId);
  }

  void setSearchCity(String city) {
    state = state.copyWith(searchCity: city);
  }

  Future<void> searchPoi(String keyword) async {
    state = state.copyWith(isSearching: true, poiResults: []);
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get<Map<String, dynamic>>(
        '/_AMapService/v3/place/text',
        queryParameters: {
          'keywords': keyword,
          'city': state.searchCity,
          'output': 'json',
          'pageSize': '20',
        },
      );
      final data = resp.data ?? {};
      final pois = ((data['pois'] as List?) ?? [])
          .map((e) => AmapPoi.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isSearching: false, poiResults: pois);
    } catch (_) {
      state = state.copyWith(isSearching: false);
      rethrow;
    }
  }

  Future<void> quickAddSchedule(AmapPoi poi) async {
    final form = ScheduleFormData(
      tId: arg,
      name: poi.name,
      coordinate: '${poi.longitude},${poi.latitude}',
      address: poi.address,
      isHotel: false,
    );
    await ref.read(scheduleProvider(arg).notifier).add(form);
    exitSearchMode();
  }
}
