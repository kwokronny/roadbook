// lib/features/travel/presentation/map/map_state_notifier.dart
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../shared/utils/platform_util.dart';
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
    this.searchError,
  });

  final MapMode mode;
  final int? selectedScheduleId;
  final String searchCity;
  final List<AmapPoi> poiResults;
  final String? selectedPoiId;
  final bool isSearching;
  final String? searchError;

  MapState copyWith({
    MapMode? mode,
    Object? selectedScheduleId = _sentinel,
    String? searchCity,
    List<AmapPoi>? poiResults,
    Object? selectedPoiId = _sentinel,
    bool? isSearching,
    Object? searchError = _sentinel,
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
        searchError: searchError == _sentinel
            ? this.searchError
            : searchError as String?,
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

  static const _searchChannel = MethodChannel('com.roadbook/amap_search');

  static final _amapDio = Dio(BaseOptions(
    baseUrl: 'https://restapi.amap.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<void> searchPoi(String keyword) async {
    state = state.copyWith(isSearching: true, poiResults: [], searchError: null);
    try {
      final isSimulator = await PlatformUtil.isSimulator;
      final List<AmapPoi> pois;
      if (isSimulator) {
        pois = await _searchViaRestApi(keyword);
      } else {
        pois = await _searchViaNativeSdk(keyword);
      }
      state = state.copyWith(
        isSearching: false,
        poiResults: pois,
        searchError: pois.isEmpty ? '未找到相关结果' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        searchError: '搜索失败：${e.toString().split('\n').first}',
      );
    }
  }

  Future<List<AmapPoi>> _searchViaNativeSdk(String keyword) async {
    final result = await _searchChannel.invokeMethod('searchPOI', {
      'keyword': keyword,
      'city': state.searchCity,
    });
    if (result is! List) return [];
    return result
        .whereType<Map>()
        .map((e) {
          try {
            return AmapPoi.fromJson(Map<String, dynamic>.from(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<AmapPoi>()
        .toList();
  }

  Future<List<AmapPoi>> _searchViaRestApi(String keyword) async {
    final resp = await _amapDio.get(
      '/v3/place/text',
      queryParameters: {
        'key': AppConstants.amapWebKey,
        'keywords': keyword,
        'city': state.searchCity,
        'output': 'json',
        'offset': '20',
      },
    );
    final raw = resp.data;
    if (raw is! Map<String, dynamic>) return [];
    if (raw['status'] != '1') {
      throw Exception(raw['info'] as String? ?? '搜索失败');
    }
    final rawPois = raw['pois'];
    if (rawPois is! List) return [];
    return rawPois
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return AmapPoi.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<AmapPoi>()
        .toList();
  }

  Future<void> quickAddSchedule(AmapPoi poi) async {
    final form = ScheduleFormData(
      tId: arg,
      name: poi.name,
      coordinate: '${poi.longitude},${poi.latitude}',
      address: poi.address,
      isHotel: poi.type?.contains('住宿服务') ?? false,
    );
    await ref.read(scheduleProvider(arg).notifier).add(form);
    exitSearchMode();
  }
}
