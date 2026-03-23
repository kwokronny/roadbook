// lib/shared/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../api/dio_client.dart';
import 'auth_state_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final authNotifier = ref.read(authStateProvider.notifier);

  return DioClientFactory.create(
    baseUrl: AppConstants.apiBaseUrl,
    // 每次请求时 lazy 读取当前 token，不需要 rebuild Dio
    tokenProvider: () => ref.read(authStateProvider).valueOrNull?.token,
    onUnauthorized: () => authNotifier.logout(),
  );
});
