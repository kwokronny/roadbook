// lib/features/travel/presentation/travel_list_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

import '../domain/travel_list_provider.dart';
import '../../luggage/domain/luggage_provider.dart';
import '../../../shared/widgets/app_confirm_dialog.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/skeleton.dart';
import 'widgets/join_travel_sheet.dart';
import 'widgets/travel_card.dart';
import 'widgets/travel_card_skeleton.dart';
import 'widgets/travel_form_sheet.dart';
import 'package:hugeicons/hugeicons.dart';

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
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '删除旅程',
      message: '确定删除「$name」？此操作无法撤销。',
      confirmLabel: '删除',
    );
    if (!confirmed) return;

    try {
      await ref.read(travelRepositoryProvider).remove(travelId);
      ref.read(travelListProvider.notifier).remove(travelId);
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(travelListProvider);

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ── Large Title + Join + Add buttons ──────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, topPad + 20, AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  const Text('旅程', style: AppTextStyles.largeTitle),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => JoinTravelSheet.show(context),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                            color: AppColors.inkPrimary, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(HugeIcons.strokeRoundedUserAdd01,
                              size: 16, color: AppColors.inkPrimary),
                          SizedBox(width: 5),
                          Text('加入',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkPrimary,
                                height: 1.0,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => TravelFormSheet.show(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.darkPill,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(HugeIcons.strokeRoundedAdd01, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Glass search bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: _GlassSearchBar(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 12),

            // ── Travel list ──────────────────────────────────────────────
            Expanded(
              child: listAsync.when(
                loading: () => SkeletonLoader(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal, 12,
                        AppSpacing.pageHorizontal, 100),
                    itemCount: 4,
                    itemBuilder: (_, __) => const TravelCardSkeleton(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.toString(), style: AppTextStyles.caption),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () => ref.read(travelListProvider.notifier).refresh(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(HugeIcons.strokeRoundedMaps, size: 48,
                              color: AppColors.textTertiary),
                          SizedBox(height: 12),
                          Text('暂无旅程，点击 ＋ 开始规划',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref.read(travelListProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal, 12,
                          AppSpacing.pageHorizontal, 100),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator(color: AppColors.primary)),
                          );
                        }
                        final travel = state.items[index];
                        return Consumer(builder: (_, ref, __) {
                          final luggage = travel.id != null
                              ? ref.watch(luggageProvider(travel.id!)).valueOrNull
                              : null;
                          return TravelCard(
                            travel: travel,
                            luggageChecked: luggage?.checkedCount ?? 0,
                            luggageTotal: luggage?.totalItems ?? 0,
                            onTap: () => context.go('/travel/${travel.id}'),
                            onEdit: () => TravelFormSheet.show(context, travel: travel),
                            onDelete: travel.id != null
                                ? () => _confirmDelete(travel.id!, travel.name)
                                : null,
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
      ),
    );
  }
}

// ─── Glass search bar ───────────────────────────────────────────────────────

class _GlassSearchBar extends StatelessWidget {
  const _GlassSearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.cover),
      child: BackdropFilter(
        filter: GlassSpec.inputBlur,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: GlassSpec.inputBg,
            borderRadius: BorderRadius.circular(AppRadius.cover),
            border: Border.all(color: GlassSpec.inputBorder, width: 1),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(HugeIcons.strokeRoundedSearch01, size: 18, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: '搜索旅行计划...',
                    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) => AnimatedOpacity(
                  opacity: value.text.isNotEmpty ? 1.0 : 0.0,
                  duration: AppAnimations.fast,
                  child: GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(HugeIcons.strokeRoundedCancel01, size: 14, color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
