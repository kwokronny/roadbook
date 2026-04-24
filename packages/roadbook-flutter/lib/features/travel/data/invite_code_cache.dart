// lib/features/travel/data/invite_code_cache.dart
// In-memory map of shortCode → full JWT so manual code input on the same
// device can resolve to the token required by the accept API. JWT itself
// expires in 7 days; there is no need to persist across app restarts.
class InviteCodeCache {
  InviteCodeCache._();

  static final Map<String, String> _cache = {};

  /// First 4 alphanumeric uppercase chars of the JWT — used as a spoken code.
  static String deriveShortCode(String jwt) {
    final chars = jwt.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return chars.length >= 4 ? chars.substring(0, 4) : chars;
  }

  static void put(String jwt) {
    final code = deriveShortCode(jwt);
    if (code.length == 4) _cache[code] = jwt;
  }

  static String? lookup(String shortCode) => _cache[shortCode.toUpperCase()];
}
