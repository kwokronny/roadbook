import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_state_notifier.dart';
import 'package:roadbook_flutter/features/schedule/domain/schedule_provider.dart';
import 'package:roadbook_flutter/shared/providers/dio_provider.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

ProviderContainer _makeContainer({Dio? dio}) {
  final mockDio = dio ?? MockDio();
  return ProviderContainer(overrides: [
    dioProvider.overrideWithValue(mockDio),
  ]);
}

void main() {
  const travelId = 42;

  group('MapStateNotifier 初始状态', () {
    test('默认 day 模式，selectedScheduleId null，搜索城市全国', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final state = container.read(mapStateProvider(travelId));
      expect(state.mode, MapMode.day);
      expect(state.selectedScheduleId, isNull);
      expect(state.searchCity, '全国');
      expect(state.poiResults, isEmpty);
      expect(state.isSearching, isFalse);
    });
  });

  group('mode 切换', () {
    test('enterSearchMode → mode=search，清空 selectedScheduleId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier)
        ..selectMarker(99)
        ..enterSearchMode();
      final state = container.read(mapStateProvider(travelId));
      expect(state.mode, MapMode.search);
      expect(state.selectedScheduleId, isNull);
    });

    test('exitSearchMode → mode=day，清空 poiResults 和 selectedPoiId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier)
        ..enterSearchMode()
        ..selectPoi('poi_1')
        ..exitSearchMode();
      final state = container.read(mapStateProvider(travelId));
      expect(state.mode, MapMode.day);
      expect(state.selectedPoiId, isNull);
      expect(state.poiResults, isEmpty);
    });
  });

  group('Marker 选择', () {
    test('selectMarker 更新 selectedScheduleId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier).selectMarker(5);
      expect(container.read(mapStateProvider(travelId)).selectedScheduleId, 5);
    });

    test('clearMarker 置空 selectedScheduleId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier)
        ..selectMarker(5)
        ..clearMarker();
      expect(container.read(mapStateProvider(travelId)).selectedScheduleId, isNull);
    });
  });

  group('POI 选择', () {
    test('selectPoi 更新 selectedPoiId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier).selectPoi('abc');
      expect(container.read(mapStateProvider(travelId)).selectedPoiId, 'abc');
    });
  });

  group('城市切换', () {
    test('setSearchCity 更新 searchCity', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier).setSearchCity('北京');
      expect(container.read(mapStateProvider(travelId)).searchCity, '北京');
    });
  });
}
