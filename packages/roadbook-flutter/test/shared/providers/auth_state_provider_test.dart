// test/shared/providers/auth_state_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';
import 'package:roadbook_flutter/shared/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStateNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is unauthenticated', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await container.read(authStateProvider.future);
      expect(state.token, isNull);
      expect(state.user, isNull);
    });

    test('login stores token and user', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const token = 'abc123';
      const user = User(id: 1, username: 'testuser');

      await container.read(authStateProvider.notifier).login(token, user);
      final state = await container.read(authStateProvider.future);

      expect(state.token, token);
      expect(state.user?.id, 1);
    });

    test('logout clears token and user', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.notifier).login(
            'tok', const User(id: 1, username: 'u'));
      await container.read(authStateProvider.notifier).logout();

      final state = await container.read(authStateProvider.future);
      expect(state.token, isNull);
      expect(state.user, isNull);
    });
  });
}
