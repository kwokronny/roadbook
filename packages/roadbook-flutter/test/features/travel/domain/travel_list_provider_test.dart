import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/travel/data/travel_repository.dart';
import 'package:roadbook_flutter/features/travel/domain/travel_list_provider.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';

class MockTravelRepository extends Mock implements TravelRepository {}

Travel _makeTravel(int id) => Travel(
      id: id,
      name: 'Trip $id',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 5),
      isPublic: false,
      isAbroad: false,
      cities: [],
      collaborators: [],
      schedules: [],
    );

TravelPage _makePage(List<Travel> travels, {bool hasMore = false}) =>
    TravelPage(travels: travels, hasMore: hasMore);

void main() {
  group('TravelListNotifier', () {
    late MockTravelRepository mockRepo;

    setUp(() {
      mockRepo = MockTravelRepository();
    });

    ProviderContainer makeContainer() => ProviderContainer(overrides: [
          travelRepositoryProvider.overrideWithValue(mockRepo),
        ]);

    test('initial build loads page 1', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1), _makeTravel(2)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      final state = await container.read(travelListProvider.future);
      expect(state.items.length, 2);
      expect(state.page, 1);
      expect(state.hasMore, isFalse);
      expect(state.keyword, '');
    });

    test('loadMore appends travels and increments page', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1)], hasMore: true));
      when(() => mockRepo.page(page: 2, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(2)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).loadMore();

      final state = container.read(travelListProvider).value!;
      expect(state.items.length, 2);
      expect(state.page, 2);
      expect(state.hasMore, isFalse);
    });

    test('loadMore is no-op when hasMore is false', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).loadMore();

      // page() called exactly once
      verify(() => mockRepo.page(page: 1, keyword: '')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('refresh resets to page 1 and replaces items', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1), _makeTravel(2)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).refresh();

      final state = container.read(travelListProvider).value!;
      expect(state.items.length, 2);
      expect(state.page, 1);
    });

    test('setKeyword resets to page 1 with new keyword', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1)]));
      when(() => mockRepo.page(page: 1, keyword: '上海'))
          .thenAnswer((_) async => _makePage([_makeTravel(99)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).setKeyword('上海');

      final state = container.read(travelListProvider).value!;
      expect(state.items.first.id, 99);
      expect(state.keyword, '上海');
      expect(state.page, 1);
    });
  });
}
