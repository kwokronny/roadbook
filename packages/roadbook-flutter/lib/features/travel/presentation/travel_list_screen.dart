// lib/features/travel/presentation/travel_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../domain/travel_list_provider.dart';
import 'widgets/travel_card.dart';
import 'widgets/travel_form_sheet.dart';

class TravelListScreen extends ConsumerStatefulWidget {
  const TravelListScreen({super.key});

  @override
  ConsumerState<TravelListScreen> createState() => _TravelListScreenState();
}

class _TravelListScreenState extends ConsumerState<TravelListScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(travelListProvider).valueOrNull;
    if (state == null || !state.hasMore || state.isLoadingMore) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(travelListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(travelListProvider.notifier).setKeyword(value.trim());
    });
  }

  Future<void> _confirmDelete(int travelId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除旅程'),
        content: Text('确定删除「$name」？此操作无法撤销。'),
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
    if (confirmed != true) return;

    try {
      await ref.read(travelRepositoryProvider).remove(travelId);
      ref.read(travelListProvider.notifier).remove(travelId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final listAsync = ref.watch(travelListProvider);

    final userInfo = authAsync.valueOrNull?.user;
    final avatar = userInfo?.avatar;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text('我的旅程', style: AppTextStyles.pageHeroTitle),
                  ),
                  // User avatar menu
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await ref.read(authStateProvider.notifier).logout();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('功能开发中')));
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'profile', child: Text('编辑资料')),
                      PopupMenuItem(value: 'password', child: Text('修改密码')),
                      PopupMenuDivider(),
                      PopupMenuItem(
                          value: 'logout',
                          child: Text('退出登录',
                              style: TextStyle(color: Colors.red))),
                    ],
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient:
                            avatar == null ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(12),
                        image: avatar != null
                            ? DecorationImage(
                                image: NetworkImage(avatar),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatar == null
                          ? Center(
                              child: Text(
                                (userInfo?.username ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── Search bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '搜索旅程名称…',
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ─── Travel list ─────────────────────────────────────────
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
                            ref.read(travelListProvider.notifier).refresh(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text('暂无旅程，点击 ＋ 开始规划',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    );
                  }

                  // Check for ongoing travels
                  final ongoingTravels = state.items
                      .where((t) =>
                          computeTravelStatus(t.startDate, t.endDate) ==
                          TravelStatus.ongoing)
                      .toList();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(travelListProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal, vertical: 4),
                      // +1 for ongoing banner, +1 for loading indicator
                      itemCount: (ongoingTravels.isNotEmpty ? 1 : 0) +
                          state.items.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Ongoing banner always at top
                        if (ongoingTravels.isNotEmpty && index == 0) {
                          return _OngoingBanner(travels: ongoingTravels);
                        }
                        final adjustedIndex =
                            index - (ongoingTravels.isNotEmpty ? 1 : 0);

                        if (adjustedIndex == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary)),
                          );
                        }

                        final travel = state.items[adjustedIndex];
                        return TravelCard(
                          travel: travel,
                          onTap: () => context.go('/travel/${travel.id}'),
                          onEdit: () =>
                              TravelFormSheet.show(context, travel: travel),
                          onDelete: travel.id != null
                              ? () => _confirmDelete(travel.id!, travel.name)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FAB (gradient background)
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
        child: FloatingActionButton(
          onPressed: () => TravelFormSheet.show(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Ongoing banner (§10.8) ──────────────────────────────────────────────────

class _OngoingBanner extends StatelessWidget {
  const _OngoingBanner({required this.travels});
  final List<Travel> travels;

  @override
  Widget build(BuildContext context) {
    final names = travels.map((t) => t.name).join('、');
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.flight_takeoff, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '旅行中：$names',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
