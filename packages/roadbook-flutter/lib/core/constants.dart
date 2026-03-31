// lib/core/constants.dart
class AppConstants {
  AppConstants._();

  /// 替换为实际后端地址，也可通过 --dart-define=API_BASE_URL=xxx 注入
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.51.4:3000',
  );

  /// 高德地图 Web 服务 API Key，通过 --dart-define=AMAP_WEB_KEY=xxx 注入
  static const String amapWebKey = String.fromEnvironment(
    'AMAP_WEB_KEY',
    defaultValue: 'e2181e83a62c299dc8a3cdc4ba1ee9b1',
  );
}
