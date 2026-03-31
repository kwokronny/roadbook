// lib/features/travel/presentation/travel_detail_screen.dart
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

class TravelDetailScreen extends ConsumerStatefulWidget {
  const TravelDetailScreen({super.key, required this.travelId});
  final int travelId;

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen> {
  int _currentTab = 0;
  bool _initialDaySet = false;

  void _setInitialDay(Travel travel) {
    if (_initialDaySet) return;
    _initialDaySet = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
        travel.startDate.year, travel.startDate.month, travel.startDate.day);
    final end = DateTime(
        travel.endDate.year, travel.endDate.month, travel.endDate.day);
    if (!today.isBefore(start) && !today.isAfter(end)) {
      final day = today.difference(start).inDays + 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedDayProvider(widget.travelId).notifier).state = day;
          ref.read(mapSelectedDayProvider(widget.travelId).notifier).state = day;
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
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString(), style: AppTextStyles.caption)),
      ),
      data: (travel) {
        _setInitialDay(travel);
        return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(travel.name, style: AppTextStyles.appBarTitle),
              if (travel.cities.isNotEmpty)
                Text(
                  travel.cities.join(' · '),
                  style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          actions: [
            _buildViewToggle(),
            _buildMoreMenu(context, travel: travel, canEdit: canEdit, canManage: canManage),
          ],
        ),
        floatingActionButton: (_currentTab == 0 && canEdit)
            ? _buildFab(context, travel)
            : null,
        body: IndexedStack(
          index: _currentTab,
          children: [
            ScheduleListPanel(travel: travel, perm: perm),
            MapTabView(travelId: widget.travelId),
          ],
        ),
      );
      },
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleIcon(Icons.format_list_bulleted, 0),
          _toggleIcon(Icons.map_outlined, 1),
        ],
      ),
    );
  }

  Widget _toggleIcon(IconData icon, int index) {
    final selected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 22,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context, {required Travel travel, required bool canEdit, required bool canManage}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 22),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      color: AppColors.surface,
      elevation: 4,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            TravelFormSheet.show(context, travel: travel);
          case 'collaborator':
            CollaboratorSheet.show(context, widget.travelId);
          case 'import':
            CollectImportSheet.show(context, widget.travelId);
          case 'luggage':
            context.push('/travel/${widget.travelId}/luggage');
        }
      },
      itemBuilder: (_) => [
        if (canManage)
          const PopupMenuItem(
            value: 'edit',
            height: 44,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('编辑旅程'),
            ]),
          ),
        if (canManage)
          const PopupMenuItem(
            value: 'collaborator',
            height: 44,
            child: Row(children: [
              Icon(Icons.group_outlined, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('协作者管理'),
            ]),
          ),
        if (canEdit)
          const PopupMenuItem(
            value: 'import',
            height: 44,
            child: Row(children: [
              Icon(Icons.download_outlined, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('批量导入'),
            ]),
          ),
        const PopupMenuItem(
          value: 'luggage',
          height: 44,
          child: Row(children: [
            Icon(Icons.luggage_outlined,
                size: 18, color: AppColors.textPrimary),
            SizedBox(width: 10),
            Text('行李清单'),
          ]),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, Travel travel) {
    return FloatingActionButton(
      onPressed: () {
        setState(() => _currentTab = 1);
        ref
            .read(mapStateProvider(widget.travelId).notifier)
            .enterSearchMode();
      },
      backgroundColor: AppColors.primary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
