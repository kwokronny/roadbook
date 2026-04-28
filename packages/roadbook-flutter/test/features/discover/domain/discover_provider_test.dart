import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/discover/data/discover_repository.dart';
import 'package:roadbook_flutter/features/discover/domain/discover_provider.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

class MockDiscoverRepository extends Mock implements DiscoverRepository {}

final _owner = PublicTravelOwner(id: 1, username: 'u', name: 'U', avatar: null);
PublicTravel _makeTravel(int id) => PublicTravel(
      id: id,
      name: 'Trip $id',
      cities: ['城市'],
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 4, 3),
      viewCount: 0,
      owner: _owner,
    );

void main() {
  late MockDiscoverRepository mockRepo;

  ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          discoverRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

  setUp(() {
    mockRepo = MockDiscoverRepository();
  });

  test('initial load populates state', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    final state = await container.read(discoverProvider.future);

    expect(state.travels.length, 1);
    expect(state.hasMore, isFalse);
    expect(state.selectedCity, isNull);
  });

  test('selectCity resets page and reloads', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));
    when(() => mockRepo.discover(page: 1, city: '东京', keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(2)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);

    await container.read(discoverProvider.notifier).selectCity('东京');
    final state = container.read(discoverProvider).value!;

    expect(state.travels.first.id, 2);
    expect(state.selectedCity, '东京');
  });

  test('loadMore appends to existing list', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: true));
    when(() => mockRepo.discover(page: 2, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(2)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);
    await container.read(discoverProvider.notifier).loadMore();

    final state = container.read(discoverProvider).value!;
    expect(state.travels.length, 2);
    expect(state.hasMore, isFalse);
  });

  test('search by keyword resets and reloads', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));
    when(() => mockRepo.discover(page: 1, city: null, keyword: '东京'))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(3)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);
    await container.read(discoverProvider.notifier).search('东京');

    final state = container.read(discoverProvider).value!;
    expect(state.travels.first.id, 3);
    expect(state.keyword, '东京');
  });

  test('loadMore resets isLoadingMore on error', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: true));
    when(() => mockRepo.discover(page: 2, city: null, keyword: null))
        .thenThrow(Exception('network error'));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);

    await expectLater(
      () => container.read(discoverProvider.notifier).loadMore(),
      throwsA(isA<Exception>()),
    );

    final state = container.read(discoverProvider).value!;
    expect(state.isLoadingMore, isFalse);
    expect(state.travels.length, 1); // original list unchanged
  });

  test('search with empty string passes null keyword', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);
    await container.read(discoverProvider.notifier).search('');

    final state = container.read(discoverProvider).value!;
    expect(state.keyword, '');
    // Verify discover was called twice with keyword: null (initial + search(''))
    verify(() => mockRepo.discover(page: 1, city: null, keyword: null)).called(2);
  });
}
