// lib/features/auth/domain/auth_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/providers/dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

// ─────────────────────────── Sign In ───────────────────────────

class SignInNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String username, String password) async {
    state = const AsyncLoading();
    try {
      final result =
          await ref.read(authRepositoryProvider).login(username, password);
      await ref.read(authStateProvider.notifier).login(result.token, result.user);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final signInProvider =
    AsyncNotifierProvider.autoDispose<SignInNotifier, void>(SignInNotifier.new);

// ─────────────────────────── Sign Up ───────────────────────────

class SignUpNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signUp(String username, String password) async {
    state = const AsyncLoading();
    try {
      final result =
          await ref.read(authRepositoryProvider).register(username, password);
      await ref.read(authStateProvider.notifier).login(result.token, result.user);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final signUpProvider =
    AsyncNotifierProvider.autoDispose<SignUpNotifier, void>(SignUpNotifier.new);
