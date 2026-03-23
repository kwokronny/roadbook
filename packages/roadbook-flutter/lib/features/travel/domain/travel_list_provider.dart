import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/travel_repository.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/providers/dio_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final travelRepositoryProvider = Provider.autoDispose<TravelRepository>((ref) {
  return TravelRepository(ref.watch(dioProvider)); // watch, not read
});

// ─── State ───────────────────────────────────────────────────────────────────

class TravelListState {
  const TravelListState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.keyword,
  });

  final List<Travel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String keyword;

  TravelListState copyWith({
    List<Travel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? keyword,
  }) =>
      TravelListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        keyword: keyword ?? this.keyword,
      );
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class TravelListNotifier extends AutoDisposeAsyncNotifier<TravelListState> {
  // Stored separately so refresh() can retrieve it even when state is AsyncError
  String _keyword = '';

  @override
  Future<TravelListState> build() => _fetch(page: 1, keyword: '', previous: null);

  Future<TravelListState> _fetch({
    required int page,
    required String keyword,
    required TravelListState? previous,
  }) async {
    final result = await ref
        .read(travelRepositoryProvider)
        .page(page: page, keyword: keyword);

    final newItems = page == 1
        ? result.travels
        : <Travel>[...(previous?.items ?? []), ...result.travels];

    _keyword = keyword; // keep in sync for refresh() to use even on error
    return TravelListState(
      items: newItems,
      page: page,
      hasMore: result.hasMore,
      isLoadingMore: false,
      keyword: keyword,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(page: 1, keyword: _keyword, previous: null),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    try {
      final next = await _fetch(page: nextPage, keyword: current.keyword, previous: current);
      state = AsyncData(next);
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> setKeyword(String keyword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(page: 1, keyword: keyword, previous: null),
    );
  }

  /// Optimistically insert/replace travel at head of list after create/edit
  void upsert(Travel travel) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: [travel, ...current.items.where((t) => t.id != travel.id)],
    ));
  }

  /// Optimistically remove travel from list after delete
  void remove(int id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(items: current.items.where((t) => t.id != id).toList()),
    );
  }
}

final travelListProvider =
    AsyncNotifierProvider.autoDispose<TravelListNotifier, TravelListState>(
  TravelListNotifier.new,
);
