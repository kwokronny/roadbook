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

  /// 快捷时间修改：乐观更新，失败时回滚。
  /// 调用方负责关闭弹窗，此方法会 throw 错误供调用方显示 SnackBar。
  Future<void> quickEditTime({
    required Schedule schedule,
    required int travelId,
    required DateTime? newStartTime,
    required DateTime? newEndTime,
  }) async {
    final current = state.valueOrNull ?? [];
    final snapshot = List<Schedule>.from(current); // rollback snapshot

    // Optimistic update
    final optimistic = Schedule(
      id: schedule.id,
      tId: schedule.tId,
      name: schedule.name,
      coordinate: schedule.coordinate,
      address: schedule.address,
      cover: schedule.cover,
      dianpingUUID: schedule.dianpingUUID,
      isHotel: schedule.isHotel,
      startTime: newStartTime,
      endTime: newEndTime,
      screenshots: schedule.screenshots,
      notes: schedule.notes,
    );
    state = AsyncData(current.map((s) => s.id == schedule.id ? optimistic : s).toList());

    try {
      final form = ScheduleFormData(
        id: schedule.id,
        tId: travelId,
        name: schedule.name,
        coordinate: schedule.coordinate,
        address: schedule.address,
        isHotel: schedule.isHotel,
        startTime: newStartTime,
        endTime: newEndTime,
        cover: schedule.cover,
        dianpingUUID: schedule.dianpingUUID,
        notes: schedule.notes,
        screenshots: schedule.screenshots,
      );
      final server = await ref.read(scheduleRepositoryProvider).update(form);
      state = AsyncData(
          (state.valueOrNull ?? []).map((s) => s.id == server.id ? server : s).toList());
    } catch (e) {
      state = AsyncData(snapshot); // rollback
      rethrow;
    }
  }
}

// ─── Selected Day Provider (family by travelId) ───────────────────────────────

/// 0 = 待规划，1-N = 第 N 天
final selectedDayProvider =
    StateProvider.autoDispose.family<int, int>((ref, travelId) => 1);
