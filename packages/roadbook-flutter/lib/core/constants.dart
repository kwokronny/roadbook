// lib/core/constants.dart
class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static const String amapWebKey = String.fromEnvironment('AMAP_WEB_KEY');

  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY');
  
}
