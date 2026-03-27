// lib/features/discover/domain/discover_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/models/public_travel.dart';
import '../data/discover_repository.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final discoverRepositoryProvider = Provider.autoDispose<DiscoverRepository>((ref) {
  return DiscoverRepository(ref.watch(dioProvider));
});

// ─── State ──────────────────────────────────────────────────────────────────

class DiscoverState {
  const DiscoverState({
    required this.travels,
    required this.hasMore,
    required this.isLoadingMore,
    this.selectedCity,
    this.keyword = '',
    this.page = 1,
  });

  final List<PublicTravel> travels;
  final bool hasMore;
  final bool isLoadingMore;
  final String? selectedCity;
  final String keyword;
  final int page;

  DiscoverState copyWith({
    List<PublicTravel>? travels,
    bool? hasMore,
    bool? isLoadingMore,
    Object? selectedCity = _sentinel,
    String? keyword,
    int? page,
  }) =>
      DiscoverState(
        travels: travels ?? this.travels,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        selectedCity: selectedCity == _sentinel
            ? this.selectedCity
            : selectedCity as String?,
        keyword: keyword ?? this.keyword,
        page: page ?? this.page,
      );
}

const _sentinel = Object();

// ─── Notifier ────────────────────────────────────────────────────────────────

class DiscoverNotifier extends AutoDisposeAsyncNotifier<DiscoverState> {
  @override
  Future<DiscoverState> build() => _load(page: 1);

  Future<DiscoverState> _load({
    required int page,
    String? city,
    String? keyword,
  }) async {
    final repo = ref.read(discoverRepositoryProvider);
    final result = await repo.discover(page: page, city: city, keyword: keyword);
    return DiscoverState(
      travels: result.travels,
      hasMore: result.hasMore,
      isLoadingMore: false,
      selectedCity: city,
      keyword: keyword ?? '',
      page: page,
    );
  }

  Future<void> selectCity(String? city) async {
    final currentKeyword = state.valueOrNull?.keyword ?? '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(page: 1, city: city, keyword: currentKeyword.isEmpty ? null : currentKeyword),
    );
  }

  Future<void> search(String keyword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _load(page: 1, keyword: keyword.isEmpty ? null : keyword));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(discoverRepositoryProvider);
      final nextPage = current.page + 1;
      final result = await repo.discover(
        page: nextPage,
        city: current.keyword.isEmpty ? current.selectedCity : null,
        keyword: current.keyword.isEmpty ? null : current.keyword,
      );
      // Guard: discard if state changed during the await
      final afterAwait = state.valueOrNull;
      if (afterAwait == null || afterAwait.page != current.page || afterAwait.keyword != current.keyword) return;
      state = AsyncData(current.copyWith(
        travels: [...current.travels, ...result.travels],
        hasMore: result.hasMore,
        isLoadingMore: false,
        page: nextPage,
      ));
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      // ignore: use_rethrow_when_possible
      Error.throwWithStackTrace(e, st);
    }
  }
}

final discoverProvider =
    AsyncNotifierProvider.autoDispose<DiscoverNotifier, DiscoverState>(
  DiscoverNotifier.new,
);
