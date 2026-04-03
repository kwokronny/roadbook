// lib/features/schedule/presentation/schedule_list_panel.dart
// NOTE: 不含 Scaffold — FAB 由父级 TravelDetailScreen 管理
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/user_travel.dart';
import '../../../shared/utils/schedule_day_helper.dart';
import '../domain/schedule_provider.dart';
import 'widgets/day_sidebar.dart';
import 'widgets/schedule_timeline_item.dart';
import 'schedule_edit_sheet.dart';
import 'schedule_quick_time_sheet.dart';

class _LuggageMarker {
  const _LuggageMarker();
}

class ScheduleListPanel extends ConsumerStatefulWidget {
  const ScheduleListPanel({
    super.key,
    required this.travel,
    required this.perm,
  });

  final Travel travel;
  final RoleType perm;

  @override
  ConsumerState<ScheduleListPanel> createState() => _ScheduleListPanelState();
}

class _ScheduleListPanelState extends ConsumerState<ScheduleListPanel> {
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  Travel get travel => widget.travel;
  RoleType get perm => widget.perm;

  int get _totalDays =>
      travel.endDate.difference(travel.startDate).inDays + 1;

  bool get _canEdit => perm == RoleType.manage || perm == RoleType.edit;

  List<Schedule> _schedulesForDay(int day, List<Schedule> all) =>
      schedulesForDay(day, all, travel.startDate, totalDays: _totalDays);

  List<Object> _buildDisplayItems(int selectedDay, List<Schedule> items) {
    final result = <Object>[];
    if (selectedDay == 1 && items.isNotEmpty) {
      result.add(const _LuggageMarker());
    }
    for (final s in items) {
      result.add(s);
      if (_isCheckoutDay(s, selectedDay)) {
        result.add(const _LuggageMarker());
      }
    }
    return result;
  }

  bool _isCheckoutDay(Schedule s, int selectedDay) {
    if (!s.isHotel || s.endTime == null) return false;
    final checkoutDay =
        s.endTime!.toLocal().difference(travel.startDate).inDays + 1;
    return selectedDay == checkoutDay;
  }

  void _enterSelectionMode(int scheduleId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.clear();
      _selectedIds.add(scheduleId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(List<Schedule> items) {
    setState(() {
      final allIds = items.map((s) => s.id!).toSet();
      if (_selectedIds.containsAll(allIds)) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(allIds);
      }
    });
  }

  Future<void> _batchDelete() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定删除选中的 $count 个行程？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('删除',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    final notifier = ref.read(scheduleProvider(travel.id!).notifier);
    for (final id in _selectedIds.toList()) {
      await notifier.remove(id);
    }
    _exitSelectionMode();
  }

  Future<void> _batchMove() async {
    final targetDay = await showDialog<int>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('移至第几天'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogCtx).pop(0),
            child: const Text('待规划'),
          ),
          for (int d = 1; d <= _totalDays; d++)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogCtx).pop(d),
              child: Text('第 $d 天'),
            ),
        ],
      ),
    );
    if (targetDay == null) return;

    final notifier = ref.read(scheduleProvider(travel.id!).notifier);
    final allSchedules = ref.read(scheduleProvider(travel.id!)).valueOrNull ?? [];

    for (final id in _selectedIds.toList()) {
      final s = allSchedules.where((s) => s.id == id).firstOrNull;
      if (s == null) continue;

      DateTime? newStart;
      DateTime? newEnd;
      if (targetDay > 0) {
        // Move to target day, preserve time-of-day or default to 09:00
        final targetDate = travel.startDate.add(Duration(days: targetDay - 1));
        final oldTime = s.startTime?.toLocal();
        final hour = oldTime?.hour ?? 9;
        final minute = oldTime?.minute ?? 0;
        newStart = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
        if (s.isHotel && s.endTime != null) {
          final oldEnd = s.endTime!.toLocal();
          final duration = s.startTime != null
              ? oldEnd.difference(s.startTime!.toLocal())
              : const Duration(days: 1);
          newEnd = newStart.add(duration);
        }
      }
      // targetDay == 0 → clear time (待规划)

      await notifier.quickEditTime(
        schedule: s,
        travelId: travel.id!,
        newStartTime: newStart,
        newEndTime: newEnd,
      );
    }
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(scheduleProvider(travel.id!));
    final selectedDay = ref.watch(selectedDayProvider(travel.id!));

    return Column(
      children: [
        // ── Top: Day bar
        IgnorePointer(
          ignoring: _isSelectionMode,
          child: Opacity(
            opacity: _isSelectionMode ? 0.4 : 1.0,
            child: DayBar(
              totalDays: _totalDays,
              selectedDay: selectedDay,
              travelStartDate: travel.startDate,
              onDaySelected: (d) =>
                  ref.read(selectedDayProvider(travel.id!).notifier).state = d,
            ),
          ),
        ),
        // ── Bottom: Timeline list (full width)
        Expanded(
          child: listAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.toString(), style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(scheduleProvider(travel.id!)),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
            data: (all) {
              final items = _schedulesForDay(selectedDay, all);
              if (items.isEmpty) {
                if (_isSelectionMode) _exitSelectionMode();
                return Center(
                  child: Text(
                    selectedDay == 0 ? '暂无待规划行程' : '第 $selectedDay 天暂无行程',
                    style: AppTextStyles.caption,
                  ),
                );
              }

              final displayItems = _buildDisplayItems(selectedDay, items);

              final allSelected = items.every((s) => _selectedIds.contains(s.id));

              return Column(
                children: [
                  // ── Selection toolbar
                  if (_isSelectionMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleSelectAll(items),
                            child: Icon(
                              allSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 22,
                              color: allSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('已选 ${_selectedIds.length} 项', style: AppTextStyles.caption),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _selectedIds.isNotEmpty ? _batchMove : null,
                            child: Icon(Icons.drive_file_move_outline, size: 22,
                                color: _selectedIds.isNotEmpty ? AppColors.primary : AppColors.textDisabled),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _selectedIds.isNotEmpty ? _batchDelete : null,
                            child: Icon(Icons.delete_outline, size: 22,
                                color: _selectedIds.isNotEmpty ? Colors.red : AppColors.textDisabled),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _exitSelectionMode,
                            child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                  // ── List
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async =>
                          ref.invalidate(scheduleProvider(travel.id!)),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal, 8,
                            AppSpacing.pageHorizontal, 100),
                        itemCount: displayItems.length + 1,
                        itemBuilder: (context, i) {
                          if (i == displayItems.length) {
                            return const SizedBox(height: 16);
                          }

                          final entry = displayItems[i];

                          if (entry is _LuggageMarker) {
                            if (_isSelectionMode) return const SizedBox.shrink();
                            return _LuggageCheckItem(
                              onTap: () => context.push('/travel/${travel.id}/luggage'),
                            );
                          }

                          final s = entry as Schedule;
                          return ScheduleTimelineItem(
                            schedule: s,
                            travelStartDate: travel.startDate,
                            canEdit: _canEdit,
                            displayDay: selectedDay,
                            isSelectionMode: _isSelectionMode,
                            isSelected: _selectedIds.contains(s.id),
                            onLongPress: _canEdit ? () => _enterSelectionMode(s.id!) : null,
                            onToggleSelect: () => _toggleSelect(s.id!),
                            onEditTimeTap: _canEdit
                                ? () => ScheduleQuickTimeSheet.show(
                                      context,
                                      travel: travel,
                                      schedule: s,
                                    )
                                : null,
                            onEdit: _canEdit
                                ? () => ScheduleEditSheet.show(context,
                                      travel: travel,
                                      schedule: s,
                                      initialDay: selectedDay)
                                : null,
                            onClone: _canEdit
                                ? () => ref
                                      .read(scheduleProvider(travel.id!).notifier)
                                      .clone(s.id!)
                                : null,
                            onDelete: _canEdit
                                ? () => _confirmDelete(context, ref, s)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Schedule s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('删除行程'),
        content: Text('确定删除「${s.name}」？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('删除',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(scheduleProvider(travel.id!).notifier)
          .remove(s.id!);
    }
  }
}

class _LuggageCheckItem extends StatelessWidget {
  const _LuggageCheckItem({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.luggage_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '清点行李',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
