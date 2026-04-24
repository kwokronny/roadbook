// lib/features/schedule/presentation/schedule_list_panel.dart
// NOTE: 不含 Scaffold — FAB 由父级 TravelDetailScreen 管理
import 'dart:ui';
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
import '../../../shared/widgets/app_confirm_dialog.dart';
import 'schedule_edit_sheet.dart';
import 'schedule_quick_time_sheet.dart';
import '../../luggage/domain/luggage_provider.dart';
import '../../../shared/widgets/skeleton.dart';
import 'widgets/schedule_item_skeleton.dart';
import 'package:hugeicons/hugeicons.dart';

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

  bool get _isSelectionMode => ref.read(scheduleSelectionModeProvider(travel.id!));
  set _isSelectionModeValue(bool v) =>
      ref.read(scheduleSelectionModeProvider(travel.id!).notifier).state = v;

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
      if (_isCheckoutDay(s, selectedDay)) {
        result.add(const _LuggageMarker());
      }
      result.add(s);
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
      _isSelectionModeValue = true;
      _selectedIds.clear();
      _selectedIds.add(scheduleId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionModeValue = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionModeValue = false;
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
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '批量删除',
      message: '确定删除选中的 $count 个行程？',
      confirmLabel: '删除',
    );
    if (!confirmed) return;

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
    // Watch selection mode so UI rebuilds when it changes
    ref.watch(scheduleSelectionModeProvider(travel.id!));

    return Stack(
      children: [
        // ── Timeline list (full height, padded top for day bar)
        Positioned.fill(
          child: listAsync.when(
            loading: () => SkeletonLoader(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal, 76,
                    AppSpacing.pageHorizontal, 100),
                itemCount: 5,
                itemBuilder: (_, __) => const ScheduleItemSkeleton(),
              ),
            ),
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

              return Padding(
                padding: EdgeInsets.only(top: _isSelectionMode ? 68 : 0),
                child: Column(
                children: [
                  // ── Selection toolbar
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal, vertical: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.cover),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x99FFFFFF), // 60% white
                              borderRadius: BorderRadius.circular(AppRadius.cover),
                              border: Border.all(color: const Color(0xA6FFFFFF)),
                            ),
                        child: Row(
                          children: [
                            // Check all circle
                            GestureDetector(
                              onTap: () => _toggleSelectAll(items),
                              child: Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: allSelected ? AppColors.primary : Colors.transparent,
                                  border: allSelected ? null
                                      : Border.all(color: AppColors.inkTertiary, width: 2),
                                ),
                                child: allSelected
                                    ? const Icon(HugeIcons.strokeRoundedTick01, size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('已选 ${_selectedIds.length} 项',
                                style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                            const Spacer(),
                            // Move
                            GestureDetector(
                              onTap: _selectedIds.isNotEmpty ? _batchMove : null,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0x0F1C1C1E),
                                ),
                                child: Icon(HugeIcons.strokeRoundedMoveTo, size: 16,
                                    color: _selectedIds.isNotEmpty
                                        ? AppColors.inkSecondary : AppColors.textDisabled),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete
                            GestureDetector(
                              onTap: _selectedIds.isNotEmpty ? _batchDelete : null,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0x14FF3B30),
                                ),
                                child: Icon(HugeIcons.strokeRoundedDelete01, size: 16,
                                    color: _selectedIds.isNotEmpty
                                        ? AppColors.destructive : AppColors.textDisabled),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Close
                            GestureDetector(
                              onTap: _exitSelectionMode,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0x0F1C1C1E),
                                ),
                                child: const Icon(HugeIcons.strokeRoundedCancel01, size: 14,
                                    color: AppColors.inkSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                        ),
                      ),
                    ),

                  // ── List
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async =>
                          ref.invalidate(scheduleProvider(travel.id!)),
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            _isSelectionMode ? 8 : 76,
                            AppSpacing.pageHorizontal, 100),
                        itemCount: displayItems.length + 1,
                        itemBuilder: (context, i) {
                          if (i == displayItems.length) {
                            return const SizedBox(height: 16);
                          }

                          final entry = displayItems[i];

                          Widget child;
                          if (entry is _LuggageMarker) {
                            if (_isSelectionMode) return const SizedBox.shrink();
                            child = _LuggageCheckItemLive(
                              travelId: travel.id!,
                              onTap: () => context.push('/travel/${travel.id}/luggage'),
                            );
                          } else {

                          final s = entry as Schedule;
                          child = ScheduleTimelineItem(
                            schedule: s,
                            travelStartDate: travel.startDate,
                            canEdit: _canEdit,
                            displayDay: selectedDay,
                            isSelectionMode: _isSelectionMode,
                            isSelected: _selectedIds.contains(s.id),
                            isAbroad: travel.isAbroad,
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
                          }

                          // Stagger entrance animation
                          final delay = (i.clamp(0, 6)) * 50;
                          return _StaggerItem(
                            delay: Duration(milliseconds: delay),
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              );
            },
          ),
        ),
        // Day bar moved to TravelDetailScreen (shared with map)
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Schedule s) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '删除行程',
      message: '确定删除「${s.name}」？',
      confirmLabel: '删除',
    );
    if (confirmed) {
      await ref
          .read(scheduleProvider(travel.id!).notifier)
          .remove(s.id!);
    }
  }
}

class _LuggageCheckItemLive extends ConsumerWidget {
  const _LuggageCheckItemLive({required this.travelId, required this.onTap});
  final int travelId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final luggageAsync = ref.watch(luggageProvider(travelId));
    final checked = luggageAsync.valueOrNull?.checkedCount ?? 0;
    final total = luggageAsync.valueOrNull?.totalItems ?? 0;
    final progress = total > 0 ? checked / total : 0.0;

    return _LuggageCheckItem(
      onTap: onTap,
      checkedCount: checked,
      totalCount: total,
      progress: progress,
    );
  }
}

class _LuggageCheckItem extends StatelessWidget {
  const _LuggageCheckItem({
    required this.onTap,
    this.checkedCount = 0,
    this.totalCount = 0,
    this.progress = 0,
  });
  final VoidCallback onTap;
  final int checkedCount;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.scheduleGap),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: BackdropFilter(
            filter: GlassSpec.cardBlur,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x7AFFFFFF), // rgba(255,255,255,0.48)
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: const Color(0x99FFFFFF)), // 0.60
              ),
              child: Stack(
                children: [
                  // Specular
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          gradient: GlassSpec.specularHighlight,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Emoji icon box
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0x14FF6B3D), // rgba(255,107,61,0.08)
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x1FFF6B3D)), // 0.12
                        ),
                        child: const Center(
                          child: Text('🧳', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title + subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('出发行李清单',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500,
                                    color: AppColors.inkPrimary)),
                            const SizedBox(height: 2),
                            Text('$checkedCount/$totalCount 已准备',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.inkTertiary)),
                          ],
                        ),
                      ),
                      // Progress bar + chevron
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Track
                          Container(
                            width: 48, height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0x0F1C1C1E),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress.clamp(0, 1),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(HugeIcons.strokeRoundedArrowRight01,
                              size: 18, color: AppColors.inkTertiary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stagger entrance animation ──────────────────────────────────────────────

class _StaggerItem extends StatefulWidget {
  const _StaggerItem({required this.delay, required this.child});
  final Duration delay;
  final Widget child;

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: const Cubic(0.22, 1.0, 0.36, 1.0), // expressive
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
