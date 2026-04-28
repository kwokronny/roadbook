import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/luggage/data/luggage_repository.dart';
import 'package:roadbook_flutter/features/luggage/domain/luggage_provider.dart';
import 'package:roadbook_flutter/features/travel/domain/travel_detail_provider.dart';
import 'package:roadbook_flutter/shared/constants/luggage_presets.dart';
import 'package:roadbook_flutter/shared/models/luggage.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/shared/models/user_travel.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';

class MockLuggageRepository extends Mock implements LuggageRepository {}

class _FakeAuthNotifier extends AuthStateNotifier {
  _FakeAuthNotifier(this._userId);
  final int _userId;

  @override
  Future<AuthState> build() async => AuthState(
        token: 'tok',
        user: User(id: _userId, username: 'u$_userId', name: 'User'),
      );
}

class _FakeTravelDetailNotifier extends TravelDetailNotifier {
  _FakeTravelDetailNotifier(this._travel);
  final Travel _travel;

  @override
  Future<Travel> build(int arg) async => _travel;
}

Travel _makeTravel({String? equip, RoleType role = RoleType.manage}) {
  final user = User(id: 1, username: 'alice', name: 'Alice');
  return Travel(
    id: 10,
    name: 'Trip',
    startDate: DateTime(2026, 4, 1),
    endDate: DateTime(2026, 4, 5),
    isPublic: false,
    isAbroad: false,
    cities: [],
    collaborators: [UserWithRole(user: user, role: role)],
    schedules: [],
    equip: equip,
  );
}

ProviderContainer _makeContainer({
  required Travel travel,
  required MockLuggageRepository mockRepo,
  int userId = 1,
}) =>
    ProviderContainer(overrides: [
      travelDetailProvider.overrideWith(() => _FakeTravelDetailNotifier(travel)),
      authStateProvider.overrideWith(() => _FakeAuthNotifier(userId)),
      luggageRepositoryProvider.overrideWithValue(mockRepo),
    ]);

void main() {
  late MockLuggageRepository mockRepo;

  setUp(() {
    mockRepo = MockLuggageRepository();
    when(() => mockRepo.setEquip(
          travelId: any(named: 'travelId'),
          equip: any(named: 'equip'),
        )).thenAnswer((_) async {});
  });

  test('build parses equip JSON and canEdit=true for manage role', () async {
    final cats = [
      LuggageCategory(
        id: 'c1',
        name: '证件',
        emoji: '📋',
        items: [const LuggageItem(id: 'i1', text: '护照')],
      ),
    ];
    final travel =
        _makeTravel(equip: jsonEncode(cats.map((c) => c.toJson()).toList()));
    final container =
        _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    // Ensure auth state is resolved before luggage provider reads it synchronously
    await container.read(authStateProvider.future);
    container.listen(luggageProvider(10), (_, __) {});

    final state = await container.read(luggageProvider(10).future);
    expect(state.categories.length, 1);
    expect(state.categories.first.name, '证件');
    expect(state.canEdit, isTrue);
    expect(state.totalItems, 1);
    expect(state.checkedCount, 0);
  });

  test('build sets canEdit=false for view role', () async {
    final travel = _makeTravel(role: RoleType.view);
    final container =
        _makeContainer(travel: travel, mockRepo: mockRepo, userId: 99);
    addTearDown(container.dispose);
    // Ensure auth state is resolved before luggage provider reads it synchronously
    await container.read(authStateProvider.future);
    container.listen(luggageProvider(10), (_, __) {});

    final state = await container.read(luggageProvider(10).future);
    expect(state.canEdit, isFalse);
  });

  test('build with null equip yields empty categories', () async {
    final travel = _makeTravel(equip: null);
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    final state = await container.read(luggageProvider(10).future);
    expect(state.categories, isEmpty);
  });

  test('toggleCheck adds itemId to checkedIds', () async {
    final travel = _makeTravel(
      equip: jsonEncode([
        {
          'id': 'c1', 'name': '证件', 'emoji': '📋',
          'items': [{'id': 'i1', 'text': '护照'}]
        }
      ]),
    );
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    container.read(luggageProvider(10).notifier).toggleCheck('i1');

    final state = container.read(luggageProvider(10)).value!;
    expect(state.checkedIds, contains('i1'));
    expect(state.checkedCount, 1);
  });

  test('toggleCheck removes itemId when already checked', () async {
    final travel = _makeTravel(
      equip: jsonEncode([
        {
          'id': 'c1', 'name': '证件', 'emoji': '📋',
          'items': [{'id': 'i1', 'text': '护照'}]
        }
      ]),
    );
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    container.read(luggageProvider(10).notifier).toggleCheck('i1');
    container.read(luggageProvider(10).notifier).toggleCheck('i1');

    final state = container.read(luggageProvider(10)).value!;
    expect(state.checkedIds, isEmpty);
  });

  test('addCategory appends category with emoji 📦 and calls setEquip', () async {
    final travel = _makeTravel(equip: '[]');
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    await container.read(luggageProvider(10).notifier).addCategory('衣物');

    final state = container.read(luggageProvider(10)).value!;
    expect(state.categories.length, 1);
    expect(state.categories.first.name, '衣物');
    expect(state.categories.first.emoji, '📦');
    verify(() =>
            mockRepo.setEquip(travelId: 10, equip: any(named: 'equip')))
        .called(1);
  });

  test('deleteCategory removes category and calls setEquip', () async {
    final travel = _makeTravel(
      equip: jsonEncode([
        {'id': 'c1', 'name': '证件', 'emoji': '📋', 'items': []},
        {'id': 'c2', 'name': '衣物', 'emoji': '👕', 'items': []},
      ]),
    );
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    await container.read(luggageProvider(10).notifier).deleteCategory('c1');

    final state = container.read(luggageProvider(10)).value!;
    expect(state.categories.length, 1);
    expect(state.categories.first.id, 'c2');
  });

  test('addItems appends items to correct category', () async {
    final travel = _makeTravel(
      equip: jsonEncode([
        {'id': 'c1', 'name': '证件', 'emoji': '📋', 'items': []},
      ]),
    );
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    await container
        .read(luggageProvider(10).notifier)
        .addItems('c1', ['护照', '签证']);

    final state = container.read(luggageProvider(10)).value!;
    expect(state.categories.first.items.length, 2);
    expect(state.categories.first.items.map((i) => i.text),
        containsAll(['护照', '签证']));
  });

  test('deleteItem removes item from correct category', () async {
    final travel = _makeTravel(
      equip: jsonEncode([
        {
          'id': 'c1', 'name': '证件', 'emoji': '📋',
          'items': [{'id': 'i1', 'text': '护照'}]
        }
      ]),
    );
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    await container
        .read(luggageProvider(10).notifier)
        .deleteItem('c1', 'i1');

    final state = container.read(luggageProvider(10)).value!;
    expect(state.categories.first.items, isEmpty);
  });

  test('importTemplate merges same-named category, skips duplicate items',
      () async {
    final travel = _makeTravel(
      equip: jsonEncode([
        {
          'id': 'c1', 'name': '证件', 'emoji': '📋',
          'items': [{'id': 'i1', 'text': '护照'}]
        }
      ]),
    );
    final container = _makeContainer(travel: travel, mockRepo: mockRepo);
    addTearDown(container.dispose);
    container.listen(luggageProvider(10), (_, __) {});

    await container.read(luggageProvider(10).future);
    final added = await container
        .read(luggageProvider(10).notifier)
        .importTemplate(LuggageSeason.spring);

    final state = container.read(luggageProvider(10)).value!;
    // Spring template has 4 categories; '证件' already exists → merged
    expect(state.categories.length, 4);
    final cert = state.categories.firstWhere((c) => c.name == '证件');
    // '护照' already existed → not duplicated
    expect(cert.items.where((i) => i.text == '护照').length, 1);
    expect(added, isA<int>());
    expect(added, greaterThan(0));
  });
}
