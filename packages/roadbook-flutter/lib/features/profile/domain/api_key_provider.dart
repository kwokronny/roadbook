// lib/features/profile/domain/api_key_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/api_key.dart';
import '../../../shared/providers/dio_provider.dart';
import '../data/api_key_repository.dart';

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  return ApiKeyRepository(ref.watch(dioProvider));
});

final apiKeyListProvider =
    AutoDisposeAsyncNotifierProvider<ApiKeyListNotifier, List<ApiKey>>(
  ApiKeyListNotifier.new,
);

class ApiKeyListNotifier extends AutoDisposeAsyncNotifier<List<ApiKey>> {
  @override
  Future<List<ApiKey>> build() async {
    return ref.read(apiKeyRepositoryProvider).list();
  }

  Future<ApiKey> create(String name) async {
    final newKey = await ref.read(apiKeyRepositoryProvider).create(name);
    final current = state.valueOrNull ?? [];
    state = AsyncData([newKey, ...current]);
    return newKey;
  }

  Future<void> remove(int id) async {
    await ref.read(apiKeyRepositoryProvider).remove(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((k) => k.id != id).toList());
  }
}
