// lib/core/constants.dart
class AppConstants {
  AppConstants._();

  /// 替换为实际后端地址，也可通过 --dart-define=API_BASE_URL=xxx 注入
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
