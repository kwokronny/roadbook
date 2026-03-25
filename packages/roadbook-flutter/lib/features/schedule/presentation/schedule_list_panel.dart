// lib/features/schedule/presentation/schedule_list_panel.dart
// NOTE: 不含 Scaffold — FAB 由父级 TravelDetailScreen 管理
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/user_travel.dart';
import '../../../shared/utils/schedule_day_helper.dart';
import '../domain/schedule_provider.dart';
import 'widgets/day_sidebar.dart';
import 'widgets/schedule_timeline_item.dart';
import 'widgets/schedule_nav_button.dart';
import 'schedule_edit_sheet.dart';
import 'schedule_quick_time_sheet.dart';

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
        // ── 左侧：时间轴列表
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
                return Center(
                  child: Text(
                    selectedDay == 0 ? '暂无待规划行程' : '第 $selectedDay 天暂无行程',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async =>
                    ref.invalidate(scheduleProvider(travel.id!)),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal, 14,
                      AppSpacing.pageHorizontal, 14),
                  itemCount: items.length + 1,
                  itemBuilder: (context, i) {
                    if (i == items.length) return const SizedBox(height: 16);
                    final s = items[i];
                    return Stack(
                      children: [
                        // Vertical timeline line
                        Positioned(
                          left: 19, // center of 40px cover image
                          top: i == 0 ? 20 : 0,
                          bottom: i == items.length - 1 ? 20 : 0,
                          child: Container(
                            width: 2,
                            color: AppColors.border,
                          ),
                        ),
                        ScheduleTimelineItem(
                          schedule: s,
                          travelStartDate: travel.startDate,
                          canEdit: _canEdit,
                          onEditTimeTap: _canEdit
                              ? () => ScheduleQuickTimeSheet.show(
                                    context,
                                    travel: travel,
                                    schedule: s,
                                  )
                              : null,
                          onMoreTap: () =>
                              _showMoreMenu(context, ref, s, selectedDay),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        // ── 右侧：天数栏
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: DaySidebar(
            totalDays: _totalDays,
            selectedDay: selectedDay,
            travelStartDate: travel.startDate,
            onDaySelected: (d) =>
                ref.read(selectedDayProvider(travel.id!).notifier).state = d,
          ),
        ),
      ],
    );
  }

  void _showMoreMenu(
      BuildContext context, WidgetRef ref, Schedule s, int currentDay) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                ScheduleEditSheet.show(context,
                    travel: travel, schedule: s, initialDay: currentDay);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('克隆'),
              onTap: () {
                Navigator.pop(context);
                ref.read(scheduleProvider(travel.id!).notifier).clone(s.id!);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ScheduleNavButton(
                    coordinate: s.coordinate,
                    name: s.name,
                    isHotel: s.isHotel,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, s);
              },
            ),
          ],
        ),
      ),
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
