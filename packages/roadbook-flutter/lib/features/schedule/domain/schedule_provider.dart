// lib/features/schedule/domain/schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/providers/dio_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(dioProvider));
});

// ─── Schedule List Provider (family by travelId) ─────────────────────────────

final scheduleProvider = AsyncNotifierProvider.autoDispose
    .family<ScheduleNotifier, List<Schedule>, int>(ScheduleNotifier.new);

class ScheduleNotifier extends AutoDisposeFamilyAsyncNotifier<List<Schedule>, int> {
  @override
  Future<List<Schedule>> build(int arg) async {
    return ref.read(scheduleRepositoryProvider).list(arg);
  }

  Future<void> add(ScheduleFormData form) async {
    final newSchedule = await ref.read(scheduleRepositoryProvider).add(form);
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, newSchedule]);
  }

  Future<void> edit(ScheduleFormData form) async {
    final updated = await ref.read(scheduleRepositoryProvider).update(form);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.map((s) => s.id == updated.id ? updated : s).toList());
  }

  Future<void> remove(int id) async {
    await ref.read(scheduleRepositoryProvider).remove(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((s) => s.id != id).toList());
  }

  Future<void> clone(int id) async {
    final cloned = await ref.read(scheduleRepositoryProvider).clone(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, cloned]);
  }
}

// ─── Selected Day Provider (family by travelId) ───────────────────────────────

/// 0 = 待规划，1-N = 第 N 天
final selectedDayProvider =
    StateProvider.autoDispose.family<int, int>((ref, travelId) => 1);
