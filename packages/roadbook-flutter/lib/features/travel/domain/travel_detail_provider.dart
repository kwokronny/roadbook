// lib/features/travel/domain/travel_detail_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'travel_list_provider.dart'; // travelRepositoryProvider + TravelRepository
import '../../../shared/models/travel.dart';
import '../../../shared/models/user_travel.dart';
import '../../../shared/providers/auth_state_provider.dart';

// ─── Detail Provider ──────────────────────────────────────────────────────────

final travelDetailProvider =
    AsyncNotifierProvider.autoDispose.family<TravelDetailNotifier, Travel, int>(
        TravelDetailNotifier.new);

class TravelDetailNotifier extends AutoDisposeFamilyAsyncNotifier<Travel, int> {
  @override
  Future<Travel> build(int arg) async {
    // Warm up auth state so travelPermProvider can read it synchronously after this resolves.
    await ref.read(authStateProvider.future);
    return ref.read(travelRepositoryProvider).detail(arg);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(travelRepositoryProvider).detail(arg));
  }

  Future<void> updateCollab(int userId, String role) async {
    await ref
        .read(travelRepositoryProvider)
        .setRole(arg, userId: userId, role: role);
    await reload();
  }

  Future<void> removeCollab(int userId) async {
    await ref
        .read(travelRepositoryProvider)
        .setRole(arg, userId: userId, role: 'delete');
    await reload();
  }
}

// ─── Permission Provider ──────────────────────────────────────────────────────

/// 当前登录用户对指定旅程的权限（manage / edit / view）
final travelPermProvider =
    Provider.autoDispose.family<RoleType, int>((ref, travelId) {
  final authUser = ref.watch(authStateProvider).valueOrNull?.user;
  final travel = ref.watch(travelDetailProvider(travelId)).valueOrNull;
  if (authUser == null || travel == null) return RoleType.view;
  final match = travel.collaborators.where((c) => c.user.id == authUser.id);
  return match.isEmpty ? RoleType.view : match.first.role;
});
