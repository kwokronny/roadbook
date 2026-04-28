// lib/features/travel/presentation/travel_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/user_travel.dart';
import '../domain/travel_detail_provider.dart';
import 'widgets/travel_form_sheet.dart';
import 'widgets/collaborator_sheet.dart';
import '../../../features/schedule/presentation/schedule_list_panel.dart';
import '../../../features/schedule/domain/schedule_provider.dart';
import '../../schedule/presentation/collect_import_sheet.dart';
import 'map/map_tab_view.dart';
import 'map/map_state_notifier.dart';
import '../../../features/schedule/presentation/widgets/day_sidebar.dart';
import '../../../shared/widgets/pastel_mesh_background.dart';
import '../../../shared/widgets/glass_popover.dart';
import 'package:hugeicons/hugeicons.dart';

class TravelDetailScreen extends ConsumerStatefulWidget {
  const TravelDetailScreen({super.key, required this.travelId});
  final int travelId;

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen> {
  int _currentTab = 0;
  bool _initialDaySet = false;

  int _totalDays(Travel t) => t.endDate.difference(t.startDate).inDays + 1;

  void _setInitialDay(Travel travel) {
    if (_initialDaySet) return;
    _initialDaySet = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
        travel.startDate.year, travel.startDate.month, travel.startDate.day);
    final end =
        DateTime(travel.endDate.year, travel.endDate.month, travel.endDate.day);
    if (!today.isBefore(start) && !today.isAfter(end)) {
      final day = today.difference(start).inDays + 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedDayProvider(widget.travelId).notifier).state = day;
          ref.read(mapSelectedDayProvider(widget.travelId).notifier).state =
              day;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final perm = ref.watch(travelPermProvider(widget.travelId));
    final canEdit = perm == RoleType.manage || perm == RoleType.edit;
    final canManage = perm == RoleType.manage;

    return travelAsync.when(
      loading: () => const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString(), style: AppTextStyles.caption)),
      ),
      data: (travel) {
        _setInitialDay(travel);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.pageHorizontal),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.darkPill,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(HugeIcons.strokeRoundedArrowLeft01,
                        size: 22, color: Colors.white),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(travel.name,
                    style: AppTextStyles.headline.copyWith(fontSize: 16)),
                if (travel.cities.isNotEmpty)
                  Text(
                    travel.cities.join(' · '),
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
              ],
            ),
            actions: [
              _buildViewToggle(),
              _buildMoreMenu(context,
                  travel: travel, canEdit: canEdit, canManage: canManage),
            ],
          ),
          floatingActionButton:
              (_currentTab == 0 && canEdit) ? _buildFab(context, travel) : null,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentTab,
                children: [
                  ScheduleListPanel(travel: travel, perm: perm),
                  MapTabView(travelId: widget.travelId),
                ],
              ),
              // ── Floating Day bar (shared across list & map)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: DayBar(
                  totalDays: _totalDays(travel),
                  selectedDay: ref.watch(selectedDayProvider(widget.travelId)),
                  travelStartDate: travel.startDate,
                  enabled: !ref.watch(scheduleSelectionModeProvider(widget.travelId)),
                  onDaySelected: (d) {
                    ref
                        .read(selectedDayProvider(widget.travelId).notifier)
                        .state = d;
                    ref
                        .read(mapSelectedDayProvider(widget.travelId).notifier)
                        .state = d == 0 ? -1 : d;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _dotSize = 30.0;
  static const _pad = 3.0;
  static const _trackH = _dotSize + _pad * 2; // 36
  static const _trackW = _dotSize * 2 + _pad * 3; // 69

  Widget _buildViewToggle() {
    return Container(
      width: _trackW,
      height: _trackH,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: const Color(0x0F1C1C1E),
        borderRadius: BorderRadius.circular(_trackH),
      ),
      child: Stack(
        children: [
          // Sliding dark circle
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: const Cubic(0.34, 1.3, 0.64, 1.0),
            left: _pad + _currentTab * (_dotSize + _pad),
            top: _pad,
            child: Container(
              width: _dotSize,
              height: _dotSize,
              decoration: const BoxDecoration(
                color: AppColors.darkPill,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Tappable icons — each centered over its dot position
          Row(
            children: [
              SizedBox(width: _pad), // left edge padding
              _buildToggleTab(HugeIcons.strokeRoundedLeftToRightListBullet, 0),
              SizedBox(width: _pad), // gap between
              _buildToggleTab(HugeIcons.strokeRoundedMaps, 1),
              SizedBox(width: _pad), // right edge padding
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab(IconData icon, int index) {
    final selected = _currentTab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentTab = index),
      child: SizedBox(
        width: _dotSize,
        height: _trackH,
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : AppColors.inkTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context,
      {required Travel travel,
      required bool canEdit,
      required bool canManage}) {
    return Builder(builder: (ctx) {
      return GestureDetector(
        onTap: () {
          final box = ctx.findRenderObject() as RenderBox;
          final pos = box.localToGlobal(Offset.zero);
          showGlassPopover(
            context: ctx,
            position: RelativeRect.fromLTRB(pos.dx, pos.dy + 36,
                MediaQuery.of(ctx).size.width - pos.dx - box.size.width, 0),
            items: [
              if (canManage)
                PopoverItem(
                    icon: HugeIcons.strokeRoundedEdit01,
                    label: '编辑旅程',
                    onTap: () => TravelFormSheet.show(context, travel: travel)),
              if (canManage)
                PopoverItem(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    label: '协作者',
                    onTap: () =>
                        CollaboratorSheet.show(context, widget.travelId)),
              if (canEdit && !travel.isAbroad)
                PopoverItem(
                    icon: HugeIcons.strokeRoundedDownload01,
                    label: '批量导入',
                    onTap: () =>
                        CollectImportSheet.show(context, widget.travelId)),
              PopoverItem(
                  icon: HugeIcons.strokeRoundedLuggage01,
                  label: '行李清点',
                  onTap: () =>
                      context.push('/travel/${widget.travelId}/luggage')),
            ],
          );
        },
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: AppSpacing.pageHorizontal),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkPill,
          ),
          child: const Icon(HugeIcons.strokeRoundedMoreVertical, size: 18, color: Colors.white),
        ),
      );
    });
  }

  Widget _buildFab(BuildContext context, Travel travel) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Color(0x4DFF6B3D), blurRadius: 16, offset: Offset(0, 4)),
          BoxShadow(
              color: Color(0x20FF6B3D), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          setState(() => _currentTab = 1);
          ref
              .read(mapStateProvider(widget.travelId).notifier)
              .enterSearchMode();
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(HugeIcons.strokeRoundedAdd01, size: 22, color: Colors.white),
      ),
    );
  }
}
