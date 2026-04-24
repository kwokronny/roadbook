// lib/features/discover/presentation/discover_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';

import '../domain/discover_provider.dart';
import 'widgets/public_travel_card.dart';
import 'package:hugeicons/hugeicons.dart';

const _cities = ['热门', '日本', '泰国', '韩国', '欧洲', '东南亚', '国内'];

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;
  int _selectedCityIdx = 0; // 0 = 热门

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _searchCtrl.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchTextChanged);
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged() => setState(() {});

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(discoverProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(discoverProvider.notifier).search(value);
    });
  }

  void _selectCity(int idx) {
    setState(() => _selectedCityIdx = idx);
    _searchCtrl.clear();
    final city = idx == 0 ? null : _cities[idx];
    ref.read(discoverProvider.notifier).selectCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(discoverProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Title
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 12,
                  AppSpacing.pageHorizontal, 0),
              child: Text('发现', style: AppTextStyles.largeTitle),
            ),
            // 搜索栏
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 8,
                  AppSpacing.pageHorizontal, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '搜索旅程、目的地',
                  hintStyle: const TextStyle(
                      fontSize: 15, color: AppColors.textSecondary),
                  prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01,
                      size: 18, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(HugeIcons.strokeRoundedCancel01,
                              size: 14, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(discoverProvider.notifier).search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: GlassSpec.inputOnGlassBg,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            // 城市 Chip 横向滚动
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal, vertical: 4),
                itemCount: _cities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, idx) {
                  final active = idx == _selectedCityIdx;
                  return GestureDetector(
                    onTap: () => _selectCity(idx),
                    child: AnimatedContainer(
                      duration: AppAnimations.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.coralTint
                            : const Color(0x0D1C1C1E),
                        border: Border.all(
                          color: active
                              ? const Color(0x2EFF6B3D) // rgba(255,107,61,0.18)
                              : const Color(0x0F1C1C1E), // rgba(28,28,30,0.06)
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _cities[idx],
                        style: TextStyle(
                          fontSize: 12,
                          color: active
                              ? const Color(0xFFD4410A)
                              : AppColors.inkSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 旅程列表
            Expanded(
              child: asyncState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(HugeIcons.strokeRoundedWifiOff01,
                          size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 8),
                      Text('$e',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(discoverProvider),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (state) {
                  if (state.travels.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(HugeIcons.strokeRoundedMapsGlobal01,
                              size: 48,
                              color: AppColors.textTertiary),
                          SizedBox(height: 8),
                          Text('暂无公开旅程',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(discoverProvider.notifier)
                            .selectCity(state.selectedCity),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: state.travels.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, idx) {
                        if (idx == state.travels.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          );
                        }
                        return PublicTravelCard(
                            travel: state.travels[idx]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
