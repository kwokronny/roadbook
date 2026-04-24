// test/features/travel/domain/travel_detail_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/travel/data/travel_repository.dart';
import 'package:roadbook_flutter/features/travel/domain/travel_list_provider.dart';
import 'package:roadbook_flutter/features/travel/domain/travel_detail_provider.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/shared/models/user_travel.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';

class MockTravelRepository extends Mock implements TravelRepository {}

class _FakeAuthNotifier extends AuthStateNotifier {
  _FakeAuthNotifier(this._userId);
  final int _userId;

  @override
  Future<AuthState> build() async => AuthState(
        token: 'tok',
        user: User(id: _userId, username: 'user$_userId', name: 'User'),
      );
}

Travel _makeTravel({List<UserWithRole> collaborators = const []}) => Travel(
      id: 1,
      name: 'Trip',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 5),
      isPublic: false,
      isAbroad: false,
      cities: [],
      collaborators: collaborators,
      schedules: [],
    );

void main() {
  group('TravelDetailNotifier', () {
    late MockTravelRepository mockRepo;

    setUp(() {
      mockRepo = MockTravelRepository();
    });

    ProviderContainer makeContainer({int userId = 1}) => ProviderContainer(
          overrides: [
            travelRepositoryProvider.overrideWithValue(mockRepo),
            authStateProvider.overrideWith(() => _FakeAuthNotifier(userId)),
          ],
        );

    test('build loads travel detail', () async {
      final travel = _makeTravel();
      when(() => mockRepo.detail(1)).thenAnswer((_) async => travel);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(travelDetailProvider(1).future);
      expect(result.id, 1);
      expect(result.name, 'Trip');
    });

    test('travelPermProvider returns manage when user has manage role', () async {
      final travel = _makeTravel(collaborators: [
        const UserWithRole(
          user: User(id: 1, username: 'alice', name: 'Alice'),
          role: RoleType.manage,
        ),
      ]);
      when(() => mockRepo.detail(1)).thenAnswer((_) async => travel);

      final container = makeContainer(userId: 1);
      addTearDown(container.dispose);

      await container.read(travelDetailProvider(1).future);
      final perm = container.read(travelPermProvider(1));
      expect(perm, RoleType.manage);
    });

    test('travelPermProvider returns view when user not in collaborators', () async {
      final travel = _makeTravel(collaborators: []);
      when(() => mockRepo.detail(1)).thenAnswer((_) async => travel);

      final container = makeContainer(userId: 99);
      addTearDown(container.dispose);

      await container.read(travelDetailProvider(1).future);
      final perm = container.read(travelPermProvider(1));
      expect(perm, RoleType.view);
    });
  });
}
