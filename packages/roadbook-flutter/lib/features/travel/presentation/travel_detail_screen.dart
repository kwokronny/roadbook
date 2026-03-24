// lib/features/travel/presentation/travel_detail_screen.dart
// ConsumerStatefulWidget with TabController — FAB 托管在此 Scaffold，避免嵌套 Scaffold 问题
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/user_travel.dart';
import '../domain/travel_detail_provider.dart';
import 'widgets/travel_form_sheet.dart';
import 'widgets/collaborator_sheet.dart';
import '../../../features/schedule/presentation/schedule_list_panel.dart';
import '../../../features/schedule/presentation/schedule_edit_sheet.dart';
import '../../../features/schedule/domain/schedule_provider.dart';
import '../../schedule/presentation/collect_import_sheet.dart';
import 'map/map_tab_view.dart';

class TravelDetailScreen extends ConsumerStatefulWidget {
  const TravelDetailScreen({super.key, required this.travelId});
  final int travelId;

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging && mounted) {
        setState(() => _currentTab = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
      data: (travel) => Scaffold(
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
            if (canManage)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: '编辑旅程信息',
                onPressed: () => TravelFormSheet.show(context, travel: travel),
              ),
            if (canManage)
              IconButton(
                icon: const Icon(Icons.group_outlined, size: 20),
                tooltip: '协作者管理',
                onPressed: () => CollaboratorSheet.show(context, widget.travelId),
              ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                tooltip: '批量导入',
                onPressed: () => CollectImportSheet.show(context, widget.travelId),
              ),
          ],
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(icon: Icon(Icons.map_outlined), text: '地图'),
              Tab(icon: Icon(Icons.format_list_bulleted), text: '行程'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        // FAB 仅在行程 Tab（index=1）且有编辑权限时显示
        floatingActionButton: (_currentTab == 1 && canEdit)
            ? _buildFab(context, travel)
            : null,
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── 地图 Tab
            MapTabView(travelId: widget.travelId),
            // ── 行程 Tab（无 Scaffold）
            ScheduleListPanel(travel: travel, perm: perm),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context, Travel travel) {
    final selectedDay = ref.watch(selectedDayProvider(widget.travelId));
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.fab),
      ),
      child: FloatingActionButton(
        onPressed: () => ScheduleEditSheet.show(
          context,
          travel: travel,
          initialDay: selectedDay == 0 ? null : selectedDay,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
