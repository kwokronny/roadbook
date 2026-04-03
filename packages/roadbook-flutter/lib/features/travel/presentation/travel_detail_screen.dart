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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(travel.name, style: AppTextStyles.headline),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x80FFFFFF),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0xCCFFFFFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toggleIcon(Icons.format_list_bulleted, 0),
                _toggleIcon(Icons.map_outlined, 1),
              ],
            ),
          ),
        ),
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
          borderRadius: BorderRadius.circular(AppRadius.pill),
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
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x80FFFFFF),
          border: Border.all(color: const Color(0xCCFFFFFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x146478B4), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.more_horiz, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildFab(BuildContext context, Travel travel) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x40FF5B2E), blurRadius: 16, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x20FF5B2E), blurRadius: 4, offset: Offset(0, 1)),
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
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
