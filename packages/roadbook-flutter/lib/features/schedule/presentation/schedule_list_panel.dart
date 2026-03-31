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

              final displayItems = _buildDisplayItems(selectedDay, items);
              // Precompute display-list indices of Schedule entries for timeline lines
              final scheduleIndices = [
                for (int i = 0; i < displayItems.length; i++)
                  if (displayItems[i] is Schedule) i,
              ];

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async =>
                    ref.invalidate(scheduleProvider(travel.id!)),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal, 14,
                      AppSpacing.pageHorizontal, 14),
                  itemCount: displayItems.length + 1,
                  itemBuilder: (context, i) {
                    if (i == displayItems.length) {
                      return const SizedBox(height: 16);
                    }

                    final entry = displayItems[i];

                    if (entry is _LuggageMarker) {
                      final hasPrev = i > 0 && displayItems[i - 1] is Schedule;
                      final hasNext = i < displayItems.length - 1 &&
                          displayItems[i + 1] is Schedule;
                      return _LuggageCheckItem(
                        onTap: () => context
                            .push('/travel/${travel.id}/luggage'),
                        showLine: hasPrev && hasNext && scheduleIndices.length > 1,
                      );
                    }

                    final s = entry as Schedule;
                    final k = scheduleIndices.indexOf(i);
                    final isFirstSchedule = k == 0;
                    final isLastSchedule = k == scheduleIndices.length - 1;

                    return Stack(
                      children: [
                        // Vertical timeline line
                        if (scheduleIndices.length > 1)
                          Positioned(
                            left: 19, // center of 40px cover image
                            top: isFirstSchedule ? 20 : 0,
                            bottom: !isLastSchedule ? 0 : null,
                            height: isLastSchedule ? 20 : null,
                            child: Container(
                              width: 2,
                              color: AppColors.border,
                            ),
                          ),
                        ScheduleTimelineItem(
                          schedule: s,
                          travelStartDate: travel.startDate,
                          canEdit: _canEdit,
                          displayDay: selectedDay,
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

class _LuggageCheckItem extends StatelessWidget {
  const _LuggageCheckItem({
    required this.onTap,
    this.showLine = false,
  });
  final VoidCallback onTap;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
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

    if (!showLine) return card;

    return Stack(
      children: [
        Positioned(
          left: 19,
          top: 0,
          bottom: 0,
          child: Container(width: 2, color: AppColors.border),
        ),
        card,
      ],
    );
  }
}
