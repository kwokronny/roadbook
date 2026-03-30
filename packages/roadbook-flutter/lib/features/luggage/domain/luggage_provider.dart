import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/luggage_repository.dart';
import '../../../shared/constants/luggage_presets.dart';
import '../../../shared/models/luggage.dart';
import '../../../shared/models/user_travel.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../travel/domain/travel_detail_provider.dart';

export '../../../shared/constants/luggage_presets.dart' show LuggageSeason;

const _uuid = Uuid();

// ─── Repository Provider ──────────────────────────────────────────────────────

final luggageRepositoryProvider = Provider<LuggageRepository>((ref) {
  return LuggageRepository(ref.watch(dioProvider));
});

// ─── State ────────────────────────────────────────────────────────────────────

class LuggageState {
  const LuggageState({
    required this.categories,
    required this.checkedIds,
    required this.isSaving,
    required this.canEdit,
    this.errorMessage,
  });

  final List<LuggageCategory> categories;
  final Set<String> checkedIds;
  final bool isSaving;
  final bool canEdit;
  final String? errorMessage;

  int get totalItems => categories.fold(0, (s, c) => s + c.items.length);
  int get checkedCount => checkedIds.length;

  LuggageState copyWith({
    List<LuggageCategory>? categories,
    Set<String>? checkedIds,
    bool? isSaving,
    bool? canEdit,
    Object? errorMessage = _sentinel,
  }) =>
      LuggageState(
        categories: categories ?? this.categories,
        checkedIds: checkedIds ?? this.checkedIds,
        isSaving: isSaving ?? this.isSaving,
        canEdit: canEdit ?? this.canEdit,
        errorMessage: errorMessage == _sentinel
            ? this.errorMessage
            : errorMessage as String?,
      );
}

const _sentinel = Object();

// ─── Notifier ─────────────────────────────────────────────────────────────────

final luggageProvider = AsyncNotifierProvider.autoDispose
    .family<LuggageNotifier, LuggageState, int>(LuggageNotifier.new);

class LuggageNotifier
    extends AutoDisposeFamilyAsyncNotifier<LuggageState, int> {
  @override
  Future<LuggageState> build(int arg) async {
    final travel = await ref.watch(travelDetailProvider(arg).future);
    final authUser = ref.read(authStateProvider).valueOrNull?.user;

    final role = () {
      if (authUser == null) return RoleType.view;
      final match =
          travel.collaborators.where((c) => c.user.id == authUser.id);
      return match.isEmpty ? RoleType.view : match.first.role;
    }();
    final canEdit = role == RoleType.manage || role == RoleType.edit;

    List<LuggageCategory> cats;
    final raw = travel.equip;
    if (raw != null && raw.isNotEmpty) {
      try {
        cats = (jsonDecode(raw) as List<dynamic>)
            .map((e) =>
                LuggageCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        cats = [];
      }
    } else {
      cats = [];
    }

    return LuggageState(
      categories: cats,
      checkedIds: const {},
      isSaving: false,
      canEdit: canEdit,
    );
  }

  // ── Local-only ────────────────────────────────────────────────────────────

  void toggleCheck(String itemId) {
    final current = state.valueOrNull;
    if (current == null) return;
    final checked = Set<String>.from(current.checkedIds);
    if (checked.contains(itemId)) {
      checked.remove(itemId);
    } else {
      checked.add(itemId);
    }
    state = AsyncData(current.copyWith(checkedIds: checked));
  }

  // ── Persistent mutations ──────────────────────────────────────────────────

  Future<void> addCategory(String name) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final previous = current.categories;
    final newCat = LuggageCategory(
      id: _uuid.v4(),
      name: name,
      emoji: '📦',
      items: const [],
    );
    final updated = [...current.categories, newCat];
    state = AsyncData(current.copyWith(categories: updated));
    await _save(updated, previous);
  }

  Future<void> deleteCategory(String catId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final previous = current.categories;
    final updated =
        current.categories.where((c) => c.id != catId).toList();
    state = AsyncData(current.copyWith(categories: updated));
    await _save(updated, previous);
  }

  Future<void> addItems(String catId, List<String> texts) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final previous = current.categories;
    final updated = current.categories.map((c) {
      if (c.id != catId) return c;
      final newItems =
          texts.map((t) => LuggageItem(id: _uuid.v4(), text: t)).toList();
      return c.copyWith(items: [...c.items, ...newItems]);
    }).toList();
    state = AsyncData(current.copyWith(categories: updated));
    await _save(updated, previous);
  }

  Future<void> deleteItem(String catId, String itemId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final previous = current.categories;
    final updated = current.categories.map((c) {
      if (c.id != catId) return c;
      return c.copyWith(
          items: c.items.where((i) => i.id != itemId).toList());
    }).toList();
    state = AsyncData(current.copyWith(categories: updated));
    await _save(updated, previous);
  }

  /// Merges season template into current categories.
  /// Returns count of newly added items.
  Future<int> importTemplate(LuggageSeason season) async {
    final current = state.valueOrNull;
    if (current == null) return 0;

    final previous = current.categories;
    final template = seasonTemplate(season);
    final cats = List<LuggageCategory>.from(current.categories);
    int addedCount = 0;

    for (final tplCat in template) {
      final existingIdx = cats.indexWhere((c) => c.name == tplCat.name);
      if (existingIdx >= 0) {
        final existing = cats[existingIdx];
        final existingTexts =
            existing.items.map((i) => i.text).toSet();
        final newItems = tplCat.items
            .where((i) => !existingTexts.contains(i.text))
            .toList();
        addedCount += newItems.length;
        cats[existingIdx] =
            existing.copyWith(items: [...existing.items, ...newItems]);
      } else {
        cats.add(tplCat);
        addedCount += tplCat.items.length;
      }
    }

    state = AsyncData(current.copyWith(categories: cats));
    await _save(cats, previous);
    return addedCount;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _save(
      List<LuggageCategory> categories,
      List<LuggageCategory> previousCategories,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isSaving: true, errorMessage: null));
    try {
      final json =
          jsonEncode(categories.map((c) => c.toJson()).toList());
      await ref
          .read(luggageRepositoryProvider)
          .setEquip(travelId: arg, equip: json);
      final after = state.valueOrNull;
      if (after != null) {
        state = AsyncData(after.copyWith(isSaving: false));
      }
    } catch (e) {
      final after = state.valueOrNull;
      if (after != null) {
        state = AsyncData(after.copyWith(
          categories: previousCategories,
          isSaving: false,
          errorMessage: e.toString(),
        ));
      }
      rethrow;
    }
  }
}
