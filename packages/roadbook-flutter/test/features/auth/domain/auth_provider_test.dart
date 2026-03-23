// test/features/auth/domain/auth_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadbook_flutter/features/auth/data/auth_repository.dart';
import 'package:roadbook_flutter/features/auth/domain/auth_provider.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  MockAuthRepository();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Providers', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('signIn success updates authStateProvider', () async {
      final mockRepo = MockAuthRepository();
      const result = AuthResult(
        token: 'tok-test',
        user: User(id: 1, username: 'alice', name: 'Alice'),
      );
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => result);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(signInProvider.notifier).signIn('alice', 'pass');

      final authState = await container.read(authStateProvider.future);
      expect(authState.token, 'tok-test');
      expect(authState.user?.username, 'alice');
    });

    test('signIn failure leaves authState unauthenticated', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.login(any(), any())).thenThrow('登录失败');

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(signInProvider.notifier).signIn('bad', 'wrong');

      final authState = await container.read(authStateProvider.future);
      expect(authState.token, isNull);
      expect(container.read(signInProvider), isA<AsyncError>());
    });

    test('signUp success updates authStateProvider', () async {
      final mockRepo = MockAuthRepository();
      const result = AuthResult(
        token: 'tok-new',
        user: User(id: 2, username: 'bob'),
      );
      when(() => mockRepo.register(any(), any()))
          .thenAnswer((_) async => result);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(signUpProvider.notifier).signUp('bob', 'secret');

      final authState = await container.read(authStateProvider.future);
      expect(authState.token, 'tok-new');
    });
  });
}
