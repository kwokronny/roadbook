// lib/features/schedule/presentation/schedule_list_panel.dart
// NOTE: 不含 Scaffold — FAB 由父级 TravelDetailScreen 管理，避免嵌套 Scaffold 问题
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/user_travel.dart';
import '../../../shared/utils/schedule_day_helper.dart';
import '../domain/schedule_provider.dart';
import 'widgets/day_sidebar.dart';
import 'widgets/schedule_item.dart';
import 'schedule_edit_sheet.dart';

class ScheduleListPanel extends ConsumerWidget {
  const ScheduleListPanel({
    super.key,
    required this.travel,
    required this.perm,
  });

  final Travel travel;
  final RoleType perm;

  int get _totalDays =>
      travel.endDate.difference(travel.startDate).inDays + 1;

  bool get _canEdit => perm == RoleType.manage || perm == RoleType.edit;

  List<Schedule> _schedulesForDay(int day, List<Schedule> all) =>
      schedulesForDay(day, all, travel.startDate);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(scheduleProvider(travel.id!));
    final selectedDay = ref.watch(selectedDayProvider(travel.id!));

    return Row(
      children: [
        // ── 左侧天数栏
        Container(
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: DaySidebar(
            totalDays: _totalDays,
            selectedDay: selectedDay,
            travelStartDate: travel.startDate,
            onDaySelected: (d) =>
                ref.read(selectedDayProvider(travel.id!).notifier).state = d,
          ),
        ),
        // ── 右侧行程列表
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
                    onPressed: () => ref.invalidate(scheduleProvider(travel.id!)),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
            data: (all) {
              final items = _schedulesForDay(selectedDay, all);
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    selectedDay == 0 ? '暂无待规划行程' : '第 $selectedDay 天暂无行程',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(scheduleProvider(travel.id!)),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final s = items[i];
                    return ScheduleItem(
                      schedule: s,
                      canEdit: _canEdit,
                      onTap: _canEdit
                          ? () => ScheduleEditSheet.show(
                                context,
                                travel: travel,
                                schedule: s,
                                initialDay: selectedDay,
                              )
                          : () {},
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
      builder: (_) => AlertDialog(
        title: const Text('删除行程'),
        content: Text('确定删除「${s.name}」？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(scheduleProvider(travel.id!).notifier).remove(s.id!);
    }
  }
}
