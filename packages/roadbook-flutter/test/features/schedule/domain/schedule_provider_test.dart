// test/features/schedule/domain/schedule_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/schedule/data/schedule_repository.dart';
import 'package:roadbook_flutter/features/schedule/domain/schedule_provider.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

Schedule _make(int id) => Schedule(
      id: id,
      tId: 10,
      name: 'Place $id',
      coordinate: '116.4,39.9',
      address: '北京',
      isHotel: false,
    );

void main() {
  group('ScheduleNotifier', () {
    late MockScheduleRepository mockRepo;

    setUp(() {
      mockRepo = MockScheduleRepository();
      registerFallbackValue(const ScheduleFormData(
        tId: 10,
        name: 'x',
        coordinate: '0,0',
        address: '',
        isHotel: false,
      ));
    });

    ProviderContainer makeContainer() => ProviderContainer(overrides: [
          scheduleRepositoryProvider.overrideWithValue(mockRepo),
        ]);

    test('build loads schedule list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1), _make(2)]);

      final container = makeContainer();
      addTearDown(container.dispose);
      container.listen(scheduleProvider(10), (_, __) {});

      final items = await container.read(scheduleProvider(10).future);
      expect(items.length, 2);
    });

    test('add appends schedule to list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1)]);
      when(() => mockRepo.add(any())).thenAnswer((_) async => _make(99));

      final container = makeContainer();
      addTearDown(container.dispose);
      container.listen(scheduleProvider(10), (_, __) {});

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).add(const ScheduleFormData(
            tId: 10, name: 'New', coordinate: '0,0', address: '', isHotel: false));

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 2);
      expect(items.last.id, 99);
    });

    test('update replaces schedule in list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1), _make(2)]);
      const updated = Schedule(
          id: 1, tId: 10, name: 'Updated', coordinate: '0,0', address: '', isHotel: false);
      when(() => mockRepo.update(any())).thenAnswer((_) async => updated);

      final container = makeContainer();
      addTearDown(container.dispose);
      container.listen(scheduleProvider(10), (_, __) {});

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).edit(const ScheduleFormData(
            id: 1, tId: 10, name: 'Updated', coordinate: '0,0', address: '', isHotel: false));

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 2);
      expect(items.first.name, 'Updated');
    });

    test('remove removes schedule from list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1), _make(2)]);
      when(() => mockRepo.remove(1)).thenAnswer((_) async {});

      final container = makeContainer();
      addTearDown(container.dispose);
      container.listen(scheduleProvider(10), (_, __) {});

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).remove(1);

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 1);
      expect(items.first.id, 2);
    });

    test('clone appends cloned schedule', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1)]);
      when(() => mockRepo.clone(1)).thenAnswer((_) async => _make(55));

      final container = makeContainer();
      addTearDown(container.dispose);
      container.listen(scheduleProvider(10), (_, __) {});

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).clone(1);

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 2);
      expect(items.last.id, 55);
    });
  });
}
